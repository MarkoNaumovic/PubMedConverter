
using com.sun.mail.imap.protocol;
using sun.tools.tree;
using System.IO;

namespace TestPubMed.Resource
{
    public class ResourceItem
    {      
       public static string xmlInput =File.ReadAllText("D:/VisualStudioProjects/PubMedCoverter/TestPubMed/Resource/Test_asset_00006.xml");
       public static string xslInput = File.ReadAllText("D:/VisualStudioProjects/PubMedCoverter/TestPubMed/Resource/assetToPubmedXml.xsl");
       public static string xmlOutput =File.ReadAllText("D:/VisualStudioProjects/PubMedCoverter/TestPubMed/Resource/TestOutput.xml");

    }
}
