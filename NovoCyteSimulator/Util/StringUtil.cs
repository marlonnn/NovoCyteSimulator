using System.Collections.Generic;
using System.Text;

namespace NovoCyteSimulator.Util
{
    public class StringUtil
    {
        private static Dictionary<byte, string> Template = null;
        static StringUtil()
        {
            Template = new Dictionary<byte, string>();
            for (int i = byte.MinValue; i <= byte.MaxValue; i++)
            {
                Template.Add((byte)i, string.Format("{0:X2} ", (byte)i));
            }
        }
        public static string Byte2ReadableXstring(byte[] bytes)
        {
            StringBuilder msg = new StringBuilder("0x ", bytes.Length * 3 + 3);
            foreach (byte b in bytes)
            {
                msg.Append(Template[b]);
            }
            return msg.ToString();
        }
    }
}
