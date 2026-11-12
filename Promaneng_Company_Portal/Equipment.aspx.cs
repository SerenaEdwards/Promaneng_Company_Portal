using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Promaneng_Company_Portal
{
    public partial class Equipment : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string role = Session["UserRole"]?.ToString() ?? "";
            pnlEquipmentForm.Visible = (role == "SystemAdmin");

            if (!IsPostBack)
            {
                txtDispatchDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtMaintStart.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadDropdowns();
                LoadEquipmentGrid();
            }
        }

        private void LoadDropdowns()
        {
            DataTable dtProj = DatabaseHelper.ExecuteQuery("SELECT ProjectCode, ProjectName FROM dbo.vw_ActiveProjectSummary");
            ddlDispatchProject.DataSource = dtProj;
            ddlDispatchProject.DataTextField = "ProjectName";
            ddlDispatchProject.DataValueField = "ProjectCode";
            ddlDispatchProject.DataBind();

            DataTable dtSup = DatabaseHelper.ExecuteQuery("SELECT EmployeeID, CONCAT(FirstName, ' ', LastName) AS FullName FROM dbo.Employee");
            ddlDispatchSupervisor.DataSource = dtSup;
            ddlDispatchSupervisor.DataTextField = "FullName";
            ddlDispatchSupervisor.DataValueField = "EmployeeID";
            ddlDispatchSupervisor.DataBind();

            DataTable dtVendors = DatabaseHelper.ExecuteQuery("SELECT VendorID, CompanyName FROM dbo.Vendor");
            ddlMaintVendor.DataSource = dtVendors;
            ddlMaintVendor.DataTextField = "CompanyName";
            ddlMaintVendor.DataValueField = "VendorID";
            ddlMaintVendor.DataBind();
        }

        private void LoadEquipmentGrid()
        {
            DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Equipment");
            gvEquipment.DataSource = dt;
            gvEquipment.DataBind();
            lblFleetCount.Text = dt.Rows.Count.ToString();
        }

        protected void btnSaveEq_Click(object sender, EventArgs e)
        {
            int editId = Convert.ToInt32(hfEditEqID.Value);
            try
            {
                if (editId == 0)
                {
                    string sql = @"INSERT INTO dbo.Equipment (Name, AcquisitionCost, CostPerDay, Type, Status, OwnershipType)
                                   VALUES (@Name, @Acq, @Rate, @Type, 'Available', @Owner)";
                    SqlParameter[] p = {
                        new SqlParameter("@Name", txtEqName.Text.Trim()),
                        new SqlParameter("@Acq", Convert.ToDecimal(txtAcqCost.Text.Trim())),
                        new SqlParameter("@Rate", Convert.ToDecimal(txtDailyRate.Text.Trim())),
                        new SqlParameter("@Type", txtEqType.Text.Trim()),
                        new SqlParameter("@Owner", ddlOwnership.SelectedValue)
                    };
                    DatabaseHelper.ExecuteQuery(sql, p);
                    ShowAlert("success", "Equipment added to fleet!");
                }
                else
                {
                    string sql = @"UPDATE dbo.Equipment SET Name=@Name, AcquisitionCost=@Acq, CostPerDay=@Rate, Type=@Type, OwnershipType=@Owner
                                   WHERE EquipmentID=@ID";
                    SqlParameter[] p = {
                        new SqlParameter("@ID", editId),
                        new SqlParameter("@Name", txtEqName.Text.Trim()),
                        new SqlParameter("@Acq", Convert.ToDecimal(txtAcqCost.Text.Trim())),
                        new SqlParameter("@Rate", Convert.ToDecimal(txtDailyRate.Text.Trim())),
                        new SqlParameter("@Type", txtEqType.Text.Trim()),
                        new SqlParameter("@Owner", ddlOwnership.SelectedValue)
                    };
                    DatabaseHelper.ExecuteQuery(sql, p);
                    ShowAlert("info", "Equipment updated!");
                }
                ResetEqForm();
                LoadEquipmentGrid();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void gvEquipment_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int eqId = Convert.ToInt32(e.CommandArgument);
            ViewState["SelectedEqID"] = eqId;

            if (e.CommandName == "ViewEquipment")
            {
                ShowEquipmentProfile(eqId);
            }
            else if (e.CommandName == "EditEquipment")
            {
                SqlParameter[] p = { new SqlParameter("@ID", eqId) };
                DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Equipment WHERE EquipmentID = @ID", p);
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    hfEditEqID.Value = eqId.ToString();
                    txtEqName.Text = r["Name"].ToString();
                    txtEqType.Text = r["Type"].ToString();
                    ddlOwnership.SelectedValue = r["OwnershipType"].ToString();
                    txtAcqCost.Text = r["AcquisitionCost"].ToString();
                    txtDailyRate.Text = r["CostPerDay"].ToString();
                    lblEqFormTitle.Text = $"<i class='bi bi-pencil-square'></i> Edit Equipment ID: {eqId}";
                    btnSaveEq.Text = "Update Equipment";
                    btnCancelEq.Visible = true;
                }
            }
        }

        private void ShowEquipmentProfile(int eqId)
        {
            SqlParameter[] p = { new SqlParameter("@ID", eqId) };
            DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Equipment WHERE EquipmentID = @ID", p);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            lblEqProfileTitle.Text = $"#{eqId}: {r["Name"]}";
            lblEqType.Text = r["Type"].ToString();
            lblEqOwner.Text = r["OwnershipType"].ToString();
            lblEqStatus.Text = r["Status"].ToString();
            lblEqAcq.Text = Convert.ToDecimal(r["AcquisitionCost"]).ToString("C");
            lblEqRate.Text = Convert.ToDecimal(r["CostPerDay"]).ToString("C");

            pnlDispatch.Visible = (r["Status"].ToString() == "Available");
            pnlSendMaintenance.Visible = (r["Status"].ToString() != "Under Maintenance");

            // Vendor performance reference
            gvVendorRef.DataSource = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.vw_VendorPerformanceAndSpend");
            gvVendorRef.DataBind();

            // Deployment history via vw_EquipmentUsageCosts
            SqlParameter[] pHist = { new SqlParameter("@EqName", r["Name"].ToString()) };
            gvEqHistory.DataSource = DatabaseHelper.ExecuteQuery("SELECT ProjectCode, StartDate, EndDate, TotalCost FROM dbo.vw_EquipmentUsageCosts WHERE EquipmentName = @EqName", pHist);
            gvEqHistory.DataBind();

            pnlEquipmentProfile.Visible = true;
        }

        protected void btnDispatch_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedEqID"] == null) return;
            int eqId = (int)ViewState["SelectedEqID"];
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@ProjectCode", Convert.ToInt32(ddlDispatchProject.SelectedValue)),
                    new SqlParameter("@EquipmentID", eqId),
                    new SqlParameter("@StartDate", DateTime.Parse(txtDispatchDate.Text)),
                    new SqlParameter("@SupervisorID", Convert.ToInt32(ddlDispatchSupervisor.SelectedValue))
                };
                DatabaseHelper.ExecuteStoredProcedure("dbo.sp_CheckoutEquipment", p);
                ShowAlert("success", "Equipment dispatched to project site!");
                ShowEquipmentProfile(eqId);
                LoadEquipmentGrid();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void btnSendMaint_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedEqID"] == null) return;
            int eqId = (int)ViewState["SelectedEqID"];
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@EquipmentID", eqId),
                    new SqlParameter("@VendorID", Convert.ToInt32(ddlMaintVendor.SelectedValue)),
                    new SqlParameter("@StartDate", DateTime.Parse(txtMaintStart.Text)),
                    new SqlParameter("@EndDate", DBNull.Value),
                    new SqlParameter("@Description", txtMaintDesc.Text.Trim()),
                    new SqlParameter("@TotalCost", 0.00m)
                };
                DataTable res = DatabaseHelper.ExecuteStoredProcedure("dbo.TR_EquipmentMaintenanceWorkflow", p);
                string msg = res.Rows.Count > 0 ? res.Rows[0]["Message"].ToString() : "Maintenance order logged.";
                ShowAlert(msg.StartsWith("Transaction committed") ? "success" : "danger", msg);
                ShowEquipmentProfile(eqId);
                LoadEquipmentGrid();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void gvEqHistory_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ReturnFromProject" && ViewState["SelectedEqID"] != null)
            {
                int eqId = (int)ViewState["SelectedEqID"];
                try
                {
                    SqlParameter[] p = {
                        new SqlParameter("@ProjectCode", Convert.ToInt32(e.CommandArgument)),
                        new SqlParameter("@EquipmentID", eqId),
                        new SqlParameter("@EndDate", DateTime.Today)
                    };
                    DatabaseHelper.ExecuteStoredProcedure("dbo.sp_CheckinEquipment", p);
                    ShowAlert("success", "Equipment returned and status flipped to Available!");
                    ShowEquipmentProfile(eqId);
                    LoadEquipmentGrid();
                }
                catch (Exception ex) { ShowAlert("danger", ex.Message); }
            }
        }

        protected void btnCloseEqProfile_Click(object sender, EventArgs e) => pnlEquipmentProfile.Visible = false;
        protected void btnCancelEq_Click(object sender, EventArgs e) => ResetEqForm();

        private void ResetEqForm()
        {
            hfEditEqID.Value = "0";
            txtEqName.Text = txtEqType.Text = txtDailyRate.Text = "";
            txtAcqCost.Text = "0.00";
            lblEqFormTitle.Text = "<i class='bi bi-plus-circle'></i> Add Equipment to Fleet";
            btnSaveEq.Text = "Save Equipment";
            btnCancelEq.Visible = false;
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}