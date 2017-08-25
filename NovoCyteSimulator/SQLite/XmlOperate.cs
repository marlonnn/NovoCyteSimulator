using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.IO;
using System.Windows.Forms;

namespace NovoCyteSimulator.SQLite
{
    class XmlOperate
    {
        public static void InitConfigFile()
        {
            string filePath = Application.StartupPath + "\\config.xml";
            if (File.Exists(filePath))
            {
                bool edit = false;
                XmlDocument xmlDoc;
                XmlNode xn;
                XmlElement xe;

                xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath);
                #region
                //xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("HeightLine");
                //if (xn == null)
                //{
                //    edit = true;
                //    xe = xmlDoc.CreateElement("HeightLine");
                //    xe.InnerText = "0";
                //    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                //    xmlDoc.Save(filePath);
                //}
                //else
                //{
                //    xe = (XmlElement)xn;
                //    gLine.Text = xe.InnerText;
                //}
                //xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("BottonLine");
                //if (xn == null)
                //{
                //    edit = true;
                //    xe = xmlDoc.CreateElement("BottonLine");
                //    xe.InnerText = "0";
                //    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                //}
                //else
                //{
                //    xe = (XmlElement)xn;
                //    dLine.Text = xe.InnerText;
                //}
                //xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("heightV");
                //if (xn == null)
                //{
                //    edit = true;
                //    xe = xmlDoc.CreateElement("heightV");
                //    xe.InnerText = "0";
                //    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                //}
                //else
                //{
                //    xe = (XmlElement)xn;
                //    gValue.Text = xe.InnerText;
                //    heightV = Convert.ToInt32(gValue.Text);
                //}
                //xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("lowV");
                //if (xn == null)
                //{
                //    edit = true;
                //    xe = xmlDoc.CreateElement("lowV");
                //    xe.InnerText = "0";
                //    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                //}
                //else
                //{
                //    xe = (XmlElement)xn;
                //    dValue.Text = xe.InnerText;
                //    lowV = Convert.ToInt32(dValue.Text);
                //}
                #endregion
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("DataSavePath");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("DataSavePath");
                    xe.InnerText  = Application.StartupPath;                   
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("AS");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("AS");
                    xe.InnerText = "1";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("PS");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("PS");
                    xe.InnerText = "50";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("AN");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("AN");
                    xe.InnerText = "64";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("PN");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("PN");
                    xe.InnerText = "2048";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("IsSavePSW");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("IsSavePSW");
                    xe.InnerText = "ture";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }

                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("PSW");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("PSW");
                    xe.InnerText = "123456";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    //txtPath.Text = xe.InnerText;
                    //dataSavePath = xe.InnerText;
                }

                #region
                //xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("DataSaveTime");
                //if (xn == null)
                //{
                //    edit = true;
                //    xe = xmlDoc.CreateElement("DataSaveTime");
                //    xe.InnerText = dataSaveTime.ToString();
                //    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                //}
                //else
                //{
                //    xe = (XmlElement)xn;
                //    nupdTime.Value = Convert.ToInt32(xe.InnerText);
                //    dataSaveTime = Convert.ToInt32(xe.InnerText);
                //}
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode("DataSaveFlag");
                if (xn == null)
                {
                    edit = true;
                    xe = xmlDoc.CreateElement("DataSaveFlag");
                    xe.InnerText = "1";
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                }
                #endregion
                if (edit)
                {
                    xmlDoc.Save(filePath);
                }
            }
            else
            {
                FileStream fs = new FileStream(filePath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
                fs.Seek(0, SeekOrigin.End);
                byte[] conntent = ASCIIEncoding.ASCII.GetBytes("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<System>\n</System>");
                fs.Write(conntent, 0, conntent.Length);
                fs.Close();
            }
        }

        public static string GetXML(string nodeName)
        {
            try
            {
                string filePath = Application.StartupPath + "\\config.xml";
                XmlDocument xmlDoc;
                XmlNode xn;
                XmlElement xe;

                xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath);
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode(nodeName);

                if (xn == null)
                {
                    return Application.StartupPath;
                }
                else
                {
                    xe = (XmlElement)xn;
                    return xe.InnerText;
                }
               // xmlDoc.Save(filePath);
            }
            catch
            {
                return Application.StartupPath;
            }
        }

        public static void SaveXML(string nodeName, string nodeValue)
        {
            try
            {
                string filePath = Application.StartupPath + "\\config.xml";
                XmlDocument xmlDoc;
                XmlNode xn;
                XmlElement xe;

                xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath);
                xn = xmlDoc.SelectSingleNode("System").SelectSingleNode(nodeName);

                if (xn == null)
                {
                    xe = xmlDoc.CreateElement(nodeName);
                    xe.InnerText = nodeValue;
                    xmlDoc.SelectSingleNode("System").AppendChild(xe);
                }
                else
                {
                    xe = (XmlElement)xn;
                    xe.InnerText = nodeValue;
                }
                xmlDoc.Save(filePath);
            }
            catch
            {
            }
        }
    }
}
