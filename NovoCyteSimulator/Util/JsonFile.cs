using Newtonsoft.Json;
using NovoCyteSimulator.Equipment;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Util
{
    public class JsonFile
    {
        /// <summary>
        /// 解析JSON字符串生成对象实体
        /// </summary>
        /// <param name="jsonText"></param>
        /// <returns></returns>
        public static NovoCyteConfig GetNovoCyteConfigFromJsonText(string jsonText)
        {
            NovoCyteConfig novoCyteConfig = JsonConvert.DeserializeObject<NovoCyteConfig>(jsonText);
            return novoCyteConfig;
        }

        /// <summary>
        /// 将对象序列化为JSON格式
        /// </summary>
        /// <param name="novoCyteConfig"></param>
        /// <returns></returns>
        public static string GetJsonTextFromNovoCyteConfig(NovoCyteConfig novoCyteConfig)
        {
            JsonSerializer serializer = new JsonSerializer();
            StringWriter textWriter = new StringWriter();
            JsonTextWriter jsonWriter = new JsonTextWriter(textWriter)
            {
                Formatting = Formatting.Indented,
                Indentation = 4,
                IndentChar = ' '
            };
            serializer.Serialize(jsonWriter, novoCyteConfig);

            return textWriter.ToString();
        }
    }
}
