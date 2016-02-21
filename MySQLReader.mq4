#property version "1.0"
#property copyright "Copyright ? 2015, Quantrade Corp."
#property link      "http: //www.talaikis.com"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 clrGray

#include <MQLMySQL.mqh>

extern string _tablename = "CBOE_EVZ";
extern int    field      = 1;
extern string host       = "localhost";
extern int    port       = 3306;
extern string user       = "root";
extern string password   = "Hg#1F8h^=GP5@4v0u9";
extern string dbName     = "lean";

double Buf_0[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
//---- indicators

    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);

    SetIndexBuffer(0, Buf_0);

    //IndicatorSetDouble(INDICATOR_MINIMUM,-4);
    //IndicatorSetDouble(INDICATOR_MAXIMUM, 4);

//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
    int maxReq = 1000; //Bars-300;

    if (Refresh(1440) == TRUE)
    {
        int    DB;
        string Query;
        int    Cursor, Rows;

        //connect to database
        DB = MySqlConnect(host, user, password, dbName, port, 0, CLIENT_MULTI_STATEMENTS);

        if (DB == -1)
        {
            Print("Connection to <a href="http://www.talaikis.com/mysql/">MySQL</a> database failed! Error: " + MySqlErrorDescription);
        }
        else
        {
            Print("Connected to <a href="http://www.talaikis.com/mysql/">MySQL</a>! DB_ID#", DB);
        }

        for (int i = (Bars - 1); i >= 0; i--)
        {
            string yD = StringSubstr(TimeToStr(Time[i], TIME_DATE | TIME_SECONDS), 0, 4);
            string mD = StringSubstr(TimeToStr(Time[i], TIME_DATE | TIME_SECONDS), 5, 2);
            string dD = StringSubstr(TimeToStr(Time[i], TIME_DATE | TIME_SECONDS), 8, 2);

            string qTime = yD + "-" + mD + "-" + dD;

            //query
            Query = "SELECT * FROM `" + _tablename + "` WHERE DATE(DATE_TIME) = '" + qTime + "'";
            Print("SQL> ", Query);
            Cursor = MySqlCursorOpen(DB, Query);

            if (Cursor >= 0)
            {
                Rows = MySqlCursorRows(Cursor);
                Print(Rows, " row(s) selected.");
                if (Rows > 0)
                {
                    for (int s = 0; s < Rows; s++)
                    {
                        if (MySqlCursorFetchRow(Cursor))
                        {
                            Buf_0[i] = MySqlGetFieldAsDoubleDD(Cursor, field);
                        }
                    }
                }
                else
                {
                    Buf_0[i] = Buf_0[i + 1];
                }
                MySqlCursorClose(Cursor); // NEVER FORGET TO CLOSE CURSOR !!!
            }
            else
            {
                Print("Cursor opening failed. Error: ", MySqlErrorDescription);
                MySqlCursorClose(Cursor); // NEVER FORGET TO CLOSE CURSOR !!!
            }
        }
    } //close of refresh() check of file data


//----
    return(0);
}
//+------------------------------------------------------------------+

//update base only once a bar
bool Refresh(int _per)
{
    static datetime PrevBar;
    //Print("Refresh times. PrevBar: "+PrevBar);

    if (PrevBar != iTime(NULL, _per, 0))
    {
        PrevBar = iTime(NULL, _per, 0);
        return(true);
    }
    else
    {
        return(false);
    }
}