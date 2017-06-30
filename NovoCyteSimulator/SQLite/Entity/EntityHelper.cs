using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.SQLite.Entity
{
    public class EntityHelper
    {
        /// <summary>
        /// DataTable转List
        /// </summary>
        /// <param name="dt">要转换的Datatable</param>
        /// <param name="className">转换后的对象的类名</param>
        /// <returns>对象列表</returns>
        public static List<object> DataTableToList(DataTable dt, string className)
        {

            if (dt == null)
                return null;
            List<object> list = new List<object>();

            //遍历DataTable中所有的数据行
            foreach (DataRow dr in dt.Rows)
            {
                //类所在的namespace
                Type type = Type.GetType("NovoCyteSimulator.SQLite.Entity." + className);
                var t = Activator.CreateInstance(type);

                PropertyInfo[] propertys = t.GetType().GetProperties();
                foreach (PropertyInfo pro in propertys)
                {
                    //检查DataTable是否包含此列（列名==对象的属性名）  
                    if (dt.Columns.Contains(pro.Name))
                    {
                        object value = dr[pro.Name];

                        Type tmpType = Nullable.GetUnderlyingType(pro.PropertyType) ?? pro.PropertyType;
                        object safeValue = (value == null) ? null : Convert.ChangeType(value, tmpType);

                        //如果非空，则赋给对象的属性  PropertyInfo
                        if (safeValue != DBNull.Value)
                        {
                            pro.SetValue(t, safeValue, null);
                        }
                    }
                }
                //对象添加到泛型集合中
                list.Add(t);
            }
            return list;
        }
    }
}
