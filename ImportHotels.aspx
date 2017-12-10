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
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Import Hotels</title>
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
        public class Address
        {
            [JsonProperty("postcode")]
            public string Postcode { get; set; }

            [JsonProperty("street_address")]
            public string StreetAddress { get; set; }
        }
        public class Centroid
        {
            [JsonProperty("coordinates")]
            public List<double> Coordinates { get; set; }

            [JsonProperty("type")]
            public string Type { get; set; }
        }

        public class Name
        {
            [JsonProperty("en-US")]
            public string EnUS { get; set; }
        }

        public class Location
        {
            [JsonProperty("id")]
            public string FluffyId { get; set; }

            [JsonProperty("name")]
            public Name Name { get; set; }

            [JsonProperty("@id")]
            public string PurpleId { get; set; }

            [JsonProperty("@type")]
            public string Type { get; set; }
        }
        public class Image
        {
            [JsonProperty("full")]
            public string Full { get; set; }

            [JsonProperty("full_size")]
            public List<long> FullSize { get; set; }

            [JsonProperty("gallery")]
            public string Gallery { get; set; }

            [JsonProperty("provider")]
            public long Provider { get; set; }

            [JsonProperty("thumbnail")]
            public string Thumbnail { get; set; }
        }
        public class Hotel
        {
            [JsonProperty("address")]
            public Address Address { get; set; }

            [JsonProperty("centroid")]
            public Centroid Centroid { get; set; }

            [JsonProperty("country_code")]
            public string CountryCode { get; set; }

            [JsonProperty("description")]
            public string Description { get; set; }

            [JsonProperty("display_name_components")]
            public List<string> DisplayNameComponents { get; set; }

            [JsonProperty("distance")]
            public double Distance { get; set; }

            [JsonProperty("@id")]
            public string FluffyId { get; set; }

            [JsonProperty("images")]
            public List<Image> Images { get; set; }

            [JsonProperty("location")]
            public List<Location> Location { get; set; }

            [JsonProperty("name")]
            public Name Name { get; set; }

            [JsonProperty("native_languages")]
            public List<string> NativeLanguages { get; set; }

            [JsonProperty("id")]
            public string HotelId { get; set; }

            [JsonProperty("review_average_score")]
            public double ReviewAverageScore { get; set; }

            [JsonProperty("@type")]
            public string Type { get; set; }

            [JsonProperty("amenities")]
            public string[] Amenities { get; set; }

            [JsonProperty("stars")]
            public long Stars { get; set; }
        }

        public class RootObject
        {
            [JsonProperty("hotels")]
            public List<Hotel> Hotels { get; set; }
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (Sitecore.Context.User.IsAuthenticated == false)
            {
                Response.Redirect("login.aspx?returnUrl=importhotels.aspx");
            }
        }


        protected void btnImport_Click(object sender, EventArgs e)
        {
            var listItemIds = new List<string>();
            var dtResults = new System.Data.DataTable();
            StringBuilder sb = new StringBuilder();


            try
            {
                Database db = Database.GetDatabase("master");

                if (db != null)
                {
                    Item rootItem = db.GetItem(txtRootPath.Text);

                    if (rootItem != null)
                    {
                        dtResults = ImportHotels(rootItem, ref sb);
                        //dtResults = ImportHotels(ref sb);

                        gvResults.DataSource = dtResults;
                        gvResults.DataBind();

                    }
                }
            }
            catch (Exception ex)
            {
                sb.Append("Error");
                lblError.Text = ex.Message;
            }

            lblError.Text = sb.ToString();
        }

        public System.Data.DataTable ImportHotels(Item rootItem, ref StringBuilder sb)
        //public System.Data.DataTable ImportHotels(ref StringBuilder sb)
        {
            var dtResults = new System.Data.DataTable();
            TemplateItem Hotel_Template_Item = rootItem.Database.GetTemplate("{013FA0E4-02A3-493F-98BC-B737B6F9B403}");
            TemplateItem Supporting_Images_Folder_Template_Item = rootItem.Database.GetTemplate("{FF8E19FA-3579-4EA8-B1EE-40D7828668D0}");
            TemplateItem Supporting_Image_Item_Template_Item = rootItem.Database.GetTemplate("{EAC08D41-4012-40FE-BB66-8C465B0B85F7}");



            dtResults.Columns.Add("Hotel Name");
            dtResults.Columns.Add("Status");
            dtResults.Columns.Add("Images");
            //dtResults.Columns.Add("Item ID");
            //dtResults.Columns.Add("Old Media ID");
            //dtResults.Columns.Add("New Media ID");


            try
            {
                string spath = Server.MapPath("~/temp");
                string csv_file_path = spath + "\\" + flUpload.FileName;
                flUpload.SaveAs(csv_file_path);

                using (StreamReader r = new StreamReader(csv_file_path))
                {
                    string json = r.ReadToEnd();
                    var objHotelRoot = JsonConvert.DeserializeObject<RootObject>(json);

                    if (objHotelRoot != null && objHotelRoot.Hotels.Any())
                    {
                        sb.Append("Total Hotels " + objHotelRoot.Hotels.Count);

                        foreach (var objHotel in objHotelRoot.Hotels)
                        {
                            System.Data.DataRow itemRow = dtResults.NewRow();
                            if (objHotel != null && !string.IsNullOrEmpty(objHotel.HotelId) && objHotel.Name != null && !string.IsNullOrEmpty(objHotel.Name.EnUS))
                            {
                                bool isexistingHotel = CheckIfExist(rootItem, objHotel.HotelId);

                                if (isexistingHotel)
                                {
                                    itemRow["Status"] = "Item exist!";
                                }
                                else
                                {
                                    using (new Sitecore.SecurityModel.SecurityDisabler())
                                    {
                                        var validName = Sitecore.Data.Items.ItemUtil.ProposeValidItemName(objHotel.Name.EnUS);
                                        validName = validName.Replace(" ", "-");

                                        
                                        Item hotelItem = rootItem.Add(validName, Hotel_Template_Item);

                                        if (hotelItem != null)
                                        {
                                            //Begin Editing Sitecore Item
                                            hotelItem.Editing.BeginEdit();
                                            try
                                            {
                                                hotelItem["SkyScanner Hotel Id"] = objHotel.HotelId;
                                                hotelItem["Description"] = objHotel.Description;
                                                hotelItem["Hotel Name"] = hotelItem["Alt Name"] = hotelItem["Breadcrumb Title"] = objHotel.Name.EnUS;

                                                if (objHotel.Address != null)
                                                {
                                                    hotelItem["Hotel Address"] = objHotel.Address.StreetAddress + ", " + objHotel.Address.Postcode != null ? objHotel.Address.Postcode : "";
                                                }


                                                hotelItem["Geolocation"] = objHotel.Centroid.Coordinates[0] + "," + objHotel.Centroid.Coordinates[1];

                                                if (objHotel.Images.Any())
                                                {
                                                    foreach (var image in objHotel.Images.Take(1))
                                                    {
                                                        try
                                                        {

                                                            var image_id = string.Empty;
                                                            var arry_image_path = image.Full.Split('/');
                                                            image_id = arry_image_path[arry_image_path.Length - 2];
                                                            itemRow["Images"] = (itemRow["Images"] + "," + image_id).TrimStart(',');

                                                            var webRequest = System.Net.WebRequest.Create(image.Full);
                                                            using (var webResponse = webRequest.GetResponse())
                                                            {
                                                                using (var stream = webResponse.GetResponseStream())
                                                                {
                                                                    if (stream != null)
                                                                    {
                                                                        using (var memoryStream = new MemoryStream())
                                                                        {
                                                                            stream.CopyTo(memoryStream);

                                                                            var mediaCreator = new Sitecore.Resources.Media.MediaCreator();
                                                                            var options = new Sitecore.Resources.Media.MediaCreatorOptions
                                                                            {
                                                                                Versioned = false,
                                                                                IncludeExtensionInItemName = false,
                                                                                Database = rootItem.Database,
                                                                                Destination = "/sitecore/media library/New-Hotels/" + validName + "/" + image_id
                                                                            };

                                                                            var media = mediaCreator.CreateFromStream(memoryStream, image_id, options);
                                                                            sb.Append(media.ID.ToString());
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        catch (Exception ex)
                                                        {
                                                            sb.Append("ERROR" + ex.ToString());
                                                            itemRow["Status"] = "Error";
                                                        }
                                                    }
                                                }

                                                // This will commit the field value
                                                hotelItem.Editing.EndEdit();

                                                itemRow["Status"] = "Item Created!";


                                            }
                                            catch (Exception)
                                            {
                                                //Revert the Changes
                                                hotelItem.Editing.CancelEdit();
                                                itemRow["Status"] = "Error";
                                            }
                                        }
                                    }
                                }


                                itemRow["Hotel Name"] = objHotel.Name.EnUS;
                                dtResults.Rows.Add(itemRow);
                            }
                        }
                    }
                }

            }
            catch (Exception ex)
            {
                sb.Append("Error:" + ex.Message);
            }











            //int count = 0;
            //var childItems = rootItem.Children;

            //if (childItems.Any())
            //{
            //    foreach (Item child in childItems)
            //    {
            //        System.Data.DataRow itemRow = dtResults.NewRow();
            //        Sitecore.Data.Fields.ImageField imgFieldTileImage = child.Fields["Tile Image"];

            //        if (imgFieldTileImage != null && imgFieldTileImage.MediaItem == null)
            //        {
            //            itemRow["Item Path"] = child.Paths.Path;
            //            itemRow["Item ID"] = child.ID.ToString();
            //            itemRow["Old Media ID"] = imgFieldTileImage.MediaID.ToString();

            //            if (child.Children.Any())
            //            {
            //                var imagesFolder = child.Children.Where(i => i.Name == "Supporting Images").FirstOrDefault();

            //                if (imagesFolder != null && imagesFolder.Children.Any())
            //                {

            //                    var firstValidImageItem = imagesFolder.Children.Where(i => i.Fields["Image"] != null && ((Sitecore.Data.Fields.ImageField)i.Fields["Image"]) != null && ((Sitecore.Data.Fields.ImageField)i.Fields["Image"]).MediaItem != null).FirstOrDefault();
            //                    if (firstValidImageItem != null)
            //                    {
            //                        Sitecore.Data.Fields.ImageField img = firstValidImageItem.Fields["Image"];
            //                        //if (count <= 9)
            //                        {
            //                            //Begin Editing Sitecore Item
            //                            child.Editing.BeginEdit();
            //                            try
            //                            {
            //                                count++;
            //                                child["Tile Image"] = string.Format("<image mediaid=\"{0}\" />", img.MediaID.ToString());
            //                                // This will commit the field value
            //                                child.Editing.EndEdit();

            //                                itemRow["New Media ID"] = imgFieldTileImage.MediaID.ToString();

            //                            }
            //                            catch (Exception ex)
            //                            {
            //                                //Revert the Changes
            //                                child.Editing.CancelEdit();
            //                                itemRow["New Media ID"] = ex.Message;
            //                            }

            //                        }
            //                    }
            //                }
            //            }
            //            dtResults.Rows.Add(itemRow);
            //            //row++;
            //        }
            //    }
            //}
            return dtResults;
        }
        public bool CheckIfExist(Item rootItem, string hotelId)
        {
            bool isExist = false;
            var hotel = rootItem.Children.Where(i => i["SkyScanner Hotel Id"] == hotelId).FirstOrDefault();
            if (hotel != null)
            {
                isExist = true;
            }

            return isExist;
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Import Hotels - Visit Dubai</h2>
        <table class="table-style-three" style="width: 70%">
            <tr>
                <td>File:
                     <asp:FileUpload ID="flUpload" runat="server"></asp:FileUpload>
                </td>
                <td>Root Path:
                   <asp:TextBox ID="txtRootPath" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button ID="btnImport" runat="server" Text="Import Hotels" OnClick="btnImport_Click" /></td>
            </tr>
            <tr>
                <td colspan="2" class="red-bg">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:GridView ID="gvResults" CssClass="table-style-three" runat="server"></asp:GridView>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
