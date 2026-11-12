using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Promaneng_Company_Portal
{
    public partial class Employees : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string role = Session["UserRole"]?.ToString() ?? "";
            pnlEmployeeForm.Visible = (role == "SystemAdmin" || role == "HR_Admin");

            if (!IsPostBack)
            {
                txtDateHired.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtDeployStart.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadDropdowns();
                LoadEmployeesGrid();
            }
        }

        private void LoadDropdowns()
        {
            DataTable dtDept = DatabaseHelper.ExecuteQuery("SELECT DepartmentID, DepartmentName FROM dbo.Department");
            ddlDepartment.DataSource = dtDept;
            ddlDepartment.DataTextField = "DepartmentName";
            ddlDepartment.DataValueField = "DepartmentID";
            ddlDepartment.DataBind();

            DataTable dtProj = DatabaseHelper.ExecuteQuery("SELECT ProjectCode, ProjectName FROM dbo.vw_ActiveProjectSummary");
            ddlDeployProject.DataSource = dtProj;
            ddlDeployProject.DataTextField = "ProjectName";
            ddlDeployProject.DataValueField = "ProjectCode";
            ddlDeployProject.DataBind();

            DataTable dtForeman = DatabaseHelper.ExecuteQuery("SELECT EmployeeID, CONCAT(FirstName, ' ', LastName) AS FullName FROM dbo.Employee");
            ddlDeployForeman.DataSource = dtForeman;
            ddlDeployForeman.DataTextField = "FullName";
            ddlDeployForeman.DataValueField = "EmployeeID";
            ddlDeployForeman.DataBind();
        }

        private void LoadEmployeesGrid(string skillFilter = "")
        {
            string sql = @"
                SELECT V.EmployeeID, V.FullName, E.TRN, D.DepartmentName, V.JobType, V.SkillSet, V.AvailabilityStatus
                FROM dbo.vw_EmployeeSkillAvailability V
                INNER JOIN dbo.Employee E ON V.EmployeeID = E.EmployeeID
                INNER JOIN dbo.Department D ON E.DepartmentID = D.DepartmentID
                WHERE (@Skill = '' OR V.SkillSet LIKE '%' + @Skill + '%')";

            SqlParameter[] p = { new SqlParameter("@Skill", skillFilter) };
            gvEmployees.DataSource = DatabaseHelper.ExecuteQuery(sql, p);
            gvEmployees.DataBind();
        }

        protected void btnSearchSkill_Click(object sender, EventArgs e) => LoadEmployeesGrid(txtSkillSearch.Text.Trim());
        protected void btnResetSearch_Click(object sender, EventArgs e) { txtSkillSearch.Text = ""; LoadEmployeesGrid(); }

        protected void btnSaveEmp_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            int editId = Convert.ToInt32(hfEditEmpID.Value);

            try
            {
                if (editId == 0)
                {
                    string sql = @"INSERT INTO dbo.Employee (DepartmentID, TRN, FirstName, LastName, StreetAddress, City, Parish, DateHired, JobType)
                                   VALUES (@Dept, @TRN, @First, @Last, @Street, @City, @Parish, @Hired, @Job)";
                    SqlParameter[] p = {
                        new SqlParameter("@Dept", Convert.ToInt32(ddlDepartment.SelectedValue)),
                        new SqlParameter("@TRN", txtTRN.Text.Trim()),
                        new SqlParameter("@First", txtFirstName.Text.Trim()),
                        new SqlParameter("@Last", txtLastName.Text.Trim()),
                        new SqlParameter("@Street", txtStreet.Text.Trim()),
                        new SqlParameter("@City", txtCity.Text.Trim()),
                        new SqlParameter("@Parish", txtParish.Text.Trim()),
                        new SqlParameter("@Hired", DateTime.Parse(txtDateHired.Text)),
                        new SqlParameter("@Job", txtJobType.Text.Trim())
                    };
                    DatabaseHelper.ExecuteQuery(sql, p);
                    ShowAlert("success", "Employee registered successfully!");
                }
                else
                {
                    string sql = @"UPDATE dbo.Employee SET DepartmentID=@Dept, TRN=@TRN, FirstName=@First, LastName=@Last,
                                   StreetAddress=@Street, City=@City, Parish=@Parish, JobType=@Job WHERE EmployeeID=@ID";
                    SqlParameter[] p = {
                        new SqlParameter("@ID", editId),
                        new SqlParameter("@Dept", Convert.ToInt32(ddlDepartment.SelectedValue)),
                        new SqlParameter("@TRN", txtTRN.Text.Trim()),
                        new SqlParameter("@First", txtFirstName.Text.Trim()),
                        new SqlParameter("@Last", txtLastName.Text.Trim()),
                        new SqlParameter("@Street", txtStreet.Text.Trim()),
                        new SqlParameter("@City", txtCity.Text.Trim()),
                        new SqlParameter("@Parish", txtParish.Text.Trim()),
                        new SqlParameter("@Job", txtJobType.Text.Trim())
                    };
                    DatabaseHelper.ExecuteQuery(sql, p);
                    ShowAlert("info", "Employee record updated!");
                }

                ResetEmpForm();
                LoadEmployeesGrid();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", ex.Message);
            }
        }

        protected void gvEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int empId = Convert.ToInt32(e.CommandArgument);
            ViewState["SelectedEmpID"] = empId;

            if (e.CommandName == "ViewProfile")
            {
                ShowEmployeeProfile(empId);
            }
            else if (e.CommandName == "EditEmployee")
            {
                SqlParameter[] p = { new SqlParameter("@ID", empId) };
                DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Employee WHERE EmployeeID = @ID", p);
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    hfEditEmpID.Value = empId.ToString();
                    ddlDepartment.SelectedValue = r["DepartmentID"].ToString();
                    txtTRN.Text = r["TRN"].ToString();
                    txtFirstName.Text = r["FirstName"].ToString();
                    txtLastName.Text = r["LastName"].ToString();
                    txtJobType.Text = r["JobType"].ToString();
                    txtStreet.Text = r["StreetAddress"].ToString();
                    txtCity.Text = r["City"].ToString();
                    txtParish.Text = r["Parish"].ToString();
                    lblEmpFormTitle.Text = $"<i class='bi bi-pencil-square'></i> Edit Employee ID: {empId}";
                    btnSaveEmp.Text = "Update Employee";
                    btnCancelEmp.Visible = true;
                }
            }
        }

        private void ShowEmployeeProfile(int empId)
        {
            SqlParameter[] p = { new SqlParameter("@ID", empId) };
            DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Employee WHERE EmployeeID = @ID", p);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            lblProfName.Text = $"{r["FirstName"]} {r["LastName"]}";
            lblProfTRN.Text = r["TRN"].ToString();
            lblProfJob.Text = r["JobType"].ToString();
            lblProfAddress.Text = $"{r["StreetAddress"]}, {r["City"]}, {r["Parish"]}";

            string histSql = @"
                SELECT A.ProjectCode, P.Name AS ProjectName, A.ProjectRole, A.StartDate, A.EndDate, A.PayRate,
                       dbo.FN_EmployeeAssignmentCost(A.EmployeeID, A.ProjectCode, A.StartDate) AS TotalEarned
                FROM dbo.Assignment A
                INNER JOIN dbo.Project P ON A.ProjectCode = P.ProjectCode
                WHERE A.EmployeeID = @ID";
            SqlParameter[] p2 = { new SqlParameter("@ID", empId) };
            gvEmpAssignments.DataSource = DatabaseHelper.ExecuteQuery(histSql, p2);
            gvEmpAssignments.DataBind();

            pnlEmployeeProfile.Visible = true;
        }

        protected void btnAddSkill_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedEmpID"] == null || string.IsNullOrWhiteSpace(txtNewSkill.Text)) return;
            int empId = (int)ViewState["SelectedEmpID"];
            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@ID", empId),
                    new SqlParameter("@Skill", txtNewSkill.Text.Trim())
                };
                DatabaseHelper.ExecuteQuery("INSERT INTO dbo.EmployeeSkills (EmployeeID, Skill) VALUES (@ID, @Skill)", p);
                txtNewSkill.Text = "";
                LoadEmployeesGrid();
                ShowAlert("success", "Skill added.");
            }
            catch (Exception ex) { ShowAlert("danger", ex.Message); }
        }

        protected void btnDeployEmp_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedEmpID"] == null) return;
            int empId = (int)ViewState["SelectedEmpID"];

            try
            {
                SqlParameter[] p = {
                    new SqlParameter("@EmployeeID", empId),
                    new SqlParameter("@ProjectCode", Convert.ToInt32(ddlDeployProject.SelectedValue)),
                    new SqlParameter("@StartDate", DateTime.Parse(txtDeployStart.Text)),
                    new SqlParameter("@EndDate", DBNull.Value),
                    new SqlParameter("@ProjectRole", txtDeployRole.Text.Trim()),
                    new SqlParameter("@PayRate", Convert.ToDecimal(txtDeployRate.Text.Trim())),
                    new SqlParameter("@ForemanID", Convert.ToInt32(ddlDeployForeman.SelectedValue))
                };
                DataTable res = DatabaseHelper.ExecuteStoredProcedure("dbo.TR_AssignEmployeeWithValidation", p);
                string msg = res.Rows.Count > 0 ? res.Rows[0]["Message"].ToString() : "Deployment processed.";
                ShowAlert(msg.StartsWith("Transaction committed") ? "success" : "danger", msg);
                ShowEmployeeProfile(empId);
                LoadEmployeesGrid();
            }
            catch (SqlException ex) { ShowAlert("danger", ex.Message); }
        }

        protected void btnCloseProfile_Click(object sender, EventArgs e) => pnlEmployeeProfile.Visible = false;
        protected void btnCancelEmp_Click(object sender, EventArgs e) => ResetEmpForm();

        private void ResetEmpForm()
        {
            hfEditEmpID.Value = "0";
            txtTRN.Text = txtFirstName.Text = txtLastName.Text = txtJobType.Text = txtStreet.Text = txtCity.Text = txtParish.Text = "";
            lblEmpFormTitle.Text = "<i class='bi bi-person-plus-fill'></i> Register New Employee";
            btnSaveEmp.Text = "Save Employee";
            btnCancelEmp.Visible = false;
        }

        private void ShowAlert(string type, string html)
        {
            lblStatusMessage.Text = $"<div class='alert alert-{type} alert-dismissible fade show'>{html}<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        }
    }
}