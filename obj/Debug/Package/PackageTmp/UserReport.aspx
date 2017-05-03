<%@ Page Language="C#" AutoEventWireup="true"%>

<%@ Import Namespace="Sitecore.Globalization" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="Sitecore.Data" %>
<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Sitecore.Security.Domains" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="Sitecore.Collections" %>
<%@ Import Namespace="Sitecore.Security.Accounts" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Sitecore.Data.Fields" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Report</title>

    <style>
        body {
            font-family: verdana, arial, sans-serif;
        }

        table.table-style-three {
            font-family: verdana, arial, sans-serif;
            font-size: 11px;
            color: #333333;
            border-width: 1px;
            border-color: #3A3A3A;
            border-collapse: collapse;
        }

            table.table-style-three th {
                border-width: 1px;
                padding: 8px;
                border-style: solid;
                border-color: #FFA6A6;
                background-color: #D56A6A;
                color: #ffffff;
            }

            table.table-style-three tr:nth-child(even) td {
                background-color: #F7CFCF;
            }

            table.table-style-three td {
                border-width: 1px;
                padding: 8px;
                border-style: solid;
                border-color: #FFA6A6;
                background-color: #ffffff;
            }
    </style>
    <script language="CS" runat="server"> 
        StringBuilder sb;
        DataTable tb;
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (Sitecore.Context.User.IsAuthenticated == false)
            {
                Response.Redirect("login.aspx?returnUrl=UserReport.aspx");
            }
        }

        protected void btnGetReport_Click(object sender, EventArgs e)
        {
            try
            {
                tb = new DataTable();
                tb.Columns.Add("Name");
                tb.Columns.Add("Full Name");
                tb.Columns.Add("Is Admin");
                tb.Columns.Add("Is Active");
                tb.Columns.Add("Email");
                int rowNumber = 0;
                IEnumerable<User> allUsers = Domain.GetDomain("sitecore").GetUsers().OrderByDescending(x=>x.IsAdministrator==true);
                foreach (User user in allUsers)
                {
                    rowNumber++;
                    DataRow itemRow = tb.NewRow();
                    itemRow["Name"] = user.Name;
                    itemRow["Full Name"] = user.Profile.FullName;
                    itemRow["Is Admin"] = user.IsAdministrator;
                    itemRow["Is Active"] = user.Profile.State;
                    itemRow["Email"] = user.Profile.Email;                    
                    tb.Rows.Add(itemRow);                    
                }


                lblCount.Text = "Total users: " + tb.Rows.Count.ToString();
                grdLanguageReport.DataSource = tb;
                grdLanguageReport.DataBind();
                Session.Add("Data", tb);
            }
            catch (Exception ex)
            {
                lblCount.Text = ex.ToString();
            }
        }

        protected void ExportToExcel(object sender, EventArgs e)
        {
            string attachment = "attachment; filename=Report.xls";
            Response.ClearContent();
            Response.AddHeader("content-disposition", attachment);
            Response.ContentType = "application/vnd.ms-excel";
            string tab = "";
            tb = (DataTable)Session["Data"];
            foreach (DataColumn dc in tb.Columns)
            {
                Response.Write(tab + dc.ColumnName);
                tab = "\t";
            }
            Response.Write("\n");
            int i;
            foreach (DataRow dr in tb.Rows)
            {
                tab = "";
                for (i = 0; i < tb.Columns.Count; i++)
                {
                    Response.Write(tab + dr[i].ToString());
                    tab = "\t";
                }
                Response.Write("\n");
            }
            Response.End();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>User Report - Visit Dubai</h2>
        <table>
            <tr>
                <td>
                    <asp:Button ID="btnGetReport" Text="Get Users" runat="server" OnClick="btnGetReport_Click" />
                    <asp:Button ID="btnDownload" runat="server" Text="Download Report" OnClick="ExportToExcel" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblCount" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td colspan="4">
                    <asp:GridView ID="grdLanguageReport" CssClass="table-style-three" runat="server"></asp:GridView>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
