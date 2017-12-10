<%@ Page Language="C#" AutoEventWireup="true" %>

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

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Move Multiple Items</title>
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

        .red-bg {
            background-color: #F7CFCF !important;
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
                Response.Redirect("login.aspx?returnUrl=movemultipleitems.aspx");
            }
        }


        protected void btnMoveItems_Click(object sender, EventArgs e)
        {

            var listItemIds = new List<string>();
            var tb = new System.Data.DataTable();
            tb.Columns.Add("ID");
            tb.Columns.Add("Path");
            StringBuilder sb = new StringBuilder();
            try
            {
                Database db = Database.GetDatabase(drpDB.SelectedItem.Value);

                if (db != null)
                {
                    string[] strArray = txtIDs.Text.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

                    var row = 0;
                    Item destinationContainer = db.GetItem(txtDestination.Text);
                    if (destinationContainer != null)
                    {
                        foreach (string strItemId in strArray)
                        {


                            System.Data.DataRow itemRow = tb.NewRow();

                            Item item = db.GetItem(strItemId);

                            if (item == null)
                            {
                                continue;
                            }

                            try
                            {
                                Sitecore.Buckets.Managers.BucketManager.MoveItemIntoBucket(item, destinationContainer);


                                itemRow["ID"] = item.ID.ToString();
                                itemRow["Path"] = item.Paths.Path.ToString();
                                tb.Rows.Add(itemRow);
                                row++;
                            }
                            catch (Exception ex)
                            {
                                sb.Append("Error " + ex.Message + " in moving item with ID " + item.ID.ToString() + "<br />");
                            }
                        }

                        sb.Append("Total items moved " + row);
                    }
                }

                grdReport.DataSource = tb;
                grdReport.DataBind();

            }

            catch (Exception ex)
            {
                sb.Append("Error" + ex.Message + "<br />");
            }

            lblError.Text = sb.ToString();

            //lblError.Text = sb.ToString();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Move Multiple Items - Visit Dubai</h2>
        <table class="table-style-three" style="width: 70%">
            <tr>
                <%-- <td style="width: 22%">Update Datasource:<asp:DropDownList ID="drpIsSubItem" runat="server">
                    <asp:ListItem Text="Without SubItem" Value="0"></asp:ListItem>
                    <asp:ListItem Text="With SubItem" Value="1"></asp:ListItem>
                </asp:DropDownList></td>--%>
                <td>Database:<asp:DropDownList ID="drpDB" runat="server">
                    <asp:ListItem Text="Master" Value="master"></asp:ListItem>
                    <asp:ListItem Text="Stage" Value="stage"></asp:ListItem>
                    <asp:ListItem Text="Web" Value="web"></asp:ListItem>
                    <asp:ListItem Text="HKG" Value="hkg"></asp:ListItem>
                </asp:DropDownList></td>
                <td>Destination Root Item:
                    <asp:TextBox ID="txtDestination" runat="server"></asp:TextBox>
                </td>
            </tr>

            <tr>

                <td style="vertical-align: top" colspan="2">
                    <asp:TextBox ID="txtIDs" TextMode="MultiLine" Rows="50" runat="server" Width="99%"></asp:TextBox></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button ID="btnMoveItems" runat="server" Text="Move Items" OnClick="btnMoveItems_Click" /></td>
            </tr>
            <tr>
                <td colspan="2" class="red-bg">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </td>

            </tr>
            <tr>
                <td>
                    <asp:GridView ID="grdReport" CssClass="table-style-three" runat="server"></asp:GridView>
                </td>
            </tr>
        </table>

    </form>
</body>
</html>
