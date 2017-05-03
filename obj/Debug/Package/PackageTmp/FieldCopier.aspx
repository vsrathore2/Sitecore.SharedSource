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
    <title>Bulk Item Field Copier Tool</title>

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
        Database db;
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            string DB = drpDB.SelectedItem.Value;
            db = Database.GetDatabase(DB);
            if (Sitecore.Context.User.IsAdministrator == false)
            {
                Response.Redirect("login.aspx?returnUrl=FieldCopier.aspx");
            }
        }

        protected void btnCopy_Click(object sender, EventArgs e)
        {
            try
            {
                string parentNode = txtPath.Text;
                foreach (ListItem lang in chkLang.Items)
                {
                    if (lang.Selected)
                    {
                        Language lng = Sitecore.Globalization.Language.Parse(lang.Value);
                        var parentItem = db.GetItem(parentNode, lng);
                        foreach (Item child in parentItem.Children)
                        {
                            if (child.TemplateName == txtTemplate.Text)
                            {
                                child.Editing.BeginEdit();
                                child[txtDestinationField.Text] = child[txtSourceField.Text];
                                child.Editing.EndEdit();
                            }
                        }
                    }
                }

                lblMsg.Text = "Copy Finished.";
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error: " + ex.ToString();

            }

        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Bulk Item Field Copier Tool</h2>
        <table class="table-style-three">
            <tr>
                <td>Database:<asp:DropDownList ID="drpDB" runat="server">
                    <asp:ListItem Text="Master" Value="master"></asp:ListItem>
                </asp:DropDownList></td>
                <td colspan="3" style="vertical-align: top">Parent Item Path:<asp:TextBox ID="txtPath" runat="server" Width="70%"></asp:TextBox></td>
            </tr>
            <tr>
                <td style="vertical-align: top">Template Name:<asp:TextBox ID="txtTemplate" runat="server"></asp:TextBox></td>
                <td style="vertical-align: top">Source Field Name:<asp:TextBox ID="txtSourceField" runat="server"></asp:TextBox></td>
                <td style="vertical-align: top">Traget Field Name:<asp:TextBox ID="txtDestinationField" runat="server"></asp:TextBox></td>
                <td>
                    <table>
                        <tr>
                            <td style="vertical-align: top">Language
                                <asp:CheckBoxList ID="chkLang" runat="server">
                                    <asp:ListItem Value="en">English</asp:ListItem>
                                    <asp:ListItem Value="ar">Arabic</asp:ListItem>
                                    <asp:ListItem Value="az">Azeri</asp:ListItem>
                                    <asp:ListItem Value="cs">Czech</asp:ListItem>
                                    <asp:ListItem Value="de">German</asp:ListItem>
                                    <asp:ListItem Value="es">Spanish</asp:ListItem>
                                    <asp:ListItem Value="fr">French</asp:ListItem>
                                    <asp:ListItem Value="id">Indonesian</asp:ListItem>
                                    <asp:ListItem Value="it">Italian</asp:ListItem>
                                    <asp:ListItem Value="ja">Japanese</asp:ListItem>
                                    <asp:ListItem Value="ko">Korean</asp:ListItem>
                                    <asp:ListItem Value="nl">Dutch</asp:ListItem>
                                    <asp:ListItem Value="pl">Polish</asp:ListItem>
                                    <asp:ListItem Value="pt">Portuguese</asp:ListItem>
                                    <asp:ListItem Value="ru">Russian</asp:ListItem>
                                    <asp:ListItem Value="sv">Swedish</asp:ListItem>
                                    <asp:ListItem Value="uk">Ukrainian</asp:ListItem>
                                    <asp:ListItem Value="zh-CN">Chinese (Simplyfied)</asp:ListItem>
                                    <asp:ListItem Value="hk">Cantonese (Chinsese)</asp:ListItem>
                                </asp:CheckBoxList>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="4">
                    <asp:Button ID="btnCopy" runat="server" Text="Copy" OnClick="btnCopy_Click" /></td>
            </tr>
            <tr>
                <td colspan="4">
                    <asp:Label ID="lblMsg" runat="server"></asp:Label>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>