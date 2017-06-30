﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.SQLite
{
    public class SQLiteTable
    {
        public string TableName = "";
        public SQLiteColumnList Columns = new SQLiteColumnList();

        public SQLiteTable()
        { }

        public SQLiteTable(string name)
        {
            TableName = name;
        }
    }
}
