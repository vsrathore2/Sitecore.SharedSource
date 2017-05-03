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

        if (!Page.IsPostBack)
        {
            foreach (var language in db.GetLanguages())
            {
                chkLang.Items.Add(new ListItem(language.GetDisplayName(), language.Name));
                rdbLang.Items.Add(new ListItem(language.GetDisplayName(), language.Name));
            }
        }
    }

    private void copyFields(Item rootItem)
    {
        foreach (Item child in rootItem.Children)
        {

            var srcLangItem = db.GetItem(child.ID, srcLang);

            if (child.Versions.Count > 0)
            {
                child.Editing.BeginEdit();
                foreach (var fieldName in lstFieldList)
                {
                    child[fieldName] = srcLangItem[fieldName];
                }

                child.Editing.EndEdit();
            }

            if (child.Children.Count > 0)
            {
                copyFields(child);
            }
        }
    }

    List<string> lstFieldList = new List<string>();

    Language srcLang;

    protected void btnCopy_Click(object sender, EventArgs e)
    {
        try
        {
            string parentNode = txtPath.Text;

            srcLang = Sitecore.Globalization.Language.Parse(rdbLang.SelectedValue);

            if (!string.IsNullOrEmpty(txtSourceField.Text))
                lstFieldList = txtSourceField.Text.Split(',').ToList();

            lblMsg.Text += lstFieldList.Count.ToString() + "- <br/>";

            foreach (ListItem lang in chkLang.Items)
            {
                if (lang.Selected)
                {
                    Language lng = Sitecore.Globalization.Language.Parse(lang.Value);

                    var parentItem = db.GetItem(parentNode, lng);
                    var srcLangItem = db.GetItem(parentNode, srcLang);

                    parentItem.Editing.BeginEdit();
                    foreach (var fieldName in lstFieldList)
                    {
                        parentItem[fieldName] = srcLangItem[fieldName];
                    }
                    parentItem.Editing.EndEdit();


                    if (chkSubitems.Checked && parentItem.Children.Count > 0)
                    {
                        copyFields(parentItem);
                    }


                    //foreach (Item child in parentItem.Children)
                    //{
                    //    //if (child.TemplateName == txtTemplate.Text)
                    //    //{
                    //    //    child.Editing.BeginEdit();
                    //    //    child[txtDestinationField.Text] = child[txtSourceField.Text];
                    //    //    child.Editing.EndEdit();
                    //    //}
                    //}
                }
            }

            lblMsg.Text += "Copy Finished.";
        }
        catch (Exception ex)
        {
            lblMsg.Text += "Error: " + ex.ToString();

        }

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Item Field Language Copier Tool</title>

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
        <h2>Item Field Language Copier Tool</h2>
        <table class="table-style-three">
            <tr>
                <td>Database:<asp:DropDownList ID="drpDB" runat="server">
                    <asp:ListItem Text="Master" Value="master"></asp:ListItem>
                </asp:DropDownList></td>
                <td colspan="2" style="vertical-align: top">Parent Item Path:
                    <asp:TextBox ID="txtPath" runat="server" Width="500" Text="/sitecore/content"></asp:TextBox></td>
                <td colspan="2">
                    <asp:CheckBox ID="chkSubitems" runat="server" Text="Sub-items?" />
                </td>

            </tr>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td style="vertical-align: top">Source Language
                                <asp:RadioButtonList ID="rdbLang" runat="server">
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                    </table>
                </td>
                <td colspan="2" style="vertical-align: top">
                    <table style="border: none;">
                        <tr>
                            <td style="border: none; vertical-align: middle">Field Name(s) [comma separated]: </td>
                            <td style="border: none; vertical-align: top">
                                <asp:TextBox ID="txtSourceField" runat="server" Width="250" TextMode="MultiLine" Rows="4"></asp:TextBox></td>
                        </tr>
                    </table>
                </td>
                <td colspan="2">
                    <table>
                        <tr>
                            <td style="vertical-align: top">Destination Languages
                                <asp:CheckBoxList ID="chkLang" runat="server">
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
