using System;
using System.IO;
using System.Text;
using System.Xml;
using Saxon.Api;

namespace PubMedCoverter
{

    public class Transformer
    {
        
        public static void Main(string[] args)
        {
           
            var xmlData = File.ReadAllText("Resource/InputFolder/asset_00006.xml");
            var xslData = File.ReadAllText("Resource/InputFolder/assetToPubmedXml.xsl");

            XmlDocument document = new XmlDocument();
            document.LoadXml(xmlData);
            if (document.DocumentElement.InnerXml.Contains("asset/[@oftype='article']")) ;
            {
               var data = TransformXml(xmlData, xslData);
               Console.WriteLine(data);
            }
            return;
        }

        public static string TransformXml(string xmlData, string xslData)
        {
            // Create a Processor instance.
            Processor xsltProcessor = new Processor();

            //Load the source document xml
            var documentBuilder = xsltProcessor.NewDocumentBuilder();
            documentBuilder.BaseUri = new Uri("file://");
            var xdmNode = documentBuilder.Build(new StringReader(xmlData));


            var xsltCompiler = xsltProcessor.NewXsltCompiler();
            var xsltExecutable = xsltCompiler.Compile(new StringReader(xslData));
            var xsltTransformer = xsltExecutable.Load();
            xsltTransformer.InitialContextNode = xdmNode;


            XQueryCompiler compiler = xsltProcessor.NewXQueryCompiler();
            XQueryExecutable exp = compiler.Compile("/");
            XQueryEvaluator eval = exp.Load();
            eval.ContextItem = xdmNode;

            string path = "Assets/OutPutXml/MyTest" + Guid.NewGuid()  + ".xml";

            try
            {
                // Create the file, or overwrite if the file exists.
                using (FileStream fs = File.Create(path))
                {
                    byte[] info = new UTF8Encoding(true).GetBytes(xdmNode.OuterXml);
                    // Add information to the file.
                    fs.Write(info, 0, info.Length);
                }

                // Open the stream and read it back.
                using (StreamReader sr = File.OpenText(path))
                {
                    string s = "";
                    while ((s = sr.ReadLine()) != null)
                    {
                        Console.WriteLine(s);
                    }
                }
            }

            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

            //  // Show the result
            return xdmNode.OuterXml;


        }

     

    }


}
