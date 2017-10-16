<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Xml.Xsl" %>
<%@ Import Namespace="NuGet.Server" %>
<%@ Import Namespace="NuGet.Server.Infrastructure" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    private const string PACKAGES_URI = "~/nuget/Packages";
    private const string XSLT_URL = "~/Packages.xslt";


    public string ToAbsolute(string relativeUrl)
    {
        // ReSharper disable once UseStringInterpolation
        return string.Format("http{0}://{1}{2}", Request.IsSecureConnection ? "s" : "", Request.Url.Authority, Page.ResolveUrl(relativeUrl));
    }


    public string GetPuckages()
    {
        try
        {
            var packageUrl = ToAbsolute(PACKAGES_URI);
            var xsltUrl = Server.MapPath(XSLT_URL);
            var xslt = new XslCompiledTransform();
            xslt.Load(xsltUrl);

            var request = WebRequest.Create(packageUrl);

            string html;
            using (var response = request.GetResponse())
            {
                var responseStream = response.GetResponseStream();
                // ReSharper disable once AssignNullToNotNullAttribute
                using (var streamReader = new StreamReader(responseStream))
                using (var reader = new XmlTextReader(streamReader))
                using (var writer = new StringWriter())
                {
                    xslt.Transform(reader, null, writer);
                    html = writer.ToString();
                }
            }

            return html;
        }
        catch (Exception)
        {
            return "";
        }
    }

    public string ServerTitle {  get { return ConfigurationManager.AppSettings["ServerTitle"]; } }
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title><%=ServerTitle %></title>
    <style type="text/css">
        body { font-family: Calibri; }
        #Packages li { margin-bottom: 5px; }
        #Packages li .description { display: block; font-weight: 100; }
        fieldset { border: 1px solid black; margin-bottom: 10px; }
        legend { position: relative; top: -1px; }
    </style>
</head>
<body>
    <div>
        <h1><%=ServerTitle %></h1>
        
        <fieldset id="Packages" style="width:800px">
            <legend><strong>Packages</strong></legend>
            <%= GetPuckages() %>
            <p>Click <a href="<%= VirtualPathUtility.ToAbsolute("~/nuget/Packages") %>">here</a> to view your packages.</p>
        </fieldset>

        <fieldset style="width:800px">
            <legend><strong>Repository URLs</strong></legend>
            In the package manager settings, add the following URL to the list of 
            Package Sources:
            <blockquote>
                <strong><%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %></strong>
            </blockquote>
            <% if (string.IsNullOrEmpty(ConfigurationManager.AppSettings["apiKey"])) { %>
            To enable pushing packages to this feed using the <a href="https://www.nuget.org/downloads">NuGet command line tool</a> (nuget.exe), set the api key appSetting in web.config.
            <% } else { %>
            Use the command below to push packages to this feed using the <a href="https://www.nuget.org/downloads">NuGet command line tool</a> (nuget.exe).
            <% } %>
            <blockquote>
                <strong>nuget.exe push {package file} {apikey} -Source <%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %></strong>
            </blockquote>            
        </fieldset>

        <% if (Request.IsLocal) { %>
        <fieldset style="width:800px">
            <legend><strong>Adding packages</strong></legend>

            To add packages to the feed put package files (.nupkg files) in the folder
            <code><% = PackageUtility.PackagePhysicalPath %></code><br/><br/>

            Click <a href="<%= VirtualPathUtility.ToAbsolute("~/nugetserver/api/clear-cache") %>">here</a> to clear the package cache.
        </fieldset>
        <% } %>
    </div>
</body>
</html>
