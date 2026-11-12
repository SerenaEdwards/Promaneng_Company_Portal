using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Promaneng_Company_Portal
{
    public partial class Maintenance : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string role = Session["UserRole"]?.ToString() ?? "";
            bool isSysAdmin = (role == "SystemAdmin");
            pnlNewServiceOrder.Visible = isSysAdmin;
            pnlAddVendor.Visible = isSysAdmin;

            if (!IsPostBack)
            {
                txtServiceStart.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtCompleteEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadDropdowns();
                LoadGrids();
            }
        }

        private void LoadDropdowns()
        {
            DataTable dtEq = DatabaseHelper.ExecuteQuery("SELECT EquipmentID, Name FROM dbo.Equipment WHERE Status <> 'Under Maintenance'");
            ddlEquipment.DataSource = dtEq;
            ddlEquipment.DataTextField = "Name";
            ddlEquipment.DataValueField = "EquipmentID";
            ddlEquipment.DataBind();

            DataTable dtVen = DatabaseHelper.ExecuteQuery("SELECT VendorID, CompanyName FROM dbo.Vendor");
            ddlVendor.DataSource = dtVen;
            ddlVendor.DataTextField = "CompanyName";
            ddlVendor.DataValueField = "VendorID";
            ddlVendor.DataBind();
        }

        private void LoadGrids()
        {
            string venSql = @"
                SELECT V.VendorID, V.CompanyName, V.LiaisonName, V.LiaisonPhone, V.LiaisonEmail,
                       P.TotalMaintenanceJobs, P.AverageMaintenanceDurationDays, P.TotalMaintenanceSpend
                FROM dbo.Vendor V
                INNER JOIN dbo.vw_VendorPerformanceAndSpend P ON V.VendorID = P.VendorID";
            gvVendors.DataSource = DatabaseHelper.ExecuteQuery(venSql);
            gvVendors.DataBind();

            string recSql = @"
                SELECT M.VendorID, V.CompanyName, M.EquipmentID, E.Name AS EquipmentName,
                       M.StartDate, M.EndDate, M.Description, M.TotalCost
                FROM dbo.MaintenanceRecord M
                INNER JOIN dbo.Vendor V ON M.VendorID = V.VendorID
                INNER JOIN dbo.Equipment E ON M.EquipmentID = E.EquipmentID";
            gvMaintenanceRecords.DataSource = DatabaseHelper.ExecuteQuery(recSql);
            gvMaintenanceRecords.DataBind();
        }

        protected void btnSubmitMaintenance_Click(object sender, EventArgs e)
        {
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@EquipmentID", Convert.ToInt32(ddlEquipment.SelectedValue)),
                    new SqlParameter("@VendorID", Convert.ToInt32(ddlVendor.SelectedValue)),
                    new SqlParameter("@StartDate", DateTime.Parse(txtServiceStart.Text)),
                    new SqlParameter("@EndDate", DBNull.Value),
                    new SqlParameter("@Description", txtDescription.Text.Trim()),
                    new SqlParameter("@TotalCost", 0.00m)
                };
                DataTable res = DatabaseHelper.ExecuteStoredProcedure("dbo.TR_EquipmentMaintenanceWorkflow", p);
                string msg = res.Rows.Count > 0 ? res.Rows[0]["Message"].ToString() : "Maintenance order created.";
                ShowAlert(msg.StartsWith("Transaction committed") ? "success" : "danger", msg);
                txtDescription.Text = "";
                LoadDropdowns();
                LoadGrids();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void gvMaintenanceRecords_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SelectRecord")
            {
                hfCompleteKey.Value = e.CommandArgument.ToString();
                pnlCompleteRepair.Visible = true;
            }
        }

        protected void btnConfirmComplete_Click(object sender, EventArgs e)
        {
            try
            {
                string[] parts = hfCompleteKey.Value.Split('|');
                string sql = @"UPDATE dbo.MaintenanceRecord
                               SET EndDate = @EndDate, TotalCost = @Cost
                               WHERE VendorID = @VendorID AND EquipmentID = @EquipmentID AND StartDate = @StartDate";
                SqlParameter[] p = {
                    new SqlParameter("@VendorID", Convert.ToInt32(parts[0])),
                    new SqlParameter("@EquipmentID", Convert.ToInt32(parts[1])),
                    new SqlParameter("@StartDate", DateTime.Parse(parts[2])),
                    new SqlParameter("@EndDate", DateTime.Parse(txtCompleteEndDate.Text)),
                    new SqlParameter("@Cost", Convert.ToDecimal(txtFinalCost.Text.Trim()))
                };
                DatabaseHelper.ExecuteQuery(sql, p);
                pnlCompleteRepair.Visible = false;
                ShowAlert("success", "Maintenance finalized and equipment automatically returned to 'Available' via trigger!");
                LoadDropdowns();
                LoadGrids();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void btnAddVendor_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = @"INSERT INTO dbo.Vendor (CompanyName, LiaisonName, LiaisonEmail, LiaisonPhone)
                               VALUES (@Name, @Liaison, @Email, @Phone)";
                SqlParameter[] p = {
                    new SqlParameter("@Name", txtCompanyName.Text.Trim()),
                    new SqlParameter("@Liaison", txtLiaisonName.Text.Trim()),
                    new SqlParameter("@Email", txtLiaisonEmail.Text.Trim()),
                    new SqlParameter("@Phone", txtLiaisonPhone.Text.Trim())
                };
                DatabaseHelper.ExecuteQuery(sql, p);
                txtCompanyName.Text = txtLiaisonName.Text = txtLiaisonEmail.Text = txtLiaisonPhone.Text = "";
                ShowAlert("success", "Vendor registered successfully!");
                LoadDropdowns();
                LoadGrids();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}