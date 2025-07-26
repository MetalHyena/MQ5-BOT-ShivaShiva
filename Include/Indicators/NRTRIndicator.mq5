//+------------------------------------------------------------------+
//|                                            NRTRIndicator.mq5     |
//|                                        MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Support
#property indicator_label1  "Support"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  DodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Resistance
#property indicator_label2  "Resistance"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input int      period   =  40;   /*period*/  // ATR period in bars
input double   k        =  2.0;  /*k*/       // ATR change coefficient
//--- indicator buffers
double         SupportBuffer[];
double         ResistanceBuffer[];
double         Trend[];
double         ATRBuffer[];
int Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SupportBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_ARROW,159);

   SetIndexBuffer(1,ResistanceBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_ARROW,159);

   Handle=iATR(_Symbol,PERIOD_CURRENT,period);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[])
  {
   static bool error=true;
   int start;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      ArrayInitialize(Trend,0);
      ArrayInitialize(SupportBuffer,0);
      ArrayInitialize(ResistanceBuffer,0);
      start=period;
      error=false;
     }
   else
     {
      start=prev_calculated-1;
     }
   if(CopyBuffer(Handle,0,0,rates_total-start,ATRBuffer)==-1)
     {
      error=true;
      return(0);
     }
   for(int i=start;i<rates_total;i++)
     {
      Trend[i]=Trend[i-1];
      SupportBuffer[i]=SupportBuffer[i-1];
      ResistanceBuffer[i]=ResistanceBuffer[i-1];
      switch((int)Trend[i])
        {
         case 2:
            if(low[i]>SupportBuffer[i])
              {
               SupportBuffer[i]=close[i];
              }
            if(close[i]<SupportBuffer[i])
              {
               ResistanceBuffer[i]=close[i]+k*ATRBuffer[i];
               Trend[i]=3;
               SupportBuffer[i]=0;
              }
            break;
         case 3:
            if(high[i]<ResistanceBuffer[i])
              {
               ResistanceBuffer[i]=close[i];
              }
            if(close[i]>ResistanceBuffer[i])
              {
               SupportBuffer[i]=close[i]-k*ATRBuffer[i];
               Trend[i]=2;
               ResistanceBuffer[i]=0;
              }
            break;
         case 0:
            SupportBuffer[i]=close[i];
            ResistanceBuffer[i]=close[i];
            Trend[i]=1;
            break;
         case 1:
            if(low[i]>SupportBuffer[i])
              {
               SupportBuffer[i]=close[i];
               Trend[i]=2;
              }
            if(high[i]<ResistanceBuffer[i])
              {
               ResistanceBuffer[i]=close[i];
               Trend[i]=3;
              }
            break;
        }

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
