//=====================================================================
//	Trend indicator.
//=====================================================================
//---------------------------------------------------------------------
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Trend indicator based on ADX indicator."
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
input int   PeriodADX=14;
input int   ADXTrendLevel=20;
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
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,PeriodADX*2);
   PlotIndexSetString(0,PLOT_LABEL,"ADXTrendDetector( "+(string)PeriodADX+" )");

//	Create external indicator handle for future reference to it:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ADX",PeriodADX);
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("ADX initialization error, Code = ",GetLastError());
      return(-1);   // return nonzero code - initialization was unsuccessful
     }

   return(0);
  }
//---------------------------------------------------------------------
//	Deinitialization event handler:
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
   int start,i;

//	If number of bars on the screen is less than ADX period, calculations can't be made:
   if(_rates_total<PeriodADX*2)
     {
      return(0);
     }

//	Determine the initial bar for indicator buffer calculation:
   if(_prev_calculated==0)
     {
      start=PeriodADX*2;
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
   int      trend_direction=0;
   double   ADXBuffer[1];
   double   PlusDIBuffer[1];
   double   MinusDIBuffer[1];

//	Copy ADX indicator values to buffers:
   CopyBuffer(indicator_handle,0,_shift,1,ADXBuffer);
   CopyBuffer(indicator_handle,1,_shift,1,PlusDIBuffer);
   CopyBuffer(indicator_handle,2,_shift,1,MinusDIBuffer);

//	If ADX value is considered (trend strength):
   if(ADXTrendLevel>0)
     {
      if(ADXBuffer[0]<ADXTrendLevel)
        {
         return(trend_direction);
        }
     }

//	Check +DI and -DI positions relative to each other:
   if(PlusDIBuffer[0]>MinusDIBuffer[0])
     {
      trend_direction=1;
     }
   else if(PlusDIBuffer[0]<MinusDIBuffer[0])
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+