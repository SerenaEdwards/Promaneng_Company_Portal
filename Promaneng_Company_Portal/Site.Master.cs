using System;
using System.Web.UI;

namespace Promaneng_Company_Portal
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string userName = Session["UserName"]?.ToString() ?? "Staff";
                string userRole = Session["UserRole"].ToString();
                lblUserDetails.Text = $"{userName} ({userRole})";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}