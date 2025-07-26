//+------------------------------------------------------------------+
//|                                             ZigZagIndicator.mq5  |
//|                                        MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Highs
#property indicator_label1  "Highs"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  DodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Lows
#property indicator_label2  "Lows"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input int      ExtDepth     = 5;
input int      ExtDeviation = 5;
input int      ExtBackstep  = 3;
//--- indicator buffers
double         ZigZagHighs[];
double         ZigZagLows[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagHighs,INDICATOR_DATA);
   SetIndexBuffer(1,ZigZagLows,INDICATOR_DATA);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start = prev_calculated > 0 ? prev_calculated - 1 : ExtDepth;
   
   for(int i = start; i < rates_total; i++)
     {
      // Reset the zigzag highs and lows
      ZigZagHighs[i] = 0;
      ZigZagLows[i] = 0;
     }
   
   // Calculate ZigZag
   int limit = rates_total - ExtDepth;
   
   for(int i = ExtDepth; i < limit; i++)
     {
      if (high[i] > high[i-ExtDepth] && high[i] > high[i+ExtDepth])
        {
         ZigZagHighs[i] = high[i];
        }
      if (low[i] < low[i-ExtDepth] && low[i] < low[i+ExtDepth])
        {
         ZigZagLows[i] = low[i];
        }
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
