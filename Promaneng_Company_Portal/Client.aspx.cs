using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Promaneng_Company_Portal
{
    public partial class Client : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ApplyRolePermissions();
            if (!IsPostBack)
            {
                LoadClientGrid();
            }
        }

        private void ApplyRolePermissions()
        {
            string role = Session["UserRole"]?.ToString() ?? "";
            // Only SystemAdmin and db_Accountant have EXECUTE on sp_RegisterNewClient
            bool canModify = (role == "SystemAdmin" || role == "db_Accountant");
            pnlClientForm.Visible = canModify;
            pnlTopActions.Visible = canModify;
        }

        private void LoadClientGrid()
        {
            try
            {
                DataTable dtActive = DatabaseHelper.ExecuteQuery("SELECT ClientID, FirstName, LastName, StreetAddress, City, Parish, Country, Email, PhoneNumber FROM dbo.Client");
                gvClients.DataSource = dtActive;
                gvClients.DataBind();
                lblActiveCount.Text = dtActive.Rows.Count.ToString();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", $"<strong>Database Error:</strong> {ex.Message}");
            }
        }

        protected void btnSaveClient_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int editId = Convert.ToInt32(hfEditClientID.Value);

            try
            {
                if (editId == 0)
                {
                    SqlParameter outId = new SqlParameter("@NewClientID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                        new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                        new SqlParameter("@LastName", txtLastName.Text.Trim()),
                        new SqlParameter("@StreetAddress", txtStreet.Text.Trim()),
                        new SqlParameter("@City", txtCity.Text.Trim()),
                        new SqlParameter("@Parish", txtParish.Text.Trim()),
                        new SqlParameter("@Country", string.IsNullOrEmpty(txtCountry.Text) ? "Jamaica" : txtCountry.Text.Trim()),
                        new SqlParameter("@Email", txtEmail.Text.Trim()),
                        new SqlParameter("@PhoneNumber", txtPhone.Text.Trim()),
                        outId
                    };

                    DatabaseHelper.ExecuteStoredProcedure("dbo.sp_RegisterNewClient", parameters);
                    ShowAlert("success", $"Client registered successfully! Assigned Client ID: <strong>{outId.Value}</strong>.");
                }
                else
                {
                    string updateQuery = @"UPDATE dbo.Client SET FirstName=@FirstName, LastName=@LastName, StreetAddress=@StreetAddress, 
                                           City=@City, Parish=@Parish, Country=@Country, Email=@Email, PhoneNumber=@PhoneNumber WHERE ClientID=@ClientID";

                    SqlParameter[] parameters = new SqlParameter[]
                    {
                        new SqlParameter("@ClientID", editId),
                        new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                        new SqlParameter("@LastName", txtLastName.Text.Trim()),
                        new SqlParameter("@StreetAddress", txtStreet.Text.Trim()),
                        new SqlParameter("@City", txtCity.Text.Trim()),
                        new SqlParameter("@Parish", txtParish.Text.Trim()),
                        new SqlParameter("@Country", txtCountry.Text.Trim()),
                        new SqlParameter("@Email", txtEmail.Text.Trim()),
                        new SqlParameter("@PhoneNumber", txtPhone.Text.Trim())
                    };

                    DatabaseHelper.ExecuteQuery(updateQuery, parameters);
                    ShowAlert("info", "Client details updated successfully!");
                }

                ResetForm();
                LoadClientGrid();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", $"<strong>Save Error:</strong> {ex.Message}");
            }
        }

        protected void gvClients_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            int clientId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ViewProfile")
            {
                ShowClientProfile(clientId);
            }
            else if (e.CommandName == "EditClient")
            {
                SqlParameter[] p = { new SqlParameter("@ClientID", clientId) };
                DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Client WHERE ClientID = @ClientID", p);

                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    hfEditClientID.Value = clientId.ToString();
                    txtFirstName.Text = r["FirstName"].ToString();
                    txtLastName.Text = r["LastName"].ToString();
                    txtEmail.Text = r["Email"].ToString();
                    txtPhone.Text = r["PhoneNumber"].ToString();
                    txtStreet.Text = r["StreetAddress"].ToString();
                    txtCity.Text = r["City"].ToString();
                    txtParish.Text = r["Parish"].ToString();
                    txtCountry.Text = r["Country"].ToString();

                    lblFormTitle.Text = $"<i class='bi bi-pencil-square'></i> Edit Client ID: {clientId}";
                    btnSaveClient.Text = "Update Client";
                    btnCancelEdit.Visible = true;
                }
            }
        }

        private void ShowClientProfile(int clientId)
        {
            SqlParameter[] p1 = { new SqlParameter("@ClientID", clientId) };
            DataTable dtClient = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Client WHERE ClientID = @ClientID", p1);

            if (dtClient.Rows.Count > 0)
            {
                DataRow r = dtClient.Rows[0];
                lblProfName.Text = $"{r["FirstName"]} {r["LastName"]}";
                lblProfPhone.Text = r["PhoneNumber"].ToString();
                lblProfEmail.Text = r["Email"].ToString();
                lblProfAddress.Text = $"{r["StreetAddress"]}, {r["City"]}, {r["Parish"]}";
                hlCreateProjectForClient.NavigateUrl = $"Projects.aspx?ClientID={clientId}#addProjectSection";

                string projSql = @"
                    SELECT F.ProjectCode, F.ProjectName, P.Status, F.EstimatedCost,
                           dbo.FN_ProjectLaborCost(F.ProjectCode) AS TotalLaborCost,
                           F.TotalEquipmentCost, F.TotalExpenses, F.BudgetStatus
                    FROM dbo.vw_ProjectFinancialOverview F
                    INNER JOIN dbo.Project P ON F.ProjectCode = P.ProjectCode
                    WHERE P.ClientID = @ClientID";

                SqlParameter[] p2 = { new SqlParameter("@ClientID", clientId) };
                DataTable dtProjects = DatabaseHelper.ExecuteQuery(projSql, p2);

                gvClientProjects.DataSource = dtProjects;
                gvClientProjects.DataBind();
                pnlClientProfile.Visible = true;
            }
        }

        protected void btnCloseProfile_Click(object sender, EventArgs e)
        {
            pnlClientProfile.Visible = false;
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hfEditClientID.Value = "0";
            txtFirstName.Text = txtLastName.Text = txtEmail.Text = txtPhone.Text = txtStreet.Text = txtCity.Text = txtParish.Text = "";
            txtCountry.Text = "Jamaica";
            lblFormTitle.Text = "<i class='bi bi-person-plus-fill'></i> Add New Client";
            btnSaveClient.Text = "Save Client";
            btnCancelEdit.Visible = false;
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}