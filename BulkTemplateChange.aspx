<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="Sitecore.Data" %>
<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="Sitecore.Collections" %>
<%@ Import Namespace="Sitecore.Data.Managers" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Sitecore.Data.Fields" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Event Copier</title>
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

            table.table-style-three tr:hover td {
                cursor: pointer;
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
            if (Sitecore.Context.User.IsAdministrator == false)
            {
                Response.Redirect("login.aspx?returnUrl=bulktemplatechange.aspx");
            }
        }

        protected void btnTemplateChange_Click(object sender, EventArgs e)
        {
            int i = 0;
            try
            {
                Database db = Database.GetDatabase("master");
                //Item parent = db.GetItem("/sitecore/content/Home/Meet-In-Dubai/Events");
                Item[] businessEvents = db.SelectItems("/sitecore/content/Home/#Meet-In-Dubai#/Events/*[@@TemplateId='{A66E7AF1-00E9-4D46-A212-F3C4F8A2057B}']");
                foreach (Item childItem in businessEvents)
                {
                    if (childItem.TemplateName == "Event")
                    {
                        Item newTemplateItem = db.GetTemplate("{445A18BD-E1D4-4327-B4E3-F5BA13CC78DE}");
                        childItem.Editing.BeginEdit();
                        childItem.ChangeTemplate(newTemplateItem);
                        childItem.Editing.EndEdit();

                        Response.Write(childItem.Paths.Path);
                        Response.Write("<br/>");
                        Response.Write(childItem.ID);
                        Response.Write("<br/>");

                        i++;

                        if (i >= Int32.Parse(txtCount.Text))
                            return;
                    }
                }

            }
            catch (Exception ex)
            {
                lblMsg.Text = ex.ToString();
            }

            lblMsg.Text = "Total " + i + " item template changed!";
        }



    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Copy Business Event Tool - Visit Dubai</h2>
        <h4>Use this tool to copy all business events to Meet In Dubai.</h4>
        <table>
            <tr>
                <td>
                    <asp:TextBox ID="txtCount" runat="server"></asp:TextBox>
                    <asp:Button ID="btnTemplateChange" runat="server" Text="Bulk Template Change" OnClick="btnTemplateChange_Click" /></td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblMsg" runat="server"></asp:Label></td>
            </tr>
        </table>
    </form>
</body>
</html>
