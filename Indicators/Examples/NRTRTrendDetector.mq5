//=====================================================================
//	Trend indicator.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Trend indicator based on NRTR indicator."
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
input int      ATRPeriod = 40;  // ATR period, in bars
input double   Koeff = 2.0;     // Coefficient of ATR value change   
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
int         indicator_handle=0;
//---------------------------------------------------------------------
//	Initialization event handler:
//---------------------------------------------------------------------
int OnInit()
  {
//	Displayed indicator buffer:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ATRPeriod);
   PlotIndexSetString(0,PLOT_LABEL,"NRTRTrendDetector( "+(string)ATRPeriod+", "+(string)Koeff+" )");

//	Create external indicator handle for future reference to it:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\NRTR",ATRPeriod,Koeff);
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("NRTR initialization error, Code = ",GetLastError());
      return(-1);     // return nonzero code - initialization was unsuccessful
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Indicator deinitialization event handler:
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
//	Delete indicator handle:
   if(indicator_handle!=INVALID_HANDLE)
     {
      IndicatorRelease(indicator_handle);
     }
  }
//---------------------------------------------------------------------
//	Need for indicator recalculation event handler:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int   start,i;

//	If number of bars on the screen is less than ADX period, calculations can't be made:
   if(_rates_total<ATRPeriod)
     {
      return(0);
     }

//	Determine the initial bar for indicator buffer calculation:
   if(_prev_calculated==0)
     {
      start=ATRPeriod;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Loop of calculating the indicator buffer values:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(_rates_total-i-1);
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
int TrendDetector(int _shift)
  {
   int    trend_direction=0;
   double Support[1];
   double Resistance[1];

//	Copy NRTR indicator values to buffers:
   CopyBuffer(indicator_handle,0,_shift,1,Support);
   CopyBuffer(indicator_handle,1,_shift,1,Resistance);

//	Check values of indicator lines:
   if(Support[0]>0.0 && Resistance[0]==0.0)
     {
      trend_direction=1;
     }
   else if(Resistance[0]>0.0 && Support[0]==0.0)
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+