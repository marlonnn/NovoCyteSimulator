using System.Collections.Generic;
using System.Text;

namespace NovoCyteSimulator.Util
{
    public class StringUtil
    {
        private static Dictionary<byte, string> Template = null;

        private static Dictionary<string, byte> Template2 = null;

        static StringUtil()
        {
            Template = new Dictionary<byte, string>();
            Template2 = new Dictionary<string, byte>();
            for (int i = byte.MinValue; i <= byte.MaxValue; i++)
            {
                Template.Add((byte)i, string.Format("{0:X2} ", (byte)i));
                Template2.Add(string.Format("{0:X2} ", (byte)i), (byte)i);
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

        public static byte String2Byte(string str)
        {
            return Template2[str];
        }

    }
}
