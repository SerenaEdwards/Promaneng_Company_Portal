using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Promaneng_Company_Portal
{
    public partial class ProjectProfile : Page
    {
        private int ProjectCode => int.TryParse(Request.QueryString["ProjectCode"], out int code) ? code : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (ProjectCode == 0)
            {
                Response.Redirect("Projects.aspx");
                return;
            }

            if (!IsPostBack)
            {
                txtCompletionDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtAssignStart.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadDropdowns();
                LoadProjectDetails();
            }
        }

        private void LoadDropdowns()
        {
            DataTable dtEmp = DatabaseHelper.ExecuteQuery("SELECT EmployeeID, CONCAT(FirstName, ' ', LastName) AS FullName FROM dbo.Employee");
            ddlEmployee.DataSource = dtEmp;
            ddlEmployee.DataTextField = "FullName";
            ddlEmployee.DataValueField = "EmployeeID";
            ddlEmployee.DataBind();

            ddlForeman.DataSource = dtEmp;
            ddlForeman.DataTextField = "FullName";
            ddlForeman.DataValueField = "EmployeeID";
            ddlForeman.DataBind();
        }

        private void LoadProjectDetails()
        {
            SqlParameter[] p = { new SqlParameter("@ProjectCode", ProjectCode) };
            string sql = @"
                SELECT P.*, F.ClientName, dbo.FN_ProjectLaborCost(P.ProjectCode) AS LaborCost,
                       F.TotalEquipmentCost, F.BudgetStatus
                FROM dbo.Project P
                INNER JOIN dbo.vw_ProjectFinancialOverview F ON P.ProjectCode = F.ProjectCode
                WHERE P.ProjectCode = @ProjectCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            lblProjectTitle.Text = $"#{ProjectCode}: {r["Name"]}";
            lblClientName.Text = r["ClientName"].ToString();
            lblStatus.Text = r["Status"].ToString();
            lblLocation.Text = $"{r["StreetAddress"]}, {r["City"]}, {r["Parish"]}";
            lblEstCost.Text = Convert.ToDecimal(r["EstimatedCost"]).ToString("C");
            lblLaborCost.Text = Convert.ToDecimal(r["LaborCost"]).ToString("C");
            lblEquipCost.Text = Convert.ToDecimal(r["TotalEquipmentCost"]).ToString("C");
            lblBudgetHealth.Text = r["BudgetStatus"].ToString();

            bool isCompleted = r["Status"].ToString() == "Completed";
            string role = Session["UserRole"]?.ToString() ?? "";
            bool canManage = (role == "SystemAdmin" || role == "db_SiteManager");

            pnlCloseProject.Visible = !isCompleted && canManage;
            pnlAddCrew.Visible = !isCompleted && canManage;

            // Assigned Crew with FN_EmployeeAssignmentCost
            SqlParameter[] pCrew = { new SqlParameter("@ProjectCode", ProjectCode) };
            string crewSql = @"
                SELECT A.EmployeeID, CONCAT(E.FirstName, ' ', E.LastName) AS EmployeeName,
                       A.ProjectRole, A.StartDate, A.EndDate, A.PayRate,
                       dbo.FN_EmployeeAssignmentCost(A.EmployeeID, A.ProjectCode, A.StartDate) AS AssignmentCost
                FROM dbo.Assignment A
                INNER JOIN dbo.Employee E ON A.EmployeeID = E.EmployeeID
                WHERE A.ProjectCode = @ProjectCode";
            gvProjectCrew.DataSource = DatabaseHelper.ExecuteQuery(crewSql, pCrew);
            gvProjectCrew.DataBind();

            // Assigned Equipment via vw_EquipmentUsageCosts joined to EquipmentID
            SqlParameter[] pEq = { new SqlParameter("@ProjectCode", ProjectCode) };
            string eqSql = @"
                SELECT EU.EquipmentID, V.EquipmentName, V.EquipmentType, V.StartDate, V.EndDate, V.TotalCost
                FROM dbo.vw_EquipmentUsageCosts V
                INNER JOIN dbo.EquipmentUsage EU ON V.ProjectCode = EU.ProjectCode AND V.StartDate = EU.StartDate
                INNER JOIN dbo.Equipment E ON EU.EquipmentID = E.EquipmentID AND E.Name = V.EquipmentName
                WHERE V.ProjectCode = @ProjectCode";
            gvProjectEquipment.DataSource = DatabaseHelper.ExecuteQuery(eqSql, pEq);
            gvProjectEquipment.DataBind();
        }

        protected void btnCloseProject_Click(object sender, EventArgs e)
        {
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@ProjectCode", ProjectCode),
                    new SqlParameter("@CompletionDate", DateTime.Parse(txtCompletionDate.Text))
                };
                DatabaseHelper.ExecuteStoredProcedure("dbo.sp_CloseProject", p);
                ShowAlert("success", "Project formally closed; open assignments and equipment usages ended.");
                LoadProjectDetails();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", ex.Message);
            }
        }

        protected void btnAssignCrew_Click(object sender, EventArgs e)
        {
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@EmployeeID", Convert.ToInt32(ddlEmployee.SelectedValue)),
                    new SqlParameter("@ProjectCode", ProjectCode),
                    new SqlParameter("@StartDate", DateTime.Parse(txtAssignStart.Text)),
                    new SqlParameter("@EndDate", DBNull.Value),
                    new SqlParameter("@ProjectRole", txtRole.Text.Trim()),
                    new SqlParameter("@PayRate", Convert.ToDecimal(txtPayRate.Text.Trim())),
                    new SqlParameter("@ForemanID", Convert.ToInt32(ddlForeman.SelectedValue))
                };

                DataTable res = DatabaseHelper.ExecuteStoredProcedure("dbo.TR_AssignEmployeeWithValidation", p);
                string msg = res.Rows.Count > 0 ? res.Rows[0]["Message"].ToString() : "Assignment processed.";
                ShowAlert(msg.StartsWith("Transaction committed") ? "success" : "danger", msg);
                LoadProjectDetails();
            }
            catch (SqlException ex)
            {
                ShowAlert("danger", ex.Message);
            }
        }

        protected void gvProjectEquipment_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CheckinEquipment")
            {
                try
                {
                    SqlParameter[] p = {
                        new SqlParameter("@ProjectCode", ProjectCode),
                        new SqlParameter("@EquipmentID", Convert.ToInt32(e.CommandArgument)),
                        new SqlParameter("@EndDate", DateTime.Today)
                    };
                    DatabaseHelper.ExecuteStoredProcedure("dbo.sp_CheckinEquipment", p);
                    ShowAlert("success", "Equipment checked in and automatically returned to 'Available'.");
                    LoadProjectDetails();
                }
                catch (Exception ex)
                {
                    ShowAlert("danger", ex.Message);
                }
            }
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}