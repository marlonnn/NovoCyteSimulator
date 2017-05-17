using NovoCyteSimulator.DBClass;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NovoCyteSimulator.ExpClass
{
    public class ExpDoc
    {
        private DBOperate dbOp;

        public bool IsConnect
        {
            get
            {
                return dbOp != null && dbOp.IsOpen;
            }
        }

        public ExpDoc()
        {
            Init();
        }

        private void Init()
        {
            if (dbOp != null)
            {
                dbOp.Close(true);
            }
            dbOp = null;
        }

        private bool IsFileReadOnly(string path)
        {
            if (string.IsNullOrEmpty(path))
            {
                return false;
            }
            if (!ValidateDirectory(path, false) || !WriteAccess(path) || IsFileHasBeenOpened(path))
            {
                return true;
            }
            return false;
        }

        [DllImport("kernel32.dll", EntryPoint = "GetDriveTypeA")]
        public static extern int GetDriveType(string nDrive);
        // Drive Type:  
        // 0   DRIVE_UNKNOWN
        // 1   DRIVE_NO_ROOT_DIR    
        // 2   DRIVE_REMOVABLE     
        // 3   DRIVE_FIXED     
        // 4   DRIVE_REMOTE     
        // 5   DRIVE_CDROM     
        // 6   DRIVE_RAMDISK 

        public int GetRootType(string path)
        {
            string strRootPath = Path.GetPathRoot(path);
            int dt = GetDriveType(strRootPath);
            return dt;
        }
        private bool ValidateDirectory(string path, bool msg)
        {
            int dt = GetRootType(path);
            string strMsg = string.Empty;
            if (dt == 5) strMsg = "CD Rom";
            if (strMsg != string.Empty)
            {
                if (msg)
                {
                    strMsg = string.Format(Res.ExpDoc.FileOpenFromCD, strMsg);
                    MessageBox.Show(strMsg, Application.ProductName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                }

                return false;
            }

            return true;
        }

        private bool WriteAccess(string fileName)
        {
            try
            {
                if ((File.GetAttributes(fileName) & FileAttributes.ReadOnly) == FileAttributes.ReadOnly)
                    return false;

                FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.ReadWrite,
                FileShare.ReadWrite);
                fs.Close();
                return true;
            }
            catch (Exception)
            {
                return false;
            }

        }

        private bool IsFileHasBeenOpened(string path)
        {
            try
            {
                FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read,
                FileShare.None);
                fs.Close();
                return false;
            }
            catch (Exception)
            {
                return true;
            }
        }

        public virtual bool Load(string pathName, bool clone)
        {
            if (string.IsNullOrEmpty(pathName))
                return false;
            dbOp = DBOperate.CreateDBOperator(pathName);
            dbOp.ReadOnly = IsFileReadOnly(pathName);
            if (!dbOp.Connect(false))
            {
                return false;
            }
            else
            {
                return true;
            }
        }
    }
}
