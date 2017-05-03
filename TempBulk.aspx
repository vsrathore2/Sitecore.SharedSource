<%@ Page Language="C#" AutoEventWireup="true" Debug="true" %>

<%@ Import Namespace="Sitecore.Data" %>
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

 <script language="CS" runat="server"> 

     protected override void OnLoad(EventArgs e)
     {
         base.OnLoad(e);
         if (Sitecore.Context.User.IsAdministrator == false)
         {
             Response.Redirect("login.aspx?returnUrl=bulkdelete.aspx");
         }
     }

     protected void btnDelete_Click(object sender, EventArgs e)
     {
         int count = 0;
         StringBuilder sb = new StringBuilder();
         bool isSubitem = false;

         try
         {


             Sitecore.Links.UrlOptions options = new Sitecore.Links.UrlOptions();
             options.LanguageEmbedding = Sitecore.Links.LanguageEmbedding.Never;

             sb.Append("Item Summary:").Append("<br/>");
             string[] s = txtIDs.Text.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

             string DB = drpDB.SelectedItem.Value;
             Database db = Database.GetDatabase(DB);
             sb.Append("<table>");
             sb.Append("<tr>");
             sb.Append("<th>Item ID</th>");
             sb.Append("<th>Item Path</th>");
             sb.Append("<th>Item URL</th>");
             sb.Append("</tr>");
             foreach (string ii in s)
             {
                 Item i = db.GetItem(ii);

                 sb.Append("<tr>");
                 sb.Append("<td>"+i.ID.ToString()+"</td>");
                 sb.Append("<td>"+i.Paths.FullPath+"</td>");
                 var itemURL = ("https://www.visitdubai.com" + Sitecore.Links.LinkManager.GetItemUrl(i, options).Replace("/sitecore/admin/sitecore/content/home", "")).Replace("/visiting_new","");
                 var anchorTag = "<a href='" + itemURL + "'>" + itemURL + "</a>";
                 sb.Append("<td>"+ anchorTag +"</td>");

                 sb.Append("</tr>");

                 count++;
             }
             sb.Append("</table>");
         }
         catch (Exception ex)
         {
             lblError.Text = ex.ToString();
         }
         lblError.Text = sb.ToString();
     }

    </script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Temp Bulk Tool</title>

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
   
</head>
<body>
    <form id="form1" runat="server">
        <h2>Bulk Delete Tool</h2>
        <table class="table-style-three">
            <tr>
                <td style="width: 20%">Delete:<asp:DropDownList ID="drpIsSubItem" runat="server">
                    <asp:ListItem Text="Without SubItem" Value="0"></asp:ListItem>
                    <asp:ListItem Text="With SubItem" Value="1"></asp:ListItem>
                </asp:DropDownList></td>

                <td>Database:<asp:DropDownList ID="drpDB" runat="server">
                    <asp:ListItem Text="Master" Value="master"></asp:ListItem>
                    <asp:ListItem Text="Stage" Value="stage"></asp:ListItem>
                    <asp:ListItem Text="Web" Value="web"></asp:ListItem>
                </asp:DropDownList></td>
            </tr>
            <tr>
                <td colspan="2" style="vertical-align: top">
                    <asp:TextBox ID="txtIDs" TextMode="MultiLine" Rows="50" runat="server" Height="400px" Width="98%"></asp:TextBox></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClick="btnDelete_Click" /></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
