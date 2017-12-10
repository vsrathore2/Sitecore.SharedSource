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
    <title>Update Hotels</title>
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
                Response.Redirect("login.aspx?returnUrl=getfieldvalue.aspx");
            }
        }


        protected void btnPublish_Click(object sender, EventArgs e)
        {
            var listItemIds = new List<string>();
            var tb = new System.Data.DataTable();
            StringBuilder sb = new StringBuilder();


            try
            {
                Database db = Database.GetDatabase(drpDB.SelectedItem.Value);

                if (db != null)
                {
                    Item rootItem = db.GetItem(txtRootPath.Text);

                    if (rootItem != null)
                    {
                        if (ddlAction.SelectedItem != null && !string.IsNullOrEmpty(ddlAction.SelectedValue))
                        {

                            switch (ddlAction.SelectedValue)
                            {
                                case "0":
                                    {
                                        tb = UpdateTileImages(rootItem, ref sb);
                                        break;
                                    }
                                case "1":
                                case "2":
                                    {
                                        tb = UpdateHotels(db, ref sb);
                                        break;
                                    }
                                case "3":
                                    {
                                       
                                        tb = RenameHotels(rootItem, ref sb);
                                        break;
                                    }

                                default:
                                    break;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                sb.Append("Error");
                lblError.Text = ex.Message;
            }


            grdLanguageReport.DataSource = tb;
            grdLanguageReport.DataBind();

            lblError.Text = sb.ToString();
        }

        public System.Data.DataTable UpdateTileImages(Item rootItem, ref StringBuilder sb)
        {
            var tb = new System.Data.DataTable();
            tb.Columns.Add("Item Path");
            tb.Columns.Add("Item ID");
            tb.Columns.Add("Old Media ID");
            tb.Columns.Add("New Media ID");

            int count = 0;
            var childItems = rootItem.Children;

            if (childItems.Any())
            {
                foreach (Item child in childItems)
                {
                    System.Data.DataRow itemRow = tb.NewRow();
                    Sitecore.Data.Fields.ImageField imgFieldTileImage = child.Fields["Tile Image"];

                    if (imgFieldTileImage != null && imgFieldTileImage.MediaItem == null)
                    {
                        itemRow["Item Path"] = child.Paths.Path;
                        itemRow["Item ID"] = child.ID.ToString();
                        itemRow["Old Media ID"] = imgFieldTileImage.MediaID.ToString();

                        if (child.Children.Any())
                        {
                            var imagesFolder = child.Children.Where(i => i.Name == "Supporting Images").FirstOrDefault();

                            if (imagesFolder != null && imagesFolder.Children.Any())
                            {

                                var firstValidImageItem = imagesFolder.Children.Where(i => i.Fields["Image"] != null && ((Sitecore.Data.Fields.ImageField)i.Fields["Image"]) != null && ((Sitecore.Data.Fields.ImageField)i.Fields["Image"]).MediaItem != null).FirstOrDefault();
                                if (firstValidImageItem != null)
                                {
                                    Sitecore.Data.Fields.ImageField img = firstValidImageItem.Fields["Image"];
                                    //if (count <= 9)
                                    {
                                        //Begin Editing Sitecore Item
                                        child.Editing.BeginEdit();
                                        try
                                        {
                                            count++;
                                            child["Tile Image"] = string.Format("<image mediaid=\"{0}\" />", img.MediaID.ToString());
                                            // This will commit the field value
                                            child.Editing.EndEdit();

                                            itemRow["New Media ID"] = imgFieldTileImage.MediaID.ToString();

                                        }
                                        catch (Exception ex)
                                        {
                                            //Revert the Changes
                                            child.Editing.CancelEdit();
                                            itemRow["New Media ID"] = ex.Message;
                                        }

                                    }
                                }
                            }
                        }
                        tb.Rows.Add(itemRow);
                        //row++;
                    }
                }
            }
            return tb;
        }

        public System.Data.DataTable UpdateHotels(Database db, ref StringBuilder sb)
        {
            var tb = new System.Data.DataTable();
            tb.Columns.Add("Item Path");
            tb.Columns.Add("Item ID");
            tb.Columns.Add("Status");
            int count = 0;
            string[] strArray = txtIDs.Text.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string valueSet in strArray)
            {

                System.Data.DataRow itemRow = tb.NewRow();

                Item item = db.GetItem(valueSet);


                if (item == null)
                {
                    sb.Append(String.Format("Item not found with ID {0}<br />", valueSet));
                    continue;
                }

                itemRow["Item ID"] = item.ID.ToString();
                itemRow["Item Path"] = item.Paths.FullPath;

                try
                {
                    using (new Sitecore.SecurityModel.SecurityDisabler())
                    {
                        if (Sitecore.Configuration.Settings.RecycleBinActive)
                        {
                            item.Recycle();
                            itemRow["Status"] = "Done";
                        }
                        else
                        {
                            item.Delete();
                            itemRow["Status"] = "Done";
                        }

                    }

                }
                catch (Exception)
                {
                    //Revert the Changes
                    //item.Editing.CancelEdit();
                    itemRow["Status"] = "Error";
                }

                tb.Rows.Add(itemRow);


            }

            return tb;
        }

        public System.Data.DataTable RenameHotels(Item rootItem, ref StringBuilder sb)
        {
          
            var tb = new System.Data.DataTable();
            tb.Columns.Add("Item Path");
            tb.Columns.Add("Item ID");
            tb.Columns.Add("Status");
            

            var childItems = rootItem.Children;

            if (childItems.Any())
            {
                foreach (Item child in childItems.Take(5))
                {
                    System.Data.DataRow itemRow = tb.NewRow();
                    itemRow["Item Path"] = child.Paths.Path;
                    itemRow["Item ID"] = child.ID.ToString();
                    //Begin Editing Sitecore Item
                    child.Editing.BeginEdit();
                    try
                    {
                        string name = child.Name;

                        child.Name = name.Replace(" ", "-");
                        // This will commit the field value
                        child.Editing.EndEdit();

                        itemRow["Status"] = "Done";


                    }
                    catch (Exception)
                    {
                        //Revert the Changes
                        child.Editing.CancelEdit();
                        itemRow["Status"] = "Error";
                    }


                    tb.Rows.Add(itemRow);
                   
                    //row++;
                }
            }

            return tb;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Update Values - Visit Dubai</h2>
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
                <td>Root Path:
                     <asp:TextBox ID="txtRootPath" runat="server"></asp:TextBox>
                </td>
                Action
                  <td style="vertical-align: top">
                      <asp:DropDownList ID="ddlAction" runat="server" Visible="true">
                          <asp:ListItem Value="Select">Select An Action</asp:ListItem>
                          <asp:ListItem Value="0">Update Tile Image</asp:ListItem>
                          <asp:ListItem Value="1">Enable Hotels</asp:ListItem>
                          <asp:ListItem Value="2">Disable Hotels</asp:ListItem>
                          <asp:ListItem Value="3">Rename Hotels</asp:ListItem>
                      </asp:DropDownList>
                  </td>
            </tr>

            <tr>

                <td style="vertical-align: top" colspan="2">
                    <asp:TextBox ID="txtIDs" TextMode="MultiLine" Rows="50" runat="server" Width="99%" Visible="true"></asp:TextBox></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button ID="btnPublish" runat="server" Text="Update Values" OnClick="btnPublish_Click" /></td>
            </tr>
            <tr>
                <td colspan="2" class="red-bg">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </td>

            </tr>
            <tr>
                <td>
                    <asp:GridView ID="grdLanguageReport" CssClass="table-style-three" runat="server"></asp:GridView>
                </td>
            </tr>
        </table>

    </form>
</body>
</html>
