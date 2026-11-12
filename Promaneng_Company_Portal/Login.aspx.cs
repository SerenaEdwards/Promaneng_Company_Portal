using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Promaneng_Company_Portal
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserRole"] != null)
            {
                Response.Redirect("Default.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string selectedRole = ddlRole.SelectedValue;
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            try
            {
                if (selectedRole == "SystemAdmin")
                {
                    if (username.Equals("admin", StringComparison.OrdinalIgnoreCase) && password == "Admin123!")
                    {
                        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Conn_SystemAdmin"].ConnectionString))
                        {
                            conn.Open();
                        }

                        Session["UserName"] = "System Admin";
                        Session["UserRole"] = "SystemAdmin";
                        Response.Redirect("Default.aspx");
                    }
                    else
                    {
                        ShowError("Invalid System Admin credentials.");
                    }
                }
                else
                {
                    bool validMapping =
                        (selectedRole == "HR_Admin" && username.Equals("HRAdminLogin", StringComparison.OrdinalIgnoreCase)) ||
                        (selectedRole == "db_SiteManager" && username.Equals("SiteManagerLogin", StringComparison.OrdinalIgnoreCase)) ||
                        (selectedRole == "db_Accountant" && username.Equals("AccountantLogin", StringComparison.OrdinalIgnoreCase));

                    if (!validMapping)
                    {
                        ShowError("The username entered does not match the selected database role.");
                        return;
                    }

                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(
                        ConfigurationManager.ConnectionStrings["Conn_SystemAdmin"].ConnectionString)
                    {
                        IntegratedSecurity = false,
                        UserID = username,
                        Password = password
                    };

                    using (SqlConnection conn = new SqlConnection(builder.ConnectionString))
                    {
                        conn.Open();
                    }

                    Session["UserName"] = username;
                    Session["UserRole"] = selectedRole;
                    Response.Redirect("Default.aspx");
                }
            }
            catch (SqlException)
            {
                ShowError("Authentication failed. Verify your SQL Server login credentials and Mixed Mode Authentication.");
            }
            catch (Exception ex)
            {
                ShowError("Login error: " + ex.Message);
            }
        }

        private void ShowError(string message)
        {
            lblLoginError.Text = $"<div class='alert alert-danger py-2 small'>{message}</div>";
        }
    }
}