using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Promaneng_Company_Portal
{
    public partial class EditProject : Page
    {
        private int ProjectCode => int.TryParse(Request.QueryString["ProjectCode"], out int code) ? code : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (ProjectCode == 0) { Response.Redirect("Projects.aspx"); return; }
            if (!IsPostBack)
            {
                SqlParameter[] p = { new SqlParameter("@ProjectCode", ProjectCode) };
                DataTable dt = DatabaseHelper.ExecuteQuery("SELECT * FROM dbo.Project WHERE ProjectCode = @ProjectCode", p);
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    txtName.Text = r["Name"].ToString();
                    txtEstCost.Text = r["EstimatedCost"].ToString();
                    txtEstTime.Text = r["EstimatedTime"].ToString();
                    txtStreet.Text = r["StreetAddress"].ToString();
                    txtCity.Text = r["City"].ToString();
                    txtParish.Text = r["Parish"].ToString();
                    txtCountry.Text = r["Country"].ToString();
                }
            }
        }

        protected void btnUpdateProject_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = @"UPDATE dbo.Project SET Name=@Name, EstimatedCost=@Cost, EstimatedTime=@Time,
                               StreetAddress=@Street, City=@City, Parish=@Parish, Country=@Country
                               WHERE ProjectCode=@Code";
                SqlParameter[] p = {
                    new SqlParameter("@Code", ProjectCode),
                    new SqlParameter("@Name", txtName.Text.Trim()),
                    new SqlParameter("@Cost", Convert.ToDecimal(txtEstCost.Text.Trim())),
                    new SqlParameter("@Time", Convert.ToInt32(txtEstTime.Text.Trim())),
                    new SqlParameter("@Street", txtStreet.Text.Trim()),
                    new SqlParameter("@City", txtCity.Text.Trim()),
                    new SqlParameter("@Parish", txtParish.Text.Trim()),
                    new SqlParameter("@Country", txtCountry.Text.Trim())
                };
                DatabaseHelper.ExecuteQuery(sql, p);
                lblStatusMessage.Text = "<div class='alert alert-success'>Project updated successfully!</div>";
            }
            catch (Exception ex)
            {
                lblStatusMessage.Text = $"<div class='alert alert-danger'>{ex.Message}</div>";
            }
        }
    }
}