//=====================================================================
//	Trend indicator.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Trend indicator based on Heiken Ashi indicator"
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price	PRICE_CLOSE
#property indicator_minimum				-1.4
#property indicator_maximum				+1.4
//---------------------------------------------------------------------
#property indicator_buffers 	1
#property indicator_plots   	1
//---------------------------------------------------------------------
#property indicator_type1   	DRAW_HISTOGRAM
#property indicator_color1  	Black
#property indicator_width1		2
//---------------------------------------------------------------------
//	External parameters:
//---------------------------------------------------------------------
//	Missing
//---------------------------------------------------------------------
double  TrendBuffer[];
//---------------------------------------------------------------------
//	Initialization event handler:
//---------------------------------------------------------------------
int OnInit()
  {
//	Displayed indicator buffer:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,1);
   PlotIndexSetString(0,PLOT_LABEL,"HeikenAshiTrendDetector");

   return(0);
  }
//---------------------------------------------------------------------
//	Need for indicator recalculation event handler:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int      start,i;
   double   open,close,ha_open,ha_close;

//	Determine the initial bar for indicator buffer calculation:
   if(_prev_calculated==0)
     {
      open=Open[0];
      close = Close[ 0 ];
      start = 1;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Loop of calculating the indicator buffer values:
   for(i=start; i<_rates_total; i++)
     {
      //	Heiken Ashi candlestick open price:
      ha_open=(open+close)/2.0;

      //	Heiken Ashi candlestick close price:
      ha_close=(Open[i]+High[i]+Low[i]+Close[i])/4.0;

      TrendBuffer[i]=TrendDetector(ha_open,ha_close);

      open=ha_open;
      close=ha_close;
     }

   return(_rates_total);
  }
//---------------------------------------------------------------------
//	Determine the current trend direction:
//---------------------------------------------------------------------
//	Returns:
//		-1 - Down trend
//		+1 - Up trend
//		 0 - trend is not defined
//---------------------------------------------------------------------
int TrendDetector(double _open,double _close)
  {
   int trend_direction=0;

   if(_close>_open) // if candlestick is growing, then it is the up trend
     {
      trend_direction=1;
     }
   else if(_close<_open) // if candlestick is falling, then it is the down trend
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+
