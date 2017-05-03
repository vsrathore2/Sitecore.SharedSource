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
<%@ Import Namespace="Sitecore.Collections" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Sitecore.Data.Managers" %>
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script language="CS" runat="server"> 
        StringBuilder sb;
        DataTable tb;
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (Sitecore.Context.User.IsAuthenticated == false)
            {
                Response.Redirect("login.aspx?returnUrl=LanguageReport.aspx");
            }
        }
        protected void btnGetReport_Click(object sender, EventArgs e)
        {
            try
            {
                string path = txtPath.Text;
                Database db = Database.GetDatabase(txtDatabase.Text);
                Item parent = db.GetItem(path);
                int globalCounter = 0;
                int onlyPageCounter = 0;
                //tb = new DataTable();
                LanguageCollection languages = LanguageManager.GetLanguages(db);
                List<CultureInfo> cultureInfos = new List<CultureInfo>();
                //tb.Columns.Add("Item ID");
                //tb.Columns.Add("Item Path");
                //foreach (Language language in languages)
                //{
                //    tb.Columns.Add(language.Name);
                //}

                foreach (Item childItem in parent.Axes.GetDescendants())
                {
                    if (childItem.Fields["__Renderings"].ToString() != string.Empty)
                    {
                        //DataRow itemRow = tb.NewRow();
                        //itemRow[0] = childItem.ID;
                        //itemRow[1] = childItem.Paths.Path;
                        onlyPageCounter = onlyPageCounter + 1;
                        foreach (var itemLanguage in childItem.Languages)
                        {
                            var item = db.GetItem(childItem.ID, itemLanguage);
                            if (item.Versions.Count > 0)
                            {
                                globalCounter = globalCounter + 1;
                                //if (tb.Columns[itemLanguage.Name] != null)
                                //    itemRow[tb.Columns[itemLanguage.Name]] = "1";                            
                            }
                        }
                    }
                }

                lblCount.Text = "Only page count: " + onlyPageCounter + " Total items: " + globalCounter;
                //grdLanguageReport.DataSource = tb;
                //grdLanguageReport.DataBind();                
            }
            catch (Exception ex)
            {
                lblCount.Text = ex.ToString();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <table>
            <tr>
                <td>Provide Parent Item Path:<asp:TextBox ID="txtPath" Width="700px" runat="server"></asp:TextBox></td>
                <td>Provide Database:<asp:TextBox ID="txtDatabase" Width="50px" runat="server"></asp:TextBox></td>
                <td>
                    <asp:Button ID="btnGetReport" runat="server" Text="Get Language Report" OnClick="btnGetReport_Click" /></td>                
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblCount" runat="server"></asp:Label></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td colspan="3">
                    <asp:GridView ID="grdLanguageReport" CssClass="table-style-three" runat="server"></asp:GridView>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
