using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace Promaneng_Company_Portal
{
    public class DatabaseHelper
    {
        /// <summary>
        /// Dynamically resolves the connection string based on the logged-in user's SQL role.
        /// </summary>
        public static string GetConnectionString()
        {
            string role = HttpContext.Current?.Session?["UserRole"]?.ToString() ?? "SystemAdmin";

            switch (role)
            {
                case "HR_Admin":
                    return ConfigurationManager.ConnectionStrings["Conn_HR_Admin"].ConnectionString;
                case "db_SiteManager":
                    return ConfigurationManager.ConnectionStrings["Conn_db_SiteManager"].ConnectionString;
                case "db_Accountant":
                    return ConfigurationManager.ConnectionStrings["Conn_db_Accountant"].ConnectionString;
                case "SystemAdmin":
                default:
                    return ConfigurationManager.ConnectionStrings["Conn_SystemAdmin"].ConnectionString;
            }
        }

        /// <summary>
        /// Executes SQL SELECT/UPDATE/INSERT queries or Views and returns results in a DataTable.
        /// </summary>
        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.CommandType = CommandType.Text;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        /// <summary>
        /// Executes Stored Procedures once (filling any result set AND populating OUTPUT parameters).
        /// </summary>
        public static DataTable ExecuteStoredProcedure(string spName, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(spName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt); // Executes the SP once, captures any SELECT output, and populates OUTPUT parameters
                        return dt;
                    }
                }
            }
        }
    }
}