using System;
using System.Data;
using System.Web.UI;

namespace Promaneng_Company_Portal
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            try
            {
                // 1. Active Projects Summary (vw_ActiveProjectSummary)
                DataTable dtActiveProjects = DatabaseHelper.ExecuteQuery("SELECT ProjectCode, ProjectName, ClientName, Status, EstimatedCost FROM dbo.vw_ActiveProjectSummary");
                lblActiveProjectsCount.Text = dtActiveProjects.Rows.Count.ToString();
                gvActiveOperations.DataSource = dtActiveProjects;
                gvActiveOperations.DataBind();

                // 2. Available Equipment Count (Equipment WHERE Status = 'Available')
                DataTable dtAvailableEq = DatabaseHelper.ExecuteQuery("SELECT COUNT(*) FROM dbo.Equipment WHERE Status = 'Available'");
                lblAvailableEquipmentCount.Text = dtAvailableEq.Rows[0][0].ToString();

                // 3. Total Employees Assigned (vw_EmployeeSkillAvailability)
                DataTable dtAssignedEmp = DatabaseHelper.ExecuteQuery("SELECT COUNT(*) FROM dbo.vw_EmployeeSkillAvailability WHERE AvailabilityStatus = 'Assigned'");
                lblAssignedEmployeesCount.Text = dtAssignedEmp.Rows[0][0].ToString();

                // 4. High-Priority Alert 1: Equipment Under Maintenance
                DataTable dtMaint = DatabaseHelper.ExecuteQuery("SELECT EquipmentID, Name, Type FROM dbo.Equipment WHERE Status = 'Under Maintenance'");
                gvMaintenanceAlerts.DataSource = dtMaint;
                gvMaintenanceAlerts.DataBind();

                // 5. High-Priority Alert 2: Ongoing Projects Exceeding EstimatedTime
                string overrunQuery = @"
                    SELECT P.ProjectCode, P.Name, P.EstimatedTime,
                           DATEDIFF(DAY, MIN(A.StartDate), CAST(GETDATE() AS DATE)) AS ElapsedDays
                    FROM dbo.Project P
                    INNER JOIN dbo.Assignment A ON P.ProjectCode = A.ProjectCode
                    WHERE P.Status = 'Ongoing'
                    GROUP BY P.ProjectCode, P.Name, P.EstimatedTime
                    HAVING DATEDIFF(DAY, MIN(A.StartDate), CAST(GETDATE() AS DATE)) > P.EstimatedTime";

                DataTable dtOverrun = DatabaseHelper.ExecuteQuery(overrunQuery);
                gvScheduleAlerts.DataSource = dtOverrun;
                gvScheduleAlerts.DataBind();
            }
            catch
            {
                lblActiveProjectsCount.Text = "0";
                lblAvailableEquipmentCount.Text = "0";
                lblAssignedEmployeesCount.Text = "0";
            }
        }
    }
}