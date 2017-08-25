using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator
{
    public static class ExtensionMethods
    {
        /// <summary>
        /// deserialize from a bytes array
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public static T Deserialize<T>(byte[] bytes) where T : class
        {
            IFormatter formatter = new BinaryFormatter();

            using (MemoryStream stream = new MemoryStream(bytes))
            {
                try
                {
                    return (T)formatter.Deserialize(stream);
                }
                catch (System.Exception)
                {

                }
            }
            return null;
        }
    }
}
