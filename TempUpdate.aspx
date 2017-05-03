<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Temp Update</title>

    
    <script language="CS" runat="server"> 
        StringBuilder sb;
        DataTable tb;
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (!Sitecore.Context.User.IsAdministrator)
            {
                Response.Redirect("/sitecore/login/default.aspx?sc_error=You do not have access to the Page.");
                return;
            }
        }

        protected void btnGetReport_Click(object sender, EventArgs e)
        {
             var strSelectQuery = "Update [dbo].[Users] Set BirthDate=NULL Where BirthDate=''";
        UpdateData(strSelectQuery);
        }

         protected void btnUserDetail_Click(object sender, EventArgs e)
        {
             var strSelectQuery = "Select UserId, [Email],  [BirthDate], [UserSource], [CreatedDate] From [dbo].[Users] Where BirthDate IS NOT NULL";
             gvUsers.DataSource = GetDataTable(strSelectQuery);
             gvUsers.DataBind();
             gvUsers.Visible = true;
        
        }

         protected void btnUserCountryDetail_Click(object sender, EventArgs e)
        {
             var strSelectQuery = "Select [Email], FirstName, LastName,  [Nationality], [Country] From [dbo].[Users]";
             gvUsers.DataSource = GetDataTable(strSelectQuery);
             gvUsers.DataBind();
             gvUsers.Visible = true;
        
        }
        

        public DataTable GetDataTable(string query)
        {
            String ConnString = ConfigurationManager.ConnectionStrings["external"].ConnectionString;
            SqlDataAdapter adapter = new SqlDataAdapter();
            DataTable genericTable = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                adapter.SelectCommand = new SqlCommand(query, conn);
                adapter.Fill(genericTable);
            }
            return genericTable;
        }

        public DataTable UpdateData(string query)
        {
             try
            {
                String ConnString = ConfigurationManager.ConnectionStrings["external"].ConnectionString;
                SqlDataAdapter adapter = new SqlDataAdapter();

                SqlCommand ocmd = new SqlCommand();
                DataTable genericTable = new DataTable();
                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    ocmd = new SqlCommand(query, conn);
                    conn.Open();
                    ocmd.ExecuteNonQuery();
                    conn.Close();
                    //adapter.Fill(genericTable);
                }
                return genericTable;
            }catch(Exception ex)
            {
                return null;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">

           <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
        </telerik:RadScriptManager>
        
                    <asp:Button ID="btnGetReport" Text="Update User" runat="server" OnClick="btnGetReport_Click" />

        <asp:Button ID="btnUserDetail" Text="Get Detail" runat="server" OnClick="btnUserDetail_Click" />

        <asp:Button ID="btnUserCountryDetail" Text="Get User Country Detail" runat="server" OnClick="btnUserCountryDetail_Click" />
        
         <div id="divSignupDetails" class="gridDiv">
            <div>
                <telerik:RadGrid ID="gvUsers" runat="server"
                    GridLines="Both" Skin="Metro"
                    Visible="false" Width="300px" CssClass="gridViewLayout" MasterTableView-Caption="User Signup Details for Dubai Calendar">

                    <ClientSettings>
                        <Resizing AllowColumnResize="false" AllowRowResize="false" ResizeGridOnColumnResize="false"
                            ClipCellContentOnResize="true" EnableRealTimeResize="false" AllowResizeToFit="true" ShowRowIndicatorColumn="true" />
                    </ClientSettings>
                    <ExportSettings HideStructureColumns="true" ExportOnlyData="true" FileName="UserSignups" Csv-ColumnDelimiter="comma"
                        Csv-RowDelimiter="NewLine"
                        Csv-EncloseDataWithQuotes="False">
                        <Pdf PageTitle="User Signup Details for Dubai Calendar" PaperSize="A4" DefaultFontFamily="Arial Unicode MS" />
                    </ExportSettings>
                    <MasterTableView Width="100%" CommandItemDisplay="Top">
                        <CommandItemSettings ShowExportToWordButton="false" ShowExportToCsvButton="true" ShowExportToExcelButton="true" ShowExportToPdfButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                    </MasterTableView>
                    <ClientSettings AllowDragToGroup="false" AllowColumnsReorder="false" ReorderColumnsOnClient="True">
                        <Scrolling AllowScroll="false" UseStaticHeaders="false" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
        </div>

    </form>
</body>
</html>
