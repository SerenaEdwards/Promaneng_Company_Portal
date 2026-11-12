using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Promaneng_Company_Portal
{
    public partial class Projects : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string role = Session["UserRole"]?.ToString() ?? "";
            pnlAddProject.Visible = (role == "SystemAdmin" || role == "db_SiteManager");

            if (!IsPostBack)
            {
                LoadClientsDropdown();
                if (!string.IsNullOrEmpty(Request.QueryString["ClientID"]) && ddlClient.Items.FindByValue(Request.QueryString["ClientID"]) != null)
                {
                    ddlClient.SelectedValue = Request.QueryString["ClientID"];
                }
                LoadProjectsGrid();
            }
        }

        private void LoadClientsDropdown()
        {
            DataTable dt = DatabaseHelper.ExecuteQuery("SELECT ClientID, CONCAT(FirstName, ' ', LastName, ' (ID: ', ClientID, ')') AS DisplayName FROM dbo.Client");
            ddlClient.DataSource = dt;
            ddlClient.DataTextField = "DisplayName";
            ddlClient.DataValueField = "ClientID";
            ddlClient.DataBind();
        }

        protected string FormatDuration(object daysObj)
        {
            if (daysObj == null || daysObj == DBNull.Value) return "N/A";
            int days = Convert.ToInt32(daysObj);
            int weeks = days / 7;
            int remainingDays = days % 7;

            if (weeks > 0)
                return $"{weeks} week{(weeks > 1 ? "s" : "")}{(remainingDays > 0 ? $" {remainingDays} day{(remainingDays > 1 ? "s" : "")}" : "")}";
            return $"{remainingDays} day{(remainingDays > 1 ? "s" : "")}";
        }

        private void LoadProjectsGrid()
        {
            try
            {
                // Active Projects via vw_ActiveProjectSummary
                DataTable dtActive = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.vw_ActiveProjectSummary");
                gvActiveProjects.DataSource = dtActive;
                gvActiveProjects.DataBind();
                lblActiveSummaryCount.Text = dtActive.Rows.Count.ToString();

                // Financial Overview via vw_ProjectFinancialOverview + FN_ProjectLaborCost
                string sql = @"
                    SELECT F.ProjectCode, F.ProjectName, F.ClientName, P.Status,
                           F.EstimatedCost, dbo.FN_ProjectLaborCost(F.ProjectCode) AS TotalLaborCost,
                           F.TotalEquipmentCost, F.RemainingBudget, F.BudgetStatus
                    FROM dbo.vw_ProjectFinancialOverview F
                    INNER JOIN dbo.Project P ON F.ProjectCode = P.ProjectCode";

                DataTable dtAll = DatabaseHelper.ExecuteQuery(sql);
                gvProjects.DataSource = dtAll;
                gvProjects.DataBind();
                lblActiveCount.Text = dtAll.Rows.Count.ToString();

                int within = 0, near = 0, over = 0;
                foreach (DataRow row in dtAll.Rows)
                {
                    string status = row["BudgetStatus"].ToString();
                    if (status == "Within Budget") within++;
                    else if (status == "Near Budget Limit") near++;
                    else if (status == "Over Budget") over++;
                }
                lblWithinBudgetCount.Text = within.ToString();
                lblNearBudgetCount.Text = near.ToString();
                lblOverBudgetCount.Text = over.ToString();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", $"<strong>Database Error:</strong> {ex.Message}");
            }
        }

        protected void btnRegisterProject_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                SqlParameter outCode = new SqlParameter("@NewProjectCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@ClientID", Convert.ToInt32(ddlClient.SelectedValue)),
                    new SqlParameter("@Name", txtProjectName.Text.Trim()),
                    new SqlParameter("@StreetAddress", txtStreet.Text.Trim()),
                    new SqlParameter("@City", txtCity.Text.Trim()),
                    new SqlParameter("@Parish", txtParish.Text.Trim()),
                    new SqlParameter("@Country", string.IsNullOrEmpty(txtCountry.Text) ? "Jamaica" : txtCountry.Text.Trim()),
                    new SqlParameter("@EstimatedCost", Convert.ToDecimal(txtEstCost.Text.Trim())),
                    new SqlParameter("@EstimatedTime", Convert.ToInt32(txtEstTime.Text.Trim())),
                    outCode
                };

                DatabaseHelper.ExecuteStoredProcedure("dbo.sp_RegisterNewProject", parameters);
                ShowAlert("success", $"Project registered as 'Not Started'! New Project Code: <strong>{outCode.Value}</strong>.");
                txtProjectName.Text = txtEstCost.Text = txtEstTime.Text = txtStreet.Text = txtCity.Text = txtParish.Text = "";
                LoadProjectsGrid();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", $"<strong>Registration Error:</strong> {ex.Message}");
            }
        }

        protected void gvProjects_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewProject")
            {
                Response.Redirect($"ProjectProfile.aspx?ProjectCode={e.CommandArgument}");
            }
            else if (e.CommandName == "EditProject")
            {
                Response.Redirect($"EditProject.aspx?ProjectCode={e.CommandArgument}");
            }
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}