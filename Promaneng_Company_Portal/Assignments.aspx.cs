using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Promaneng_Company_Portal
{
    public partial class Assignments : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtCheckoutDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtReturnDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadAllData();
            }
        }

        private void LoadAllData()
        {
            // Read-only reference grids
            gvRefEmployees.DataSource = DatabaseHelper.ExecuteQuery("SELECT EmployeeID, FullName, SkillSet, AvailabilityStatus FROM dbo.vw_EmployeeSkillAvailability");
            gvRefEmployees.DataBind();

            DataTable dtActiveProj = DatabaseHelper.ExecuteQuery("SELECT ProjectCode, ProjectName, Status FROM dbo.vw_ActiveProjectSummary");
            gvRefProjects.DataSource = dtActiveProj;
            gvRefProjects.DataBind();

            DataTable dtEq = DatabaseHelper.ExecuteQuery("SELECT EquipmentID, Name, Status FROM dbo.Equipment");
            gvRefEquipment.DataSource = dtEq;
            gvRefEquipment.DataBind();

            // Form dropdowns
            DataTable dtEmp = DatabaseHelper.ExecuteQuery("SELECT EmployeeID, CONCAT(FirstName, ' ', LastName, ' (ID: ', EmployeeID, ')') AS DisplayName FROM dbo.Employee");
            ddlEmployee.DataSource = dtEmp;
            ddlEmployee.DataTextField = "DisplayName";
            ddlEmployee.DataValueField = "EmployeeID";
            ddlEmployee.DataBind();

            ddlForeman.DataSource = dtEmp;
            ddlForeman.DataTextField = "DisplayName";
            ddlForeman.DataValueField = "EmployeeID";
            ddlForeman.DataBind();

            ddlSupervisor.DataSource = dtEmp;
            ddlSupervisor.DataTextField = "DisplayName";
            ddlSupervisor.DataValueField = "EmployeeID";
            ddlSupervisor.DataBind();

            // Include all projects so trigger trg_PreventAssignmentToCompletedProject can also be demonstrated
            DataTable dtAllProj = DatabaseHelper.ExecuteQuery("SELECT ProjectCode, CONCAT(Name, ' [', Status, ']') AS DisplayName FROM dbo.Project");
            ddlProject.DataSource = dtAllProj;
            ddlProject.DataTextField = "DisplayName";
            ddlProject.DataValueField = "ProjectCode";
            ddlProject.DataBind();

            ddlEqProject.DataSource = dtActiveProj;
            ddlEqProject.DataTextField = "ProjectName";
            ddlEqProject.DataValueField = "ProjectCode";
            ddlEqProject.DataBind();

            DataTable dtAvailEq = DatabaseHelper.ExecuteQuery("SELECT EquipmentID, Name FROM dbo.Equipment WHERE Status = 'Available'");
            ddlAvailableEquipment.DataSource = dtAvailEq;
            ddlAvailableEquipment.DataTextField = "Name";
            ddlAvailableEquipment.DataValueField = "EquipmentID";
            ddlAvailableEquipment.DataBind();

            DataTable dtOpenUsage = DatabaseHelper.ExecuteQuery(@"
                SELECT CONCAT(EU.ProjectCode, '|', EU.EquipmentID) AS CompositeKey,
                       CONCAT('Project #', EU.ProjectCode, ' - ', E.Name) AS Label
                FROM dbo.EquipmentUsage EU
                INNER JOIN dbo.Equipment E ON EU.EquipmentID = E.EquipmentID
                WHERE EU.EndDate IS NULL");
            ddlActiveDeployments.DataSource = dtOpenUsage;
            ddlActiveDeployments.DataTextField = "Label";
            ddlActiveDeployments.DataValueField = "CompositeKey";
            ddlActiveDeployments.DataBind();
        }

        protected void btnAssignEmployee_Click(object sender, EventArgs e)
        {
            try
            {
                object endDateVal = string.IsNullOrEmpty(txtEndDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtEndDate.Text);

                SqlParameter[] p = {
                    new SqlParameter("@EmployeeID", Convert.ToInt32(ddlEmployee.SelectedValue)),
                    new SqlParameter("@ProjectCode", Convert.ToInt32(ddlProject.SelectedValue)),
                    new SqlParameter("@StartDate", DateTime.Parse(txtStartDate.Text)),
                    new SqlParameter("@EndDate", endDateVal),
                    new SqlParameter("@ProjectRole", txtProjectRole.Text.Trim()),
                    new SqlParameter("@PayRate", Convert.ToDecimal(txtPayRate.Text.Trim())),
                    new SqlParameter("@ForemanID", Convert.ToInt32(ddlForeman.SelectedValue))
                };

                DataTable res = DatabaseHelper.ExecuteStoredProcedure("dbo.TR_AssignEmployeeWithValidation", p);
                string msg = res.Rows.Count > 0 ? res.Rows[0]["Message"].ToString() : "Assignment processed.";
                ShowAlert(msg.StartsWith("Transaction committed") ? "success" : "danger", msg);
                LoadAllData();
            }
            catch (SqlException ex)
            {
                // Displays trigger errors (trg_PreventSelfSupervision / trg_PreventAssignmentToCompletedProject)
                ShowAlert("danger", $"<strong>Rule Violation:</strong> {ex.Message}");
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void btnCheckoutEq_Click(object sender, EventArgs e)
        {
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@ProjectCode", Convert.ToInt32(ddlEqProject.SelectedValue)),
                    new SqlParameter("@EquipmentID", Convert.ToInt32(ddlAvailableEquipment.SelectedValue)),
                    new SqlParameter("@StartDate", DateTime.Parse(txtCheckoutDate.Text)),
                    new SqlParameter("@SupervisorID", Convert.ToInt32(ddlSupervisor.SelectedValue))
                };
                DatabaseHelper.ExecuteStoredProcedure("dbo.sp_CheckoutEquipment", p);
                ShowAlert("success", "Equipment checked out to project site!");
                LoadAllData();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void btnCheckinEq_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlActiveDeployments.SelectedValue)) return;
            try
            {
                string[] parts = ddlActiveDeployments.SelectedValue.Split('|');
                SqlParameter[] p = {
                    new SqlParameter("@ProjectCode", Convert.ToInt32(parts[0])),
                    new SqlParameter("@EquipmentID", Convert.ToInt32(parts[1])),
                    new SqlParameter("@EndDate", DateTime.Parse(txtReturnDate.Text))
                };
                DatabaseHelper.ExecuteStoredProcedure("dbo.sp_CheckinEquipment", p);
                ShowAlert("success", "Equipment returned and cost calculated!");
                LoadAllData();
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}