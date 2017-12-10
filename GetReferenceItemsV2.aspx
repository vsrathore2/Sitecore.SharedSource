<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="Sitecore.Data" %>
<%@ Import Namespace="Sitecore" %>
<%@ Import Namespace="Sitecore.Links" %>
<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="Sitecore.Globalization" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Get Reference Items</title>

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

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (Sitecore.Context.User.IsAuthenticated == false)
            {
                Response.Redirect("login.aspx?returnUrl=GetReferenceItemsv2.aspx");
            }
        }

        protected void getReferenceItems_Click(object sender, EventArgs e)
        {
            int i = 0;
            try
            {
                Database db = Database.GetDatabase("master");
                Item item = db.GetItem(txtID.Text);
                if (item != null)
                {
                    //This will return Standard Values as well!
                    var links = Globals.LinkDatabase.GetReferrers(item);
                    if (links != null)
                    {

                        StringBuilder sb = new StringBuilder();
                        sb.Append("<table><tr><th>Path</th><th>ID</th><th>Language</th><th>Field Name</th><th>Database</th></tr>");

                        foreach (var linkedItem in links)
                        {
                            sb.Append("<tr>");
                            string name = string.Empty;
                            var sourceItem = linkedItem.GetSourceItem();
                            if (sourceItem != null)
                            {
                                sb.Append("<td>" + sourceItem.Paths.FullPath + "</td>");
                                name = sourceItem.Name;
                            }
                            sb.Append("<td width=\"25%\">" + linkedItem.SourceItemID.ToString() + "</td>");
                            sb.Append("<td width=\"3%\">" + linkedItem.SourceItemLanguage.Name + "</td>");
                            sb.Append("<td>" + name + "</td>");
                            sb.Append("<td>" + linkedItem.SourceDatabaseName + "</td>");
                            sb.Append("</tr>");


                        }
                        sb.Append("</table>");

                        //lblMessage.Text += string.Join("<td>", itemLinksPath.ToArray());
                        //lblMessage.Text += "<br><br>ItemIDs:<br>";
                        //lblMessage.Text += string.Join("<br>", linkedItems.Select(ii => ii.ID.ToString()).ToArray());
                        lblMessage.Text = sb.ToString();
                        return;
                    }
                }
                //if (i == 0)
                //{
                //    lblMessage.Text = "Locked total " + i + " item(s)";
                //}
            }
            catch (Exception ex)
            {
                lblMessage.Text = ex.ToString();
            }
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Get Reference Items of an Item</h2>
        <table class="table-style-three">
            <tr>
                <td colspan="2" style="vertical-align: top">Give Me Item ID or Path:                   
                    <asp:TextBox ID="txtID" Width="400px" runat="server"></asp:TextBox>
                </td>
                <td>
                    <asp:Button ID="btnGetReferenceItems" runat="server" Text="Get Reference Items" OnClick="getReferenceItems_Click" />
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
