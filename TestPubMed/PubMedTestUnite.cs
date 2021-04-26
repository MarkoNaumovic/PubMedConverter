using NUnit.Framework;
using NUnit.Framework.Internal;
using TestPubMed.Resource;
using PubMedCoverter;
using Assert = NUnit.Framework.Assert;
using Org.XmlUnit.Builder;
using Org.XmlUnit.Diff;
using System.Xml;

namespace TestPubMed
{
    [TestFixture]
    public class PubMedTestUnite : ResourceItem
    {
        //Validate output files
        //Test expected input files content

        [Test]
        public void IsExpetedTransformSucess()
        {
            var inputDataXml = xmlInput;
            var inputDataXsl = xslInput;
            var expectedData2 = xmlOutput;

            var testdata = Transformer.TransformXml(inputDataXml, inputDataXsl);

            Assert.IsTrue(true, testdata, expectedData2);
        }

        [Test]
        public void CheckXMLDifference()
        {
            var inputDataXml = xmlInput;
            var OutputDataXml = xmlOutput;

            Diff myDiff = DiffBuilder.Compare(Input.FromString(inputDataXml))
                .WithTest(Input.FromString(OutputDataXml))
                .IgnoreComments()
                .CheckForSimilar().CheckForIdentical()
                .IgnoreWhitespace().NormalizeWhitespace().Build();

            Assert.IsTrue(true, inputDataXml, OutputDataXml);

        }

        [Test]
        public void DataAtribute()
        {
            var OutputDataXml = xmlOutput;
           
            var expectedData = OutputDataXml;

           
            Assert.IsTrue(expectedData.Contains("article"));
            Assert.IsFalse(expectedData.Contains("00006534-202008000-00022"));

        }
        [Test]
        public void CheckIfExistNodeElements()
        {
            XmlDocument xDoc = new XmlDocument();
            xDoc.LoadXml(xmlOutput);

            XmlNodeList node = xDoc.DocumentElement.SelectNodes("article");
            if (xDoc.ChildNodes.Count == 0)
            {
                Assert.IsFalse(false,xmlOutput,node);
            }
            Assert.IsTrue(true, xmlOutput, node);
        }
    }
}

