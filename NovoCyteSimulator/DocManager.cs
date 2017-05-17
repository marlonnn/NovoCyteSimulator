using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NovoCyteSimulator
{
    public class DocManager
    {
        private string fileDlgFilter;

        private string _ncfFilePath;
        /// <summary>
        /// gets or sets the open and save ncf file path, could only be a sub path of DefaultNcfFilePath
        /// </summary>
        public string NcfFilePath
        {
            get { return _ncfFilePath; }
            set
            {
                if (value.ToLower().StartsWith(DefaultNcfFilePath.ToLower()))
                    _ncfFilePath = value;
            }
        }

        /// <summary>
        /// a combine of DefaultDataFolder and "Experiments"
        /// </summary>
        public string DefaultNcfFilePath
        {
            get { return Path.Combine(DefaultDataFolder, "Experiments"); }
        }

        private string _defaultDataFolder;
        /// <summary>
        /// gets or sets user data root folder
        /// </summary>
        public string DefaultDataFolder
        {
            get { return _defaultDataFolder; }
            set
            {
                if (_defaultDataFolder == value) return;
                _defaultDataFolder = value;
            }
        }

        private Form frmOwner;

        public bool OpenDocument()
        {
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = fileDlgFilter;
            openFileDialog1.InitialDirectory = NcfFilePath;

            DialogResult res = openFileDialog1.ShowDialog(frmOwner);
            if (res != DialogResult.OK)
                return false;
            string fileName = openFileDialog1.FileName;
            openFileDialog1.Dispose();

            using (Stream stream = null)
            {

            }
            return true;
        }

        /// <summary>
        /// Helper function - test if string is empty
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        static bool Empty(string s)
        {
            return s == null || s.Length == 0;
        }
    }
}
