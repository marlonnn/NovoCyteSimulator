using System;
using System.Data.OleDb;
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.IO;
using System.Linq;

/*
1.   数据库操作类一览
我的数据库操作类一共有如下几种：

类                          名称                   描述
 
SqlDBOperate            SQL-Server数据库操作类     执行SQL-Server的数据库操作。 
OracleDBOperate         Oracle数据库操作类         执行Oracle的数据库操作。 
OleDBOperate            OleDb数据库操作类          通过OleDb执行数据库操作。 
ODBCDBOperate           ODBC数据库操作类           通过ODBC执行数据库的操作。
 
2.   如何使用数据库操作类
SqlDBOperate oper = new SqlDBOperate(“…”);
String sql = “…”;
oper. ExecuteNonQuery(sql); 
或
DataTable dt = oper.ExecuteDataTable(sql);

3.   数据库操作类的实现   
 * 
 * 现在做一个项目，之前的是Sqlserver版的，现在需要改成Oracle版的，之前也没怎么用过vs+oracle，做的时候挺没方向的，现在遇到一个小问题，

    如果用sqlserver数据库，传参时我们一般用：

string sql ="select * from [tb] where ID=@id";

SqlParameter pid = new SqlParameter("@id", SqlDbType.Char, 10);
pid.Value = TextBox1.text.ToString();

cmd.Parameters.Add(pid);

 

    如果使用oracle数据库，再用以上方法就无法得到值，应使用以下方法：

string sql ="select * from [tb] where ID=:id";    //将@id换成:id,

OracleParameter pid= new OracleParameter("id",OracleDbType.VarChar,10); //参数的@去掉

pid.Value = TextBox1.text.ToString();

cmd.Parameters.Add(pid);

或者连起来写：

Parameters.Add("id", OracleDbType.VarChar, 10).Value = TextBox1.text.ToString();

 * 
 * */

namespace NovoCyteSimulator.DBClass
{
    internal class OleDBOperate : DBOperate
    {
        private string[] Passwords = { "NovoExpressDaTa",
                                       "Dipv4Ojv3",
                                       "Zjo4Iv4",
                                       "Nbp4Uv5",
                                       "Difo3Mpoh3",
                                       "Tj5Tif3",
                                       "Xv4Nb4",
                                       "Xfj5Zboh3",
                                       "Tifo2Ipv3",
                                       "Zpv4Kj2",
                                       "Yv2Hpv4",
                                       "Ibj5Aiv2",
                                       "Aj4Tiv4" ,
                                       "NovoExpressDaTa"
                                      };


        // 在构造方法中创建数据库连接
        public OleDBOperate(string pathName)
        {
            PathName = pathName;
            ReadOnly = false;
        }

        // 创建适配器
        public override DbDataAdapter CreateDataAdapter(string sql)
        {
            return new OleDbDataAdapter(sql, (OleDbConnection)conn);
        }

        public override bool Connect(bool exclusive)
        {
            if (string.IsNullOrEmpty(PathName))
            {
                return false;
            }

            string providerString;
            if (!exclusive)
            {
                if (!ReadOnly)
                {
                    if (IntPtr.Size == 4)
                        providerString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\"{0}\";Jet OLEDB:Database password=\"{1}\";";
                    else
                        providerString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=\"{0}\";Jet OLEDB:Database password=\"{1}\";";
                }
                else
                {
                    if (IntPtr.Size == 4)
                        providerString = "Provider=Microsoft.Jet.OLEDB.4.0;Mode=Read;Data Source=\"{0}\";Jet OLEDB:Database password=\"{1}\";";
                    else
                        providerString = "Provider=Microsoft.ACE.OLEDB.12.0;Mode=Read;Data Source=\"{0}\";Jet OLEDB:Database password=\"{1}\";";
                }

            }
            else
            {
                if (IntPtr.Size == 4)
                    providerString = "Provider=Microsoft.Jet.OLEDB.4.0;Mode=Share Exclusive;Data Source=\"{0}\";Jet OLEDB:Database password=\"{1}\";";
                else
                    providerString = "Provider=Microsoft.ACE.OLEDB.12.0;Mode=Share Exclusive;Data Source=\"{0}\";Jet OLEDB:Database password=\"{1}\";";
            }

            foreach (var password in GetPwds(PathName))
            {
                string connString = string.Format(providerString, PathName, password);

                if (this.conn != null)  // make sure old connection object is closed and disposed
                {
                    Close(true);
                }
                this.conn = new OleDbConnection(connString);
                if (this.Open())
                {
                    Password = password;
                    return true;
                }
            }

            return false;
        }

        private IEnumerable<string> GetPwds(string fileName)
        {
            string password = GetPwd(fileName);

            yield return password;

            for (int i = -3; i < Passwords.Length; i++)
            {
                if (i < -1)
                {
                    password = Passwords[0];
                }
                else if (i == -1)
                {
                    password = "";
                }
                else
                {
                    password = Passwords[i];
                }

                yield return password;
            }
        }


        private string GetPwd(string fileName)
        {
            string strPwd = string.Empty;

            byte[] ps = { 0xa1, 0xec, 0x7a, 0x9c, 0xe1, 0x28, 0x34, 0x8a, 0x73, 0x7b, 0xd2, 0xdf, 0x50 };

            var bt = new byte[26];
            var flag = new byte[1];
            var sz = new char[13];

            const byte const1 = 0x13;

            using (var file = new FileStream(fileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                file.Seek(66, SeekOrigin.Begin);
                file.Read(bt, 0, 26);
                file.Seek(0x62, SeekOrigin.Begin);
                file.Read(flag, 0, 1);
                int j = 0;
                for (int i = 0; i < 13; i++)
                {
                    if (i % 2 == 0)
                    {
                        sz[j] = (char)(const1 ^ flag[0] ^ bt[i * 2] ^ ps[i]);
                    }
                    else
                    {
                        sz[j] = (char)(bt[j * 2] ^ ps[i]);
                    }

                    j++;
                }
            }

            if (sz[1] < 0x20 || sz[1] > 0x7E) return strPwd;

            for (int i = 0; i < sz.Count(); i++)
            {
                if (sz[i].Equals('\0')) break;

                strPwd += sz[i];
            }

            // this function only decrypt password less than 14 chars, Passwords[0] has 15 chars
            if (!string.IsNullOrEmpty(strPwd) && Passwords[0].StartsWith(strPwd)) strPwd = Passwords[0];

            return strPwd;
        }

        //         private string BuildPassword()
        //         {
        //             int seconds = DateTime.Now.Second;
        //             return Passwords[seconds % (Passwords.Length - 1)];
        //         }
        // 
        //         public bool SetPassword()
        //         {
        //             if (this.conn != null && this.IsOpen)
        //             {
        //                 this.Close();
        //             }
        //             if (!this.Connect(true))
        //             {
        //                 return false;
        //             }
        //             
        //             string newPassword = BuildPassword();
        //             this.TryExecuteNonQuery("ALTER Database Password [" + newPassword + "] [" + Password + "]", null);
        //             Password = newPassword;
        //             this.Close();
        //             return true;
        //         }
        //         

        public override IDbDataParameter CreateDbDataParameter(string paraName, OleDbType dataType, int size)
        {
            return new OleDbParameter(paraName, dataType, size);
        }

        public override IDbDataParameter CreateDbDataParameter(string paraName, OleDbType dataType)
        {
            return new OleDbParameter(paraName, dataType);
        }

        /// <summary>
        /// quote for date time in sql where
        /// </summary>
        public override char Quote
        {
            get
            {
                return '#';
            }
        }
        public override void TryExecuteCompressSQLite(string PathName)
        {
        }

    }
}
