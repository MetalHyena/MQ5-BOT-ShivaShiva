//     Jai Ganesha!
//
//     History Log
//     Version   Date          Change
//     V1        Jul  25 2025  Shiva Emerges from Tridevi 26 GROK version
//
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Tools\DateTime.mqh>
#include <indicators\MovingAverages.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+



input string   DemoMode = "N";                                    // Set to 'Y' for fast trigger testing in demo
input double   LotSize = 0.02;                                    // Lot size for trading
input double   buyThreshold = 4.0;                                 // Buy threshold
input double   sellThreshold = 4.0;                                // Sell threshold
input double   oppositeThreshold = 1.5;                              // Opposite threshold*

input string   WolfProtectFlag = "Y";                             // Activate WolfProtect Y or N
// Production:

input double   WolfStopPrice = 4.0;                               // Trail Amount (in dollars) to set stop loss below/above current price
input double   WolfPositivePrice = 6.0;                           // Wolf Positive
input double   WolfNegativePrice = 6.0;                           // Wolf Negative
input double   WolfBreakEven = 6.0;                               // Wolf Breakeven


 //Testing:
 /*
input double   WolfStopPrice = 1.0;                               // Trail Amount (in dollars) to set stop loss below/above current price
input double   WolfPositivePrice = 1.0;                           // Wolf Positive
input double   WolfNegativePrice = 1.0;                           // Wolf Negative
input double   WolfBreakEven = 1.0;                               // Wolf Breakeven
*/

input double   WolfPartial = 0.5;                                 // Wolf Partial Percentage
input bool     WolfTrailAfterBreakEven = true;                    // Trail After BreakEven
input bool     WolfTrailAfterNegative = false;                     // Trail After Negative
input bool     RevWolfProtect = false;                             // TrendReverseProtect





input bool     MoneyDriven = true;                                 // Money $ Driven
input double   SL_Money = 30.0;                                    // Stop Loss $
input double   TP_Money = 80.0;                                   //  Take Profit $
input double   TrailingStepMoney = 3.0;                          // Trailing Step $
input double   TrailingStartMoney = 6.0;                         // Trailing Start $
input double   BreakEvenTriggerMoney = 6.0;                       // BreakEven Trigger $

input bool     ATRDriven = false;                                  // ATR Driven
input double   SL_ATRMultiplier = 2.0;                                // Multiplier for Stop Loss calculation
input double   TP_ATRMultiplier = 10.0;                               // Multiplier for Take Profit calculation
input int      ATRPeriod = 14;                                     // ATR period for volatility measurement

input double   threshold = 5.0;                                   // ADX threshold

input string   TrendFollowMethod = "C";                           // "O" for overall trend, "C" for current trend
input int      TimeFrameLevelsUp = 2;                             // Level UP Timegframes
input double   MaxAllowedDrawdown = 10.0;                         // Max Drawdown %
input int      MaxToleranceContinuousLoss = 5;                    // Continous Loss Tolerance
input string   TradeWithTrendFlag = "N";                          // Trading with the trend ('Y' or 'N')

input int      adxPeriod = 14;                                    //ADX Period
input int      CoolOffCandleSeconds = 300;                          // Cool off period in seconds after placing a trade
input int      DriverLevelTimeChart = -2;                          // Timeframe adjustment: positive or negative chart level changes
input bool     DoTheOpposite = false;                              // Flag to reverse trading actions
input int      barsToCheck = 10;                                  // Number of bars to check for trend formation

input double   MinATRThreshold = 0.005;                            // Minimum ATR Percentage
input int      MagicNumber = 1199;                                 // Unique identifier for EA's orders
input int      MaxConcurrentTrades = 1;                            // Max number of concurrent trades
input int      FastEMAPeriod = 3;                                  // Fast EMA period for MACD
input int      SlowEMAPeriod = 10;                                 // Slow EMA period for MACD
input int      SignalSmaPeriod = 16;                               // Signal SMA period for MACD
input int      StartTradeHour = 0;                                 // Start hour for trading
input int      EndTradeHour = 23;                                  // End hour for trading
input string   NonStopTrading = "Y";                               // Non-stop trading flag ('Y' or 'N')

input bool     TradeDuringUptrend = true;                          // Flag to trade during an uptrend
input bool     TradeDuringDowntrend = true;                        // Flag to trade during a downtrend
input bool     TradeDuringConsolidation = true;                    // Flag to trade during consolidation

input string TradeOnMonday = "Y";    // Trade on Monday ('Y' or 'N')
input string TradeOnTuesday = "Y";   // Trade on Tuesday ('Y' or 'N')
input string TradeOnWednesday = "Y"; // Trade on Wednesday ('Y' or 'N')
input string TradeOnThursday = "Y";  // Trade on Thursday ('Y' or 'N')
input string TradeOnFriday = "Y";    // Trade on Friday ('Y' or 'N')
input string TradeOnSaturday = "Y";  // Trade on Saturday ('Y' or 'N')
input string TradeOnSunday = "Y";    // Trade on Sunday ('Y' or 'N')

input string TradeNewYorkSession = "Y";    // Trade during New York session ('Y' or 'N')
input string TradeLondonSession = "Y";     // Trade during London session ('Y' or 'N')
input string TradeTokyoSession = "Y";      // Trade during Tokyo session ('Y' or 'N')
input string TradeSydneySession = "Y";     // Trade during Sydney session ('Y' or 'N')


input bool EnableDisplay = true; // Enable display panel
datetime lastDisplayUpdate = 0;

double adxMinThreshold = 15.0;
double adxMaxThreshold = 40.0;
double atrMaxThreshold = 0.7;
double diDifferenceMinThreshold = 5.0;
double highVolatilityATRThreshold = 1.0;
double veryHighADXThreshold = 55.0;
double veryHighMinusDiDifference = 10.0;

string WorldSessionText = "NONE";
string TrendTextDisp = "Don't Know!";

// Enumerate world sessions
enum WorldSession {
    SYDNEY,
    TOKYO,
    LONDON,
    NEW_YORK,
    UNKNOWN
};

bool breakEvenSet = false;
struct PositionInfo {
    ulong ticket;
    bool breakEvenSet;
};

// Declare an array to store the position information
PositionInfo positionInfoArray[];

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
bool WolfTakenPartial = false;  // Global variable to track if partial closure has occurred


string MASignalText, EMASignalText, SOSignalText, MACDSignalText, BoBSignalText;
string RSISignalText, FibSignalText, ICSignalText, SDSignalText, AvgDirSignalText;
string HMASignalText, SEMASignalText, CANDSignalText, VolSignalText, VolumeSignalText, divergenceSignalText;
string ATRBandSignalText, KeltnerChannelSignalText, DonchianChannelSignalText, ParabolicSARSignalText;
string ChoppinessSignalText;

input double Weight_MA = 1.0, Weight_EMA = 1.0, Weight_SO = 1.0, Weight_MACD = 3.0, Weight_BoB = 0.5, Weight_RSI = 1.0;
input double Weight_Fib = 0, Weight_IC = 0, Weight_SD = 0, Weight_ADX = 2.0, Weight_HMA = 0, Weight_SEMA = 1.0;
input double Weight_CAND = 0.5, Weight_Vol = 0, Weight_Volume = 0, Weight_MacDivergence = 1.0;
input double Weight_ATRBand = 0, Weight_KeltnerChannel = 0, Weight_DonchianChannel = 0, Weight_ParabolicSAR = 0;
input double Weight_Choppiness = 0;

double BuyScore, SellScore;
double breakEvenTriggerPrice, trailingStartPrice, minStopDistance, newStopLoss, spread, atr;
double drawdownPercent = 0.00;
double LogHighestPrice, LogBreakEven, LogTrailStop, LogOpen, LogInATR, LogInStopLoss;
double atrPercentage;
double GrandSL, GrandTP;

datetime CoolOffStartTime;

//Logging
int ContinuouslossCount = 0;
ulong lastOrderTicket = 0;
ulong PrevOrderTicket = 0;

double SessionPnL = 0;

//string BalancedisplayText;
string DoTheOppsiteFlag;
string TradeProtocolFlag = "N";
string BotAbortedReason = "N/A";
string BotAborted = "N";
string BotErrorMsg = " ";


double MaxBalance = 0;
double StartBalance = 0;
//bool isTradingActive = true;

int higherTF;

double adx, plusDi, minusDi;

#define UPTREND 1
#define DOWNTREND -1
#define CONSOLIDATION 0
#define UNKNOWN 2

// Define the timeframes to check
int _timeframesToCheck[] = { PERIOD_H4, PERIOD_H1, PERIOD_M15, PERIOD_M5, PERIOD_M1 };

// Structure to store the trend results for each timeframe
struct TrendResult {
    int timeframe;
    int trend;
    string trendText;
};

// Variables to store the trend text for each timeframe
string H4TrendText = "";
string H1TrendText = "";
string M15TrendText = "";
string M30TrendText = "";
string M5TrendText = "";
string M1TrendText = "";

int marketCondition;

// Trend array to store trends for each method in each timeframe
string trendArray[6][6]; // 6 timeframes, 6 methods

// Declare strings to hold the individual trend values for display
string M1ADX, M1FAN, M1HA, M1MA, M1NRTR, M1ZZ;
string M5ADX, M5FAN, M5HA, M5MA, M5NRTR, M5ZZ;
string M15ADX, M15FAN, M15HA, M15MA, M15NRTR, M15ZZ;
string M30ADX, M30FAN, M30HA, M30MA, M30NRTR, M30ZZ;
string H1ADX, H1FAN, H1HA, H1MA, H1NRTR, H1ZZ;
string H4ADX, H4FAN, H4HA, H4MA, H4NRTR, H4ZZ;


bool activateWolfProtect = false;
double profitOrLoss = 0.0;
bool WolfNegativeHIT = false;
bool WolfPositiveHIT = false;
bool WolfBreakEvenTrailHit    = false;

double runtimeBuyThreshold;
double runtimeSellThreshold;
double runtimeOppositeThreshold;

// Declare variables for DISPLAY
input int panel_x = 10;
input int panel_y_offset = 10;
input int panel_width = 900;
input int panel_height = 800; // Adjusted height for button
input int label_height = 20;  // Height for each label
int panel_y;
int chart_height;

int display_button;
int label1, label2, label3;
string info_text1 = "Shiva 1.0";
string info_text2 = "Strategy  Wt  Signal";
string info_text3;
string objects_created[];

// Define TickInfo struct globally
struct TickInfo {
    double tickValue;
    double tickSize;
    double contractSize;
    double point;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

    Print("=== Broker Tick Info for Symbol: ", _Symbol, " ===");

    double tickValue     = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize      = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double contractSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    double point         = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

    if (tickValue <= 0)
        Print("❌ Error: SYMBOL_TRADE_TICK_VALUE is invalid or zero.");
    if (tickSize <= 0)
        Print("❌ Error: SYMBOL_TRADE_TICK_SIZE is invalid or zero.");
    if (contractSize <= 0)
        Print("❌ Error: SYMBOL_TRADE_CONTRACT_SIZE is invalid or zero.");
    if (point <= 0)
        Print("❌ Error: SYMBOL_POINT is invalid or zero.");

    PrintFormat("✅ TickValue: %.10f", tickValue);
    PrintFormat("✅ TickSize: %.10f", tickSize);
    PrintFormat("✅ ContractSize: %.2f", contractSize);
    PrintFormat("✅ Point: %.10f", point);

    // Override if DemoMode is enabled
    if (DemoMode == "Y") {
        runtimeBuyThreshold = 1.0;
        runtimeSellThreshold = 1.0;
        runtimeOppositeThreshold = 20.0;
    } else {
        runtimeBuyThreshold = buyThreshold;
        runtimeSellThreshold = sellThreshold;
        runtimeOppositeThreshold = oppositeThreshold;
    }

    // Create a panel for DISPLAY
    ChartSetInteger(0, CHART_BRING_TO_TOP, 0);
    ChartRedraw();
   
    // Get chart height to position the panel at the bottom
    chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
    // Calculate y position for bottom panel
    panel_y = chart_height - panel_height - panel_y_offset;

    // Create the display button without text
    display_button = CreateLargeButton(panel_x, panel_y, panel_width, panel_height);
    ArrayResize(objects_created, ArraySize(objects_created) + 1);
    objects_created[ArraySize(objects_created) - 1] = "Display Panel_button";

    // Create labels for each line of text
    label1 = CreateCustomLabel("info_label1", info_text1, 700, panel_y + 10, clrBlueViolet);
    
    StartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    Print("Initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Cleanup logic here
    ObjectsDeleteAll(0, 0, "");  // Deletes all objects from the main window of the chart
    
    // Delete all controls on deinitialization
    DeleteAllControls();
    ChartRedraw();
  
    // Release the indicator handles
    ReleaseIndicators();

    Print("Deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Main trading logic here

    RunStrategy();
    CheckLastClosedTrade();
    WolfProtect();
    TriDeviDisplay();
    CheckDrawDown(MaxAllowedDrawdown);
    
    //Check for Trading Rules
    TradeProtocol();
    // Check Trade Protocol
    if (TradeProtocolFlag == "Y" && BotAborted != "Y") 
       {
          // Check if the cool-off period has passed
          if (TimeCurrent() - CoolOffStartTime >= CoolOffCandleSeconds)
           {
               CheckLastClosedTrade();  // Check again!
               DecideBuyOrSell();
           }
       } 
    
}


//+------------------------------------------------------------------+
//| Trade Protocol function                                          |
//+------------------------------------------------------------------+
void TradeProtocol() {
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    TradeProtocolFlag = "Y";

    // Rule 1: Trading hours
    if (NonStopTrading != "Y" && (timeStruct.hour < StartTradeHour || timeStruct.hour >= EndTradeHour)) {
        TradeProtocolFlag = "N";
        BotErrorMsg = "- Non Trading Time";
        return;
    }

    // Rule 2: Trading days (relaxed for demo testing)
    string tradeDays[] = {TradeOnSunday, TradeOnMonday, TradeOnTuesday, TradeOnWednesday, TradeOnThursday, TradeOnFriday, TradeOnSaturday};
    if (tradeDays[timeStruct.day_of_week] != "Y") {
        TradeProtocolFlag = "N";
        BotErrorMsg = "- Non Trading Day";
        return;
    }

    // Rule 3: Market conditions
    marketCondition = DetermineMarketConditions5Elements();
    if ((marketCondition == UPTREND && !TradeDuringUptrend) ||
        (marketCondition == DOWNTREND && !TradeDuringDowntrend) ||
        (marketCondition == CONSOLIDATION && !TradeDuringConsolidation)) {
        TradeProtocolFlag = "N";
        BotErrorMsg = "- Trend Not Suitable";
        return;
    }

    // Rule 4: Trading sessions (relaxed for demo testing)
    if (NonStopTrading != "Y") {
    WorldSession currentSession = DetermineWorldSession();
    if ((currentSession == NEW_YORK && TradeNewYorkSession != "Y") ||
        (currentSession == LONDON && TradeLondonSession != "Y") ||
        (currentSession == TOKYO && TradeTokyoSession != "Y") ||
        (currentSession == SYDNEY && TradeSydneySession != "Y") ||
        (currentSession == UNKNOWN)) {
        TradeProtocolFlag = "N";
        BotErrorMsg = "- Session Not Active";
        return;
    }
                               }

    // Rule 5: ATR threshold
    atr = CalculateATR();
    if (atr <= 0) {
        Print("Error in calculating ATR");
        TradeProtocolFlag = "N";
        BotErrorMsg = "- ATR Calculation Failed";
        return;
    }

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    if (currentPrice <= 0) {
        Print("Failed to retrieve current price");
        TradeProtocolFlag = "N";
        BotErrorMsg = "- Price Retrieval Failed";
        return;
    }

    atrPercentage = (atr / currentPrice) * 100;
    if (atrPercentage < MinATRThreshold) {
        TradeProtocolFlag = "N";
        BotErrorMsg = "- ATR Threshold Too Low";
    }
}

// Determine the current world trading session
WorldSession DetermineWorldSession() {
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);

    int hour = timeStruct.hour;
    
    // Define the start and end hours of each session (server time)
    // Adjust these times according to your broker's server time
    if ((hour >= 22 && hour < 7) || (hour == 21 && timeStruct.min >= 55)) {
        WorldSessionText = "SYDNEY";
        return SYDNEY;
    } else if (hour >= 7 && hour < 16) {
        WorldSessionText = "TOKYO";
        return TOKYO;
    } else if (hour >= 8 && hour < 17) {
        WorldSessionText = "LONDON";
        return LONDON;
    } else if (hour >= 13 && hour < 22) {
        WorldSessionText = "NEW YORK";
        return NEW_YORK;
    }

    WorldSessionText = "UNKNOWN";
    return UNKNOWN;
}


void RunStrategy()
{
    // Reset scores after decision
    BuyScore = 0.0;
    SellScore = 0.0;
     
    MovingAverage(); 
    UpdateScore(MASignalText, Weight_MA);
      
    ExponentialMovingAverage(); 
    UpdateScore(EMASignalText, Weight_EMA);

    StochasticOscillator(); 
    UpdateScore(SOSignalText, Weight_SO);

    MACDStrategy(); 
    UpdateScore(MACDSignalText, Weight_MACD);
      
    BollingerBandsStrategy();  
    UpdateScore(BoBSignalText, Weight_BoB);
      
    RelativeStrengthIndex(); 
    UpdateScore(RSISignalText, Weight_RSI);
      
    FibonacciRetracement(); 
    UpdateScore(FibSignalText, Weight_Fib);
      
    IchimokuCloudStrategy(); 
    UpdateScore(ICSignalText, Weight_IC);
      
    StandardDeviationStrategy(); 
    UpdateScore(SDSignalText, Weight_SD);
      
    AverageDirectionalIndex(); 
    UpdateScore(AvgDirSignalText, Weight_ADX);
      
    HullMovingAverageStrategy(); 
    UpdateScore(HMASignalText, Weight_HMA);
      
    ScalpingEMA(); 
    UpdateScore(SEMASignalText, Weight_SEMA);
      
    CandlestickPatterns();
    UpdateScore(CANDSignalText, Weight_CAND);
      
    VolatilityStrategy();
    UpdateScore(VolSignalText, Weight_Vol);
      
    VolumeStrategy();
    UpdateScore(VolumeSignalText, Weight_Volume);
    
    DivergenceProtectionStrategy();
    UpdateScore(divergenceSignalText, Weight_MacDivergence);
    
    ATRBandStrategy();
    UpdateScore(divergenceSignalText, Weight_ATRBand);
    
    KeltnerChannelStrategy();
    UpdateScore(KeltnerChannelSignalText, Weight_KeltnerChannel);
    
    DonchianChannelStrategy();
    UpdateScore(DonchianChannelSignalText, Weight_DonchianChannel);
    
    ParabolicSARStrategy();
    UpdateScore(ParabolicSARSignalText, Weight_ParabolicSAR);
    
}

//+------------------------------------------------------------------+
//| Function to add scores after each strategy                       |
//+------------------------------------------------------------------+
void UpdateScore(string signalText, double weight) {
    if (weight > 0) {  // Only consider the strategy if its weight is greater than 0
        if (StringContains(signalText, "BUY")) {
            BuyScore += weight;  // Increment BuyScore by the weight if "BUY" is found
        } else if (StringContains(signalText, "SELL")) {
            SellScore += weight;  // Increment SellScore by the weight if "SELL" is found
        }
    }
}

//+------------------------------------------------------------------+
//| Returns true if 'str' contains 'subStr'                          |
//+------------------------------------------------------------------+
bool StringContains(string str, string subStr) {
    return(StringFind(str, subStr) >= 0);  // Check if substring is found in the string
}

void DecideBuyOrSell() {
    int marketCondition = DetermineMarketConditions5Elements();
  
bool tradeWithTrend = (TradeWithTrendFlag == "Y");
    
if (DoTheOpposite) {
    if (BuyScore >= runtimeBuyThreshold && SellScore <= runtimeOppositeThreshold ) {
        //Print("DoTheOpposite - BuyScore meets threshold and SellScore is within opposite threshold");
        if (!tradeWithTrend || (tradeWithTrend && marketCondition == UPTREND)) {
            //Print("SellSignal triggered due to BuyScore >= buyThreshold in an uptrend or not trading with trend");
            SellSignal();  // Sell in an uptrend or if not trading with the trend
        }
    } else if (SellScore >= runtimeSellThreshold && BuyScore <= runtimeOppositeThreshold ) {
        Print("DoTheOpposite - SellScore meets threshold and BuyScore is within opposite threshold");
        if (!tradeWithTrend || (tradeWithTrend && marketCondition == DOWNTREND)) {
            //Print("BuySignal triggered due to SellScore >= sellThreshold in a downtrend or not trading with trend");
            BuySignal();  // Buy in a downtrend or if not trading with the trend
        }
    }
} else {
    if (BuyScore >= runtimeBuyThreshold && SellScore <= runtimeOppositeThreshold ) {
        //Print("Normal - BuyScore meets threshold and SellScore is within opposite threshold");
        if (tradeWithTrend && marketCondition == UPTREND) {
            //Print("BuySignal triggered due to BuyScore >= buyThreshold in an uptrend");
            BuySignal();  // Buy only in an uptrend when trading with the trend
        } else if (!tradeWithTrend) {
            //Print("BuySignal triggered due to BuyScore >= buyThreshold without considering trend");
            BuySignal();  // Buy without considering the trend
        }
    } else if (SellScore >= runtimeSellThreshold && BuyScore <= runtimeOppositeThreshold ) {
        //Print("Normal - SellScore meets threshold and BuyScore is within opposite threshold");
        if (tradeWithTrend && marketCondition == DOWNTREND) {
            //Print("SellSignal triggered due to SellScore >= sellThreshold in a downtrend");
            SellSignal();  // Sell only in a downtrend when trading with the trend
        } else if (!tradeWithTrend) {
            //Print("SellSignal triggered due to SellScore >= sellThreshold without considering trend");
            SellSignal();  // Sell without considering the trend
        }
    }
}

    BuyScore = 0.0;
    SellScore = 0.0;
}


// Function to convert dollar amount to symbol points
double ConvertDollarsToPoints(string symbol, double dollarAmount) {
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double point     = SymbolInfoDouble(symbol, SYMBOL_POINT);

    double valuePerPoint = tickValue * (point / tickSize);
    if (valuePerPoint == 0.0) valuePerPoint = 1.0; // fail-safe
    return dollarAmount / valuePerPoint;
}

// Function to calculate SL/TP for buy and sell orders
void CalculateSLTP(double &sl, double &tp, double price, double slDollars, double tpDollars, double lotSize, bool isBuy) {
//    double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE); // e.g., 100000 for EURUSD, 100 for XAUUSD
//    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);        // e.g., 0.00001 for EURUSD, 0.01 for XAUUSD
//    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);      // Per 1 lot
//    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);                    // Typically equals tickSize

TickInfo tickInfo = CalculateTickInfo(_Symbol);
double tickValue = tickInfo.tickValue;
double tickSize = tickInfo.tickSize;
double contractSize = tickInfo.contractSize;
double point = tickInfo.point;

    double minStopLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * tickSize;

    // Calculate points needed to achieve the dollar risk/reward
    double slPoints = (slDollars / (tickValue * lotSize)) / (tickSize / point); // Convert dollars to points
    double tpPoints = (tpDollars / (tickValue * lotSize)) / (tickSize / point);

    // Ensure minimum stop level is met
    slPoints = MathMax(slPoints, minStopLevelPoints / tickSize);
    tpPoints = MathMax(tpPoints, minStopLevelPoints / tickSize);

    if (isBuy) {
        sl = NormalizeDouble(price - slPoints * tickSize, _Digits);
        tp = NormalizeDouble(price + tpPoints * tickSize, _Digits);
    } else {
        sl = NormalizeDouble(price + slPoints * tickSize, _Digits);
        tp = NormalizeDouble(price - tpPoints * tickSize, _Digits);
    }

    Print("CalculateSLTP: Symbol=", _Symbol, ", SL_Dollars=", slDollars, ", TP_Dollars=", tpDollars, 
          ", SL_Points=", slPoints, ", TP_Points=", tpPoints, ", SL=", sl, ", TP=", tp, 
          ", MinStopLevel=", minStopLevelPoints, ", TickValue=", tickValue, ", ContractSize=", contractSize);
}

// BuySignal updated with improved SL/TP calculation
void BuySignal() {
    if (CountPositionsForSymbol(_Symbol) >= MaxConcurrentTrades)
        return;

    double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double stopLoss, takeProfit;

    if (MoneyDriven) {
        CalculateSLTP(stopLoss, takeProfit, askPrice, SL_Money, TP_Money, LotSize, true);
    } else {
        CalculateDynamicSLTP(stopLoss, takeProfit, SL_ATRMultiplier, TP_ATRMultiplier);
    }

    double minStopLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    if (MathAbs(askPrice - stopLoss) < minStopLevelPoints || MathAbs(takeProfit - askPrice) < minStopLevelPoints) {
        Print("Invalid SL/TP: Symbol=", _Symbol, ", SL=", stopLoss, ", TP=", takeProfit, ", Ask=", askPrice, ", MinStopLevel=", minStopLevelPoints);
        return;
    }

    if (trade.Buy(LotSize, _Symbol, askPrice, stopLoss, takeProfit, "Buy Order")) {
        ulong ticket = trade.ResultOrder();
        if (ticket > 0) {
            string detailedSignals = PrepareSignalDetails();
            string TradeDetailsString = TimeCurrent() + ";" + ticket + ";Buy;" + detailedSignals;
            LogTradeDetails(TradeDetailsString);
            lastOrderTicket = ticket;
            CoolOffStartTime = TimeCurrent();
            WolfTakenPartial = false;
            WolfNegativeHIT = false;
            WolfPositiveHIT = false;
            WolfBreakEvenTrailHit = false;
        } else {
            Print("Failed to get position ticket for buy order");
        }
    } else {
        Print("Error placing buy order: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
    }
}

// SellSignal updated with improved SL/TP calculation
void SellSignal() {
    if (CountPositionsForSymbol(_Symbol) >= MaxConcurrentTrades)
        return;

    double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double stopLoss, takeProfit;

    if (MoneyDriven) {
        CalculateSLTP(stopLoss, takeProfit, bidPrice, SL_Money, TP_Money, LotSize, false);
    } else {
        CalculateDynamicSLTP(stopLoss, takeProfit, SL_ATRMultiplier, TP_ATRMultiplier);
    }

    double minStopLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    if (MathAbs(bidPrice - stopLoss) < minStopLevelPoints || MathAbs(takeProfit - bidPrice) < minStopLevelPoints) {
        Print("Invalid SL/TP: Symbol=", _Symbol, ", SL=", stopLoss, ", TP=", takeProfit, ", Bid=", bidPrice, ", MinStopLevel=", minStopLevelPoints);
        return;
    }

    if (trade.Sell(LotSize, _Symbol, bidPrice, stopLoss, takeProfit, "Sell Order")) {
        ulong ticket = trade.ResultOrder();
        if (ticket > 0) {
            string detailedSignals = PrepareSignalDetails();
            string TradeDetailsString = TimeCurrent() + ";" + ticket + ";Sell;" + detailedSignals;
            LogTradeDetails(TradeDetailsString);
            lastOrderTicket = ticket;
            CoolOffStartTime = TimeCurrent();
            WolfTakenPartial = false;
            WolfNegativeHIT = false;
            WolfPositiveHIT = false;
            WolfBreakEvenTrailHit = false;
        } else {
            Print("Failed to get position ticket for sell order");
        }
    } else {
        Print("Error placing sell order: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
    }
}

void CalculateDynamicSLTP(double &stopLoss, double &takeProfit, double atrMultiplierSL, double atrMultiplierTP) {
    double atr = CalculateATR();
    if (atr <= 0) {
        Print("Error in calculating ATR");
        BotAborted = "Y";
        BotAbortedReason = "ATR Calculation Failed";
        stopLoss = 0;
        takeProfit = 0;
        return;
    }

    double minStopLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
    if (minStopLevelPoints <= 0) minStopLevelPoints = 20 * _Point;

    double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    stopLoss = atrMultiplierSL * atr / pointSize;
    takeProfit = atrMultiplierTP * atr / pointSize;

    stopLoss = MathMax(stopLoss, minStopLevelPoints / pointSize);
    takeProfit = MathMax(takeProfit, minStopLevelPoints / pointSize);

    LogInATR = atr;
    Print("CalculateDynamicSLTP: ATR=", atr, ", SL=", stopLoss, ", TP=", takeProfit, ", MinStopLevel=", minStopLevelPoints);
}

double CalculateATR() {
    string symbol = _Symbol;
    ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
    int atrPeriod = ATRPeriod;

    int atrHandle = iATR(symbol, timeframe, atrPeriod);
    double atrValues[];
    ArraySetAsSeries(atrValues, true);

    if (CopyBuffer(atrHandle, 0, 0, 1, atrValues) <= 0) {
        Print("Failed to retrieve ATR values");
        return -1;
    }

    return atrValues[0];
}

// Function to normalize SL/TP based on symbol
double NormalizeSLTP(double price, double adjustment) {
    return NormalizeDouble(price + adjustment, _Digits);
}

// Function to count the number of positions for the current symbol
int CountPositionsForSymbol(string symbol) {
    int count = 0;
    int totalPositions = PositionsTotal();
    for (int i = 0; i < totalPositions; i++) {
        if (PositionSelect(_Symbol) && PositionGetString(POSITION_SYMBOL) == symbol) {
            count++;
        }
    }
    return count;
}


//+------------------------------------------------------------------+
//   STRATEGIES!
//+------------------------------------------------------------------+

// (1) ****Moving Average Strategy****
void MovingAverage() {
    int period = 50;
    double ma = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_SMA, PRICE_CLOSE);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    string signalText = (currentPrice > ma) ? "BUY" : (currentPrice < ma) ? "SELL" : "WAIT";
    MASignalText = signalText;
     string dispstr1 = "MASignalText";
     string disptxt1 = "MA       " + DoubleToString(Weight_MA, 1);
     string sigtxt1  =  MASignalText;
     int Xpos1       = 15;
     int Ypos1       = 50;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (2) ****Exponential Moving Average Strategy****
void ExponentialMovingAverage() {
    int period = 200;
    int maHandle = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_CLOSE);
    if (maHandle == INVALID_HANDLE) {
        Print("Failed to obtain EMA handle");
        return;
    }

    double emaBuffer[];
    if (CopyBuffer(maHandle, 0, 0, 1, emaBuffer) <= 0) {
        Print("Failed to copy data from EMA buffer");
        return;
    }
    double ema = emaBuffer[0];
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    string signalText = (currentPrice > ema) ? "BUY" : (currentPrice < ema) ? "SELL" : "WAIT";
    EMASignalText = signalText;
     string dispstr1 = "EMASignalText";
     string disptxt1 = "EMA     " + DoubleToString(Weight_EMA, 1);
     string sigtxt1  =  EMASignalText;
     int Xpos1       = 15;
     int Ypos1       = 90;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (3) ****Stochastic Oscillator Strategy****
void StochasticOscillator() {
    int Kperiod = 5, Dperiod = 3, slowing = 3;
    int stochasticHandle = iStochastic(_Symbol, PERIOD_CURRENT, Kperiod, Dperiod, slowing, MODE_SMA, STO_LOWHIGH);
    if (stochasticHandle == INVALID_HANDLE) {
        Print("Failed to get handle of Stochastic indicator");
        return;
    }
    double KBuffer[], DBuffer[];
    if (CopyBuffer(stochasticHandle, 0, 0, 1, KBuffer) <= 0 || CopyBuffer(stochasticHandle, 1, 0, 1, DBuffer) <= 0) {
        Print("Failed to copy data from Stochastic buffer");
        return;
    }
    double K = KBuffer[0];
    double D = DBuffer[0];
    string signalText = (K > D) ? "BUY" : (K < D) ? "SELL" : "WAIT";
    SOSignalText = signalText;
     string dispstr1 = "SOSignalText";
     string disptxt1 = "SO        " + DoubleToString(Weight_SO, 1);
     string sigtxt1  =  SOSignalText;
     int Xpos1       = 15;
     int Ypos1       = 130;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (4) ****MACD Strategy****
void MACDStrategy() {
    int macdHandle = iMACD(_Symbol, PERIOD_CURRENT, FastEMAPeriod, SlowEMAPeriod, SignalSmaPeriod, PRICE_CLOSE);
    if (macdHandle == INVALID_HANDLE) {
        Print("Failed to obtain MACD handle");
        return;
    }

    double macdMainBuffer[];
    double macdSignalBuffer[];

    if (CopyBuffer(macdHandle, 0, 0, 1, macdMainBuffer) <= 0) {
        Print("Failed to copy data from MACD main buffer");
        return;
    }
    if (CopyBuffer(macdHandle, 1, 0, 1, macdSignalBuffer) <= 0) {
        Print("Failed to copy data from MACD signal buffer");
        return;
    }

    double macd_main = macdMainBuffer[0];
    double macd_signal = macdSignalBuffer[0];

    string signalText = (macd_main > macd_signal) ? "BUY" : (macd_main < macd_signal) ? "SELL" : "WAIT";
    MACDSignalText = signalText;
     string dispstr1 = "MACDSignalText";
     string disptxt1 = "MACD   " + DoubleToString(Weight_MACD, 1);
     string sigtxt1  =  MACDSignalText;
     int Xpos1       = 15;
     int Ypos1       = 170;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (5) ****Bollinger Bands Strategy****

void BollingerBandsStrategy() {
    int bandsHandle = iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE);
    if (bandsHandle == INVALID_HANDLE) {
        Print("Failed to obtain Bollinger Bands handle");
        return;
    }

    double upperBandBuffer[1];
    double lowerBandBuffer[1];

    if (CopyBuffer(bandsHandle, 1, 0, 1, upperBandBuffer) <= 0) {
        Print("Failed to copy data from Bollinger Bands upper buffer");
        return;
    }
    if (CopyBuffer(bandsHandle, 2, 0, 1, lowerBandBuffer) <= 0) {
        Print("Failed to copy data from Bollinger Bands lower buffer");
        return;
    }

    double upperBand = upperBandBuffer[0];
    double lowerBand = lowerBandBuffer[0];
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    string signalText = (currentPrice > upperBand) ? "SELL" : (currentPrice < lowerBand) ? "BUY" : "WAIT";
    BoBSignalText = signalText;
     string dispstr1 = "BoBSignalText";
     string disptxt1 = "BoB       " + DoubleToString(Weight_BoB, 1);
     string sigtxt1  =  BoBSignalText;
     int Xpos1       = 15;
     int Ypos1       = 210;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}


// (6) ****Relative Strength Index Strategy****
void RelativeStrengthIndex() {
    int period = 14;
    int rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, period, PRICE_CLOSE);

    if (rsiHandle == INVALID_HANDLE) {
        Print("Failed to obtain RSI handle");
        return;
    }

    double rsiBuffer[1];

    if (CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) <= 0) {
        Print("Failed to copy data from RSI buffer");
        return;
    }

    double rsi = rsiBuffer[0];
    string signalText = (rsi > 70) ? "SELL" : (rsi < 30) ? "BUY" : "WAIT";
    RSISignalText = signalText;
     string dispstr1 = "RSISignalText";
     string disptxt1 = "RSI        " + DoubleToString(Weight_RSI, 1);
     string sigtxt1  =  RSISignalText;
     int Xpos1       = 15;
     int Ypos1       = 250;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (7) ****Fibonacci Retracement Strategy****
void FibonacciRetracement() {
    double highPrice = iHigh(_Symbol, PERIOD_CURRENT, 0);
    double lowPrice = iLow(_Symbol, PERIOD_CURRENT, 0);

    double fib382 = highPrice - (highPrice - lowPrice) * 0.382;
    double fib618 = highPrice - (highPrice - lowPrice) * 0.618;

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    string signalText = (currentPrice > fib618) ? "BUY" : (currentPrice < fib382) ? "SELL" : "WAIT";
    FibSignalText = signalText;
     string dispstr1 = "FibSignalText";
     string disptxt1 = "Fib         " + DoubleToString(Weight_Fib, 1);
     string sigtxt1  =  FibSignalText;
     int Xpos1       = 15;
     int Ypos1       = 290;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (8) ****Ichimoku Cloud Strategy****
void IchimokuCloudStrategy() {
    int tenkan = 9;
    int kijun = 26;
    int senkou = 52;

    double tenkanSen[], kijunSen[], senkouSpanA[], senkouSpanB[];

    int handle = iIchimoku(_Symbol, PERIOD_CURRENT, tenkan, kijun, senkou);

    CopyBuffer(handle, 0, 0, 1, tenkanSen);
    CopyBuffer(handle, 1, 0, 1, kijunSen);
    CopyBuffer(handle, 2, 0, 1, senkouSpanA);
    CopyBuffer(handle, 3, 0, 1, senkouSpanB);

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    string signalText = (tenkanSen[0] > kijunSen[0] && senkouSpanA[0] > senkouSpanB[0] && currentPrice > senkouSpanA[0]) ? "BUY" :
                        (tenkanSen[0] < kijunSen[0] && senkouSpanA[0] < senkouSpanB[0] && currentPrice < senkouSpanA[0]) ? "SELL" : "WAIT";
    ICSignalText = signalText;
     string dispstr1 = "ICSignalText";
     string disptxt1 = "Ic           " + DoubleToString(Weight_IC, 1);
     string sigtxt1  =  ICSignalText;
     int Xpos1       = 15;
     int Ypos1       = 330;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

// (9) ****Standard Deviation Strategy****
void StandardDeviationStrategy() {
    int period = 20;
    ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
    string symbol = _Symbol;

    double maBuffer[], stddevBuffer[];

    int maHandle = iMA(symbol, timeframe, period, 0, MODE_SMA, PRICE_CLOSE);
    int stddevHandle = iStdDev(symbol, timeframe, period, 0, MODE_SMA, PRICE_CLOSE);

    CopyBuffer(maHandle, 0, 0, 1, maBuffer);
    CopyBuffer(stddevHandle, 0, 0, 1, stddevBuffer);

    double upperBand = maBuffer[0] + stddevBuffer[0];
    double lowerBand = maBuffer[0] - stddevBuffer[0];

    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
    
    string signalText = (currentPrice > upperBand) ? "SELL" : (currentPrice < lowerBand) ? "BUY" : "WAIT";
    SDSignalText = signalText;
     string dispstr1 = "SDSignalText";
     string disptxt1 = "SD         " + DoubleToString(Weight_SD, 1);
     string sigtxt1  =  SDSignalText;
     int Xpos1       = 15;
     int Ypos1       = 370;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);

}

void AverageDirectionalIndex() {
    CalculateADXValues(_Symbol, PERIOD_CURRENT, adxPeriod, adx, plusDi, minusDi);
    string signalText = (adx > 25 && (plusDi - minusDi) > threshold) ? "BUY" : (adx > 25 && (minusDi - plusDi) > threshold) ? "SELL" : "WAIT";
    AvgDirSignalText = signalText;

    string dispstr1 = "AvgDirSignalText";
    string disptxt1 = "ADX       " + DoubleToString(Weight_ADX, 1);  // Use 'adx' directly
    string sigtxt1  =  AvgDirSignalText;
    int Xpos1       = 15;
    int Ypos1       = 410;
    DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
}

void CalculateADXValues(string symbol, ENUM_TIMEFRAMES timeframe, int period, double &adxValue, double &plusDiValue, double &minusDiValue) {
    int adxHandle = iADX(symbol, timeframe, period);
    double adxBuffer[1], plusDiBuffer[1], minusDiBuffer[1];
    if (CopyBuffer(adxHandle, 0, 0, 1, adxBuffer) > 0 && 
        CopyBuffer(adxHandle, 1, 0, 1, plusDiBuffer) > 0 && 
        CopyBuffer(adxHandle, 2, 0, 1, minusDiBuffer) > 0) {
        adxValue = adxBuffer[0];
        plusDiValue = plusDiBuffer[0];
        minusDiValue = minusDiBuffer[0];
    } else {
        adxValue = plusDiValue = minusDiValue = 0.0;
    }
}


// (11) ****Hull Moving Average Strategy****
void HullMovingAverageStrategy() {
    int period = 14;
    double hma = CalculateHullMovingAverage(_Symbol, PERIOD_CURRENT, period, PRICE_CLOSE);
    double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
    string signalText = (currentPrice > hma) ? "BUY" : (currentPrice < hma) ? "SELL" : "WAIT";
    HMASignalText = signalText;
     string dispstr1 = "HMASignalText";
     string disptxt1 = "Hull        " + DoubleToString(Weight_HMA, 1);
     string sigtxt1  =  HMASignalText;
     int Xpos1       = 15;
     int Ypos1       = 450;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
    
}

double CalculateHullMovingAverage(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_APPLIED_PRICE priceType) {
    int wmaHalfPeriod = period / 2;
    int sqrtPeriod = (int)MathSqrt(period);

    double priceData[];
    ArrayResize(priceData, Bars(symbol, timeframe));
    CopyClose(symbol, timeframe, 0, ArraySize(priceData), priceData);

    double wmaHalfLength[], wmaFullLength[], deltaWMAArray[], hmaArray[];

    ArrayResize(wmaHalfLength, ArraySize(priceData));
    ArrayResize(wmaFullLength, ArraySize(priceData));
    ArrayResize(deltaWMAArray, ArraySize(priceData));
    ArrayResize(hmaArray, ArraySize(priceData));

    SimpleMAOnBuffer(ArraySize(priceData), 0, wmaHalfPeriod, 0, priceData, wmaHalfLength);
    SimpleMAOnBuffer(ArraySize(priceData), 0, period, 0, priceData, wmaFullLength);

    for (int i = 0; i < ArraySize(deltaWMAArray); i++) {
        deltaWMAArray[i] = 2 * wmaHalfLength[i] - wmaFullLength[i];
    }

    SimpleMAOnBuffer(ArraySize(deltaWMAArray), 0, sqrtPeriod, 0, deltaWMAArray, hmaArray);

    return hmaArray[0];
}

// (12) ****Scalping Exponential Moving Average Strategy****
void ScalpingEMA() {
    int fastEMAPeriod = 9, slowEMAPeriod = 21;
    double fastEMA = iMA(NULL, 0, fastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
    double slowEMA = iMA(NULL, 0, slowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    string signalText = (fastEMA > slowEMA && currentPrice > fastEMA) ? "BUY" : (fastEMA < slowEMA && currentPrice < fastEMA) ? "SELL" : "WAIT";
    SEMASignalText = signalText;
     string dispstr1 = "SEMASignalText";
     string disptxt1 = "SEMA    " + DoubleToString(Weight_SEMA, 1);
     string sigtxt1  =  SEMASignalText;
     int Xpos1       = 15;
     int Ypos1       = 490;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
}

// (13) ****Candlestick Patterns*********
void CandlestickPatterns() {
    double openCurrent = iOpen(NULL, 0, 0);
    double closeCurrent = iClose(NULL, 0, 0);
    double highCurrent = iHigh(NULL, 0, 0);
    double lowCurrent = iLow(NULL, 0, 0);

    double openPrevious = iOpen(NULL, 0, 1);
    double closePrevious = iClose(NULL, 0, 1);
    double highPrevious = iHigh(NULL, 0, 1);
    double lowPrevious = iLow(NULL, 0, 1);

    string signalText = "WAIT";

    if (closeCurrent > openCurrent && closePrevious < openPrevious) {
        if (openCurrent < closePrevious && closeCurrent > openPrevious) {
            signalText = "BUY";
        }
    }

    if (closeCurrent < openCurrent && closePrevious > openPrevious) {
        if (openCurrent > closePrevious && closeCurrent < openPrevious) {
            signalText = "SELL";
        }
    }

    CANDSignalText = signalText;
     string dispstr1 = "CANDSignalText";
     string disptxt1 = "Cand      " + DoubleToString(Weight_CAND, 1);
     string sigtxt1  =  CANDSignalText;
     int Xpos1       = 15;
     int Ypos1       = 530;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
}

// (14) ****Volatility-Based Strategy****
void VolatilityStrategy() {
    int atrPeriod = 14;
    double atr = iATR(_Symbol, PERIOD_CURRENT, atrPeriod);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double volatilityThreshold = 0.5 * atr;

    double highPrice = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double lowPrice = iLow(_Symbol, PERIOD_CURRENT, 1);

    if (currentPrice > highPrice + volatilityThreshold) {
        VolSignalText = "BUY";
    } else if (currentPrice < lowPrice - volatilityThreshold) {
        VolSignalText = "SELL";
    } else {
        VolSignalText = "WAIT";
    }
     string dispstr1 = "VolSignalText";
     string disptxt1 = "Volatility  " + DoubleToString(Weight_Vol, 1);
     string sigtxt1  =  VolSignalText;
     int Xpos1       = 15;
     int Ypos1       = 570;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
}

// (15) ****Volume-Based Strategy****
void VolumeStrategy() {
    int obvPeriod = 20;
    double currentOBV = iOBV(NULL, 0, 0);
    double previousOBV = iOBV(NULL, 0, 1);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double previousPrice = iClose(NULL, 0, 1);

    if (currentOBV > previousOBV && currentPrice > previousPrice) {
        VolumeSignalText = "BUY";
    } else if (currentOBV < previousOBV && currentPrice < previousPrice) {
        VolumeSignalText = "SELL";
    } else {
        VolumeSignalText = "WAIT";
    }
     string dispstr1 = "VolumeSignalText";
     string disptxt1 = "Volume   " + DoubleToString(Weight_Volume, 1);
     string sigtxt1  =  VolumeSignalText;
     int Xpos1       = 15;
     int Ypos1       = 610;
     DisplayBuySellSignals(dispstr1, disptxt1, sigtxt1, Xpos1, Ypos1);
}

// (16) ****MACD DivergenceProtection Strategy****
void DivergenceProtectionStrategy() {
    int macdHandle = iMACD(_Symbol, PERIOD_CURRENT, FastEMAPeriod, SlowEMAPeriod, SignalSmaPeriod, PRICE_CLOSE);
    if (macdHandle == INVALID_HANDLE) {
        Print("Failed to obtain MACD handle");
        return;
    }

    double macdMainBuffer[];
    double priceHighs[20];
    double priceLows[20];

    // Copy the latest 20 bars of MACD line
    if (CopyBuffer(macdHandle, 0, 0, 20, macdMainBuffer) <= 0) {
        Print("Failed to copy data from MACD main buffer");
        return;
    }

    // Get recent price highs and lows
    for (int i = 0; i < 20; i++) {
        priceHighs[i] = iHigh(_Symbol, PERIOD_CURRENT, i);
        priceLows[i] = iLow(_Symbol, PERIOD_CURRENT, i);
    }

    double recentHigh = iHigh(_Symbol, PERIOD_CURRENT, 0);
    double recentLow = iLow(_Symbol, PERIOD_CURRENT, 0);

    bool bullishDivergence = false;
    bool bearishDivergence = false;

    // Detect Bullish Divergence (Price lower low, MACD higher low)
    if (recentLow < priceLows[1] && macdMainBuffer[0] > macdMainBuffer[1]) {
        bullishDivergence = true;
    }

    // Detect Bearish Divergence (Price higher high, MACD lower high)
    if (recentHigh > priceHighs[1] && macdMainBuffer[0] < macdMainBuffer[1]) {
        bearishDivergence = true;
    }

    divergenceSignalText = "WAIT"; // Default to wait if no divergence detected

    if (bullishDivergence) {
        divergenceSignalText = "BUY";
    } else if (bearishDivergence) {
        divergenceSignalText = "SELL";
    }

    // Display Divergence signals
    string dispstr2 = "DivergenceSignalText";
    string disptxt2 = "MacDiv   " + DoubleToString(Weight_MacDivergence, 1);;
    string sigtxt2  = divergenceSignalText;
    int Xpos2       = 15;
    int Ypos2       = 650;
    DisplayBuySellSignals(dispstr2, disptxt2, sigtxt2, Xpos2, Ypos2);
}

// (17) ****ATR Bands Strategy****
void ATRBandStrategy() {
    int atrPeriod = 14;
    double atr = iATR(_Symbol, PERIOD_CURRENT, atrPeriod);
    double ma = iMA(_Symbol, PERIOD_CURRENT, atrPeriod, 0, MODE_SMA, PRICE_CLOSE);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double upperBand = ma + (atr * 1.5);  // You can change the multiplier as needed
    double lowerBand = ma - (atr * 1.5);

    // Determine the buy/sell/wait signal based on price vs. bands
    if (currentPrice > upperBand) {
        ATRBandSignalText = "BUY";
    } else if (currentPrice < lowerBand) {
        ATRBandSignalText = "SELL";
    } else {
        ATRBandSignalText = "WAIT";
    }

    // Display ATR Bands signals on the chart
    string dispstr2 = "ATRBandSignalText";
    string disptxt2 = "ATR Bands  " + DoubleToString(Weight_ATRBand, 1);
    string sigtxt2  = ATRBandSignalText;
    int Xpos2       = 15;
    int Ypos2       = 700;
//    DisplayBuySellSignals(dispstr2, disptxt2, sigtxt2, Xpos2, Ypos2);
}


// (18) ****Keltner Channel Strategy****
void KeltnerChannelStrategy() {
    int emaPeriod = 20;
    int atrPeriod = 14;
    double multiplier = 2.0;  // Adjust the multiplier as needed for the channel width

    // Calculate EMA and ATR
    double ema = iMA(_Symbol, PERIOD_CURRENT, emaPeriod, 0, MODE_EMA, PRICE_CLOSE);
    double atr = iATR(_Symbol, PERIOD_CURRENT, atrPeriod);

    // Calculate the upper and lower Keltner Channel bands
    double upperBand = ema + (multiplier * atr);
    double lowerBand = ema - (multiplier * atr);

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    // Determine the buy/sell/wait signal based on price vs. Keltner Channels
    if (currentPrice > upperBand) {
        KeltnerChannelSignalText = "BUY";
    } else if (currentPrice < lowerBand) {
        KeltnerChannelSignalText = "SELL";
    } else {
        KeltnerChannelSignalText = "WAIT";
    }

    // Display Keltner Channel signals on the chart
    string dispstr3 = "KeltnerChannelSignalText";
    string disptxt3 = "Keltner Channel  " + DoubleToString(Weight_KeltnerChannel, 1);
    string sigtxt3  = KeltnerChannelSignalText;
    int Xpos3       = 15;
    int Ypos3       = 610;
//    DisplayBuySellSignals(dispstr3, disptxt3, sigtxt3, Xpos3, Ypos3);
}


// (19) ****Donchian Channel Strategy****
void DonchianChannelStrategy() {
    int period = 20;  // Adjust this period for the Donchian Channel

    // Calculate the highest high and lowest low over the specified period
    double highestHigh = iHigh(_Symbol, PERIOD_CURRENT, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, period, 0));
    double lowestLow = iLow(_Symbol, PERIOD_CURRENT, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, period, 0));

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    // Determine the buy/sell/wait signal based on price vs. Donchian Channels
    if (currentPrice > highestHigh) {
        DonchianChannelSignalText = "BUY";
    } else if (currentPrice < lowestLow) {
        DonchianChannelSignalText = "SELL";
    } else {
        DonchianChannelSignalText = "WAIT";
    }

    // Display Donchian Channel signals on the chart
    string dispstr4 = "DonchianChannelSignalText";
    string disptxt4 = "Donchian Channel  " + DoubleToString(Weight_DonchianChannel, 1);
    string sigtxt4  = DonchianChannelSignalText;
    int Xpos4       = 15;
    int Ypos4       = 630;
//    DisplayBuySellSignals(dispstr4, disptxt4, sigtxt4, Xpos4, Ypos4);
}

// (20) ****Parabolic SAR Strategy****
void ParabolicSARStrategy() {
    double step = 0.02;  // Default step value for Parabolic SAR
    double maximum = 0.2; // Default maximum value for Parabolic SAR

    // Get the current Parabolic SAR value using the correct iSAR syntax
    double sarValue = iSAR(_Symbol, PERIOD_CURRENT, step, maximum);

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    // Determine the buy/sell/wait signal based on Parabolic SAR vs. current price
    if (currentPrice > sarValue) {
        ParabolicSARSignalText = "BUY";
    } else if (currentPrice < sarValue) {
        ParabolicSARSignalText = "SELL";
    } else {
        ParabolicSARSignalText = "WAIT";
    }

    // Display Parabolic SAR signals on the chart
    string dispstr5 = "ParabolicSARSignalText";
    string disptxt5 = "Parabolic SAR  " + DoubleToString(Weight_ParabolicSAR, 1);
    string sigtxt5  = ParabolicSARSignalText;
    int Xpos5       = 15;
    int Ypos5       = 660;
//    DisplayBuySellSignals(dispstr5, disptxt5, sigtxt5, Xpos5, Ypos5);
}

// (21) ****Choppiness Index Strategy****
void ChoppinessIndexStrategy() {
    int ciPeriod = 14;  // Default period for Choppiness Index
    double ciThresholdBuy = 38.2;  // Choppiness index below this indicates trending market
    double ciThresholdSell = 61.8;  // Choppiness index above this indicates choppy market

    // Calculate the Choppiness Index using custom indicator or calculation (if available)
    double ciValue = iCustom(_Symbol, PERIOD_CURRENT, "ChoppinessIndex", ciPeriod);

    // Determine the buy/sell/wait signal based on Choppiness Index value
    if (ciValue < ciThresholdBuy) {
        ChoppinessSignalText = "BUY";
    } else if (ciValue > ciThresholdSell) {
        ChoppinessSignalText = "SELL";
    } else {
        ChoppinessSignalText = "WAIT";
    }

    // Display Choppiness Index signals on the chart
    string dispstr6 = "ChoppinessSignalText";
    string disptxt6 = "Choppiness Index  " + DoubleToString(Weight_Choppiness, 1);
    string sigtxt6  = ChoppinessSignalText;
    int Xpos6       = 15;
    int Ypos6       = 700;
//    DisplayBuySellSignals(dispstr6, disptxt6, sigtxt6, Xpos6, Ypos6);
}

//+------------------------------------------------------------------+
//| SIGNALS on Chart Red or Blue                                     |
//+------------------------------------------------------------------+

void DisplayBuySellSignals(string dispstr1, string disptxt1, string sigtxt1, int Xpos1, int Ypos1)
{
    string SigColor1;
    if (sigtxt1 == "BUY") SigColor1 = clrBlue;
    if (sigtxt1 == "SELL") SigColor1 = clrRed;
    if (sigtxt1 == "WAIT") SigColor1 = clrGray;
    
    label3 = CreateCustomLabel(dispstr1, disptxt1, Xpos1, panel_y + Ypos1, clrBlack);
    label3 = CreateCustomLabel(dispstr1 + "Unique", sigtxt1, Xpos1 + 170, panel_y + Ypos1, SigColor1);


}


//+------------------------------------------------------------------+
//| Function to create a large button                                |
//+------------------------------------------------------------------+
int CreateLargeButton(int x, int y, int width, int height)
{
    string button_name = "Display Panel_button";
    if (!ObjectCreate(0, button_name, OBJ_BUTTON, 0, 0, 0)) {
        Print("Failed to create button: ", button_name);
        return 0;
    }
    ObjectSetInteger(0, button_name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, button_name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, button_name, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, button_name, OBJPROP_YSIZE, height);
    ObjectSetString(0, button_name, OBJPROP_TEXT, ""); // No text on button
    ObjectSetInteger(0, button_name, OBJPROP_CORNER, 0);
    ObjectSetInteger(0, button_name, OBJPROP_HIDDEN, 0);
    return 1;
}
  
//+------------------------------------------------------------------+
//| Function to create a custom label                                |
//+------------------------------------------------------------------+
int CreateCustomLabel(string name, string text, int x, int y, color textColor) {
    if (!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) {
        Print("Failed to create label: ", name);
        return 0;
    }
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_CORNER, 0);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, 0);
    ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
    ArrayResize(objects_created, ArraySize(objects_created) + 1);
    objects_created[ArraySize(objects_created) - 1] = name;
    return 1;
}

//+------------------------------------------------------------------+
//| Function to check if a button was clicked                        |
//+------------------------------------------------------------------+
bool ButtonClicked(string button_name) {
    if (ObjectGetInteger(0, button_name, OBJPROP_STATE) == 1) {
        ObjectSetInteger(0, button_name, OBJPROP_STATE, 0);
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Function to delete all controls                                  |
//+------------------------------------------------------------------+
void DeleteAllControls() {
    for (int i = 0; i < ArraySize(objects_created); i++) {
        ObjectDelete(0, objects_created[i]);
    }
}


//+------------------------------------------------------------------+
//| LOGGING LOGIC - IN A .CSV                                        |
//+------------------------------------------------------------------+

void LogTradeDetails(string log_entry)
{
    string file_name = "TradeDetailTridevi.csv";
    string full_path = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + file_name; // To print exact path
    Print("Full path to file: ", full_path);  // Prints the path in the logs

    int file_handle;
    
    // Check if the file already exists
    if (FileIsExist(file_name))
    {
        // Open the file for appending
        file_handle = FileOpen(file_name, FILE_READ | FILE_WRITE | FILE_CSV);
        if (file_handle == INVALID_HANDLE)
        {
            Print("Failed to open file for appending: ", GetLastError());
            return;
        }
        FileSeek(file_handle, 0, SEEK_END);  // Move to the end of the file
    }
    else
    {
        // Create a new file
        file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV);
        if (file_handle == INVALID_HANDLE)
        {
            Print("Failed to create file: ", GetLastError());
            return;
        }
        // Optionally, write the header row
        FileWrite(file_handle, "TradeDetails");
    }
    
    // Log the trade details
    FileWrite(file_handle, log_entry);
    
    // Close the file
    FileClose(file_handle);
    
    Print("Trade details logged successfully: ", log_entry);
}


string PrepareSignalDetails() {
    // Initialize a string to hold detailed signal information
    string signalDetails = "";
    // Append each strategy's signal and corresponding weight
    
    signalDetails += "ADX: " + DoubleToString(adx, 2) + ";plusDi: " + DoubleToString(plusDi, 2) + ";minusDi: " + DoubleToString(minusDi, 2) + ";";
    signalDetails += "BuyScore: " + BuyScore + ";Sell Score: " + SellScore + ";";
    
    signalDetails += "MA: " + MASignalText + " : " + DoubleToString(Weight_MA, 1) + "; ";
    signalDetails += "EMA: " + EMASignalText + " : " + DoubleToString(Weight_EMA, 1) + "; ";
    signalDetails += "Stochastic: " + SOSignalText + " : " + DoubleToString(Weight_SO, 1) + "; ";
    signalDetails += "MACD: " + MACDSignalText + " : " + DoubleToString(Weight_MACD, 1) + "; ";
    signalDetails += "Bollinger Bands: " + BoBSignalText + " : " + DoubleToString(Weight_BoB, 1) + "; ";
    signalDetails += "RSI: " + RSISignalText + " : " + DoubleToString(Weight_RSI, 1) + "; ";
    signalDetails += "Fibonacci: " + FibSignalText + " : " + DoubleToString(Weight_Fib, 1) + "; ";
    signalDetails += "Ichimoku Cloud: " + ICSignalText + " : " + DoubleToString(Weight_IC, 1) + "; ";
    signalDetails += "Standard Deviation: " + SDSignalText + " : " + DoubleToString(Weight_SD, 1) + "; ";
    signalDetails += "ADX: " + AvgDirSignalText + " : " + DoubleToString(Weight_ADX, 1) + "; ";
    signalDetails += "HMA: " + HMASignalText + " : " + DoubleToString(Weight_HMA, 1) + "; ";
    signalDetails += "Scalping EMA: " + SEMASignalText + " : " + DoubleToString(Weight_SEMA, 1) + "; ";
    signalDetails += "Candlestick: " + CANDSignalText + " : " + DoubleToString(Weight_CAND, 1) + "; ";
    signalDetails += "Volatility: " + VolSignalText + " : " + DoubleToString(Weight_Vol, 1) + "; ";
    signalDetails += "Volume: " + VolumeSignalText + " : " + DoubleToString(Weight_Volume, 1) + "; ";
    
    return signalDetails;
}


//+------------------------------------------------------------------+
//| Check the result of the last trade                               |
//+------------------------------------------------------------------+
void CheckLastClosedTrade()
  {
  
   if (PositionSelectByTicket(lastOrderTicket)) 
    {
        return;   //Active Order
    }
   else 
    {        
             PrevOrderTicket = lastOrderTicket;  //It's Histroy
    } 
   
   
   if (PrevOrderTicket == 0) return;
   
   if (BotAborted == "Y") return;

   // Ensure history is loaded
   if (!HistorySelect(0, TimeCurrent())) {
      Print("History not selected");
      return;
   }
   if (HistoryOrderSelect(PrevOrderTicket))
   {
      datetime timeord = HistoryOrderGetInteger(PrevOrderTicket, ORDER_TIME_DONE);
      double closePrice = 0.0;
      double dealprofit = 0.0;
      // Find the closing deal for this order
      for (int i = HistoryDealsTotal() - 1; i >= 0; i--)
      {
         ulong dealTicket = HistoryDealGetTicket(i);
         datetime timedeal = HistoryDealGetInteger(dealTicket, DEAL_TIME);
           if (timedeal = timeord)
         {
            dealprofit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            break;
         }
      }

      int orderType = HistoryOrderGetInteger(PrevOrderTicket, ORDER_TYPE);

      bool isWin = false;
      if (dealprofit >= 0.0) {isWin = true;}
      else                  {isWin = false;}
      
      if (isWin)
      {
         ContinuouslossCount = 0;  // Reset loss count on win
         Print(lastOrderTicket, " WIN: ", DoubleToString(dealprofit, 2), " Loss Count: " + ContinuouslossCount);
      }
      else
      {
         ContinuouslossCount++;  // Increase loss count on loss
         Print(lastOrderTicket, " LOSS: ", DoubleToString(dealprofit, 2), " Loss Count: " + ContinuouslossCount);
         Print("Loss Cool Off!");
         CoolOffStartTime = TimeCurrent();

         if (ContinuouslossCount >= MaxToleranceContinuousLoss)
         {
            Print("Reached max tolerance. Abort BOT!!!");
            BotAbortedReason = "Max Loss Count";
            BotAborted = "Y";
            BotErrorMsg = "- Max Continuous loss";
         }
      }
      
      string LogClosedTrade = TimeCurrent() +";" + PrevOrderTicket 
                                              + ";PNL: " + DoubleToString(dealprofit, 2) 
                                              + ";ATR: " + DoubleToString(LogInATR, 2)
                                              + ";Open: " + DoubleToString(LogOpen, 2)
                                              + ";StopLoss: " + DoubleToString(LogInStopLoss, 2)
                                              + ";High-Low: " + DoubleToString(LogHighestPrice, 2) 
                                              + ";Brk-evn: " + DoubleToString(LogBreakEven, 2)
                                              + ";Trail: " + DoubleToString(LogTrailStop, 2); 
                                              
      LogTradeDetails(LogClosedTrade);

      SessionPnL = SessionPnL + dealprofit;
      PrevOrderTicket = 0;  // Reset the ticket after checking
      lastOrderTicket = 0;  // Reset the ticket after checking
   }
   else
   {
      Print("Error selecting order from history. Order ticket: ", lastOrderTicket);
   }
}


//  CALCULATE DRAWDOWN
void CheckDrawDown(double maxDrawdownPercent)
{
    double CurrentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
    if (MaxBalance < CurrentBalance) 
      {
        MaxBalance = CurrentBalance;
      }
    else 
      {
        drawdownPercent = ((MaxBalance - CurrentBalance) / MaxBalance) * 100.0;
      }
    
    // Check if drawdown exceeds the maximum allowed
    if (drawdownPercent >= maxDrawdownPercent)
    {
        BotAborted = "Y";
        BotAbortedReason = "Max Drawdown";
        BotErrorMsg = "- Max Drawdown Reached";
    }
    else
    {
    }
}


//--------------------------TREND!---TREND!---TREND!---TREND!---TREND!---TREND!

// Include necessary libraries
#include <Trade\Trade.mqh>

// Indicator handles
int adx_handle = 0;
int fan_handle = 0;
int heiken_ashi_handle = 0;
int ma_handle = 0;
int nrtr_handle = 0;
int zigzag_handle = 0;

// Trend array to store trends for each method in each timeframe
//string trendArray[6][6]; // 6 timeframes, 6 methods

// Function to initialize indicator handles for a specific timeframe
int InitializeIndicators(ENUM_TIMEFRAMES timeframe)
{
    adx_handle = iCustom(Symbol(), timeframe, "Examples\\ADXTrendDetector", 14, 20);
    if(adx_handle == INVALID_HANDLE) { Print("Failed to initialize ADXTrendDetector, Error: ", GetLastError()); return -1; }

    fan_handle = iCustom(Symbol(), timeframe, "Examples\\FanTrendDetector", 200, 50, 21);
    if(fan_handle == INVALID_HANDLE) { Print("Failed to initialize FanTrendDetector, Error: ", GetLastError()); return -1; }

    heiken_ashi_handle = iCustom(Symbol(), timeframe, "Examples\\HeikenAshiTrendDetector");
    if(heiken_ashi_handle == INVALID_HANDLE) { Print("Failed to initialize HeikenAshiTrendDetector, Error: ", GetLastError()); return -1; }

    ma_handle = iCustom(Symbol(), timeframe, "Examples\\MATrendDetector", 200);
    if(ma_handle == INVALID_HANDLE) { Print("Failed to initialize MATrendDetector, Error: ", GetLastError()); return -1; }

    nrtr_handle = iCustom(Symbol(), timeframe, "Examples\\NRTRTrendDetector", 40, 2.0);
    if(nrtr_handle == INVALID_HANDLE) { Print("Failed to initialize NRTRTrendDetector, Error: ", GetLastError()); return -1; }

    zigzag_handle = iCustom(Symbol(), timeframe, "Examples\\ZigZagTrendDetector", 12, 5, 3);
    if(zigzag_handle == INVALID_HANDLE) { Print("Failed to initialize ZigZagTrendDetector, Error: ", GetLastError()); return -1; }

    // Wait for the indicators to load data
    Sleep(180);
    return 0;
}

// Function to release indicator handles
void ReleaseIndicators()
{
    if (adx_handle != INVALID_HANDLE) IndicatorRelease(adx_handle);
    if (fan_handle != INVALID_HANDLE) IndicatorRelease(fan_handle);
    if (heiken_ashi_handle != INVALID_HANDLE) IndicatorRelease(heiken_ashi_handle);
    if (ma_handle != INVALID_HANDLE) IndicatorRelease(ma_handle);
    if (nrtr_handle != INVALID_HANDLE) IndicatorRelease(nrtr_handle);
    if (zigzag_handle != INVALID_HANDLE) IndicatorRelease(zigzag_handle);
}

// Function to get the trend signal from a specific indicator handle
int GetSignal(int handle)
{
    double trend_direction[];
    ArrayResize(trend_direction, 1);
    int copied = CopyBuffer(handle, 0, 0, 1, trend_direction);
    if (copied != 1)
    {
        Print("CopyBuffer copy error, Code = ", GetLastError());
        return 0;
    }
    return (int)trend_direction[0];
}

int TrendDetector(ENUM_TIMEFRAMES timeframe, int tf_index) {
    // === ADX ===
    double adxBuffer[], plusDiBuffer[], minusDiBuffer[];
    ArraySetAsSeries(adxBuffer, true);
    ArraySetAsSeries(plusDiBuffer, true);
    ArraySetAsSeries(minusDiBuffer, true);

    int adx_handle = iADX(_Symbol, timeframe, 14);
    if (adx_handle == INVALID_HANDLE) {
        Print("Failed to initialize ADX for ", EnumToString(timeframe));
        BotAborted = "Y";
        BotAbortedReason = "ADX Initialization Failed";
        return UNKNOWN;
    }

    if (CopyBuffer(adx_handle, 0, 0, 1, adxBuffer) <= 0 ||
        CopyBuffer(adx_handle, 1, 0, 1, plusDiBuffer) <= 0 ||
        CopyBuffer(adx_handle, 2, 0, 1, minusDiBuffer) <= 0) {
        Print("Failed to copy ADX buffers for ", EnumToString(timeframe));
        IndicatorRelease(adx_handle);
        BotAborted = "Y";
        BotAbortedReason = "ADX Data Retrieval Failed";
        return UNKNOWN;
    }

    double adx = adxBuffer[0];
    double plusDi = plusDiBuffer[0];
    double minusDi = minusDiBuffer[0];

    trendArray[tf_index][0] = (adx > 25 && plusDi > minusDi) ? "U" : 
                               (adx > 25 && minusDi > plusDi) ? "D" : "C";
    IndicatorRelease(adx_handle);

    // === Other Trend Indicators ===
    double fan[], ha[], ma[], nrtr[], zz[];
    ArraySetAsSeries(fan, true);
    ArraySetAsSeries(ha, true);
    ArraySetAsSeries(ma, true);
    ArraySetAsSeries(nrtr, true);
    ArraySetAsSeries(zz, true);

    // FAN
    if (CopyBuffer(fan_handle, 0, 0, 1, fan) > 0)
        trendArray[tf_index][1] = (int)fan[0] == 1 ? "U" : (int)fan[0] == -1 ? "D" : "C";
    else
        trendArray[tf_index][1] = "C";

    // Heiken Ashi
    if (CopyBuffer(heiken_ashi_handle, 0, 0, 1, ha) > 0)
        trendArray[tf_index][2] = (int)ha[0] == 1 ? "U" : (int)ha[0] == -1 ? "D" : "C";
    else
        trendArray[tf_index][2] = "C";

    // MA
    if (CopyBuffer(ma_handle, 0, 0, 1, ma) > 0)
        trendArray[tf_index][3] = (int)ma[0] == 1 ? "U" : (int)ma[0] == -1 ? "D" : "C";
    else
        trendArray[tf_index][3] = "C";

    // NRTR
    if (CopyBuffer(nrtr_handle, 0, 0, 1, nrtr) > 0)
        trendArray[tf_index][4] = (int)nrtr[0] == 1 ? "U" : (int)nrtr[0] == -1 ? "D" : "C";
    else
        trendArray[tf_index][4] = "C";

    // ZigZag
    if (CopyBuffer(zigzag_handle, 0, 0, 1, zz) > 0)
        trendArray[tf_index][5] = (int)zz[0] == 1 ? "U" : (int)zz[0] == -1 ? "D" : "C";
    else
        trendArray[tf_index][5] = "C";

    return (adx > 25 && plusDi > minusDi) ? UPTREND :
           (adx > 25 && minusDi > plusDi) ? DOWNTREND :
           CONSOLIDATION;
}


// Function to determine the market conditions for M1, M5, M15, M30, H1, and H4 timeframes
int DetermineMarketConditions5Elements() {
    ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4};
    TrendResult results[];
    ArrayResize(results, ArraySize(timeframes));
    int overallTrend = UNKNOWN;
    int currentTrend = UNKNOWN;
    int currentLevelTrend = UNKNOWN;
    
    int startLevel = 0;  // Start level based on the current timeframe
    int endLevel = TimeFrameLevelsUp + 1;  // End level for checking trend (inclusive of TimeFrameLevelsUp)

    // Determine startLevel based on current timeframe
    int currentTimeFrame = Period();
    if (currentTimeFrame == PERIOD_M5) {
        startLevel = 1;  // Start from M5
    } else if (currentTimeFrame == PERIOD_M15) {
        startLevel = 2;  // Start from M15
    } else if (currentTimeFrame == PERIOD_M30) {
        startLevel = 3;  // Start from M30
    } else if (currentTimeFrame == PERIOD_H1) {
        startLevel = 4;  // Start from H1
    } else if (currentTimeFrame == PERIOD_H4) {
        startLevel = 5;  // Start from H4
    }

    // Iterate over the timeframes and check trends
    for (int i = 0; i < ArraySize(timeframes); i++) {
        ENUM_TIMEFRAMES timeframe = timeframes[i];
        InitializeIndicators(timeframe);
        Sleep(200);
        int trend = TrendDetector(timeframe, i);  // Passing the index 'i' as 'tf_index'
        string trendText;

        if (trend == UPTREND) {
            trendText = "U";
        } else if (trend == DOWNTREND) {
            trendText = "D";
        } else {
            trendText = "C";
        }

        results[i].timeframe = timeframe;
        results[i].trend = trend;
        results[i].trendText = trendText;

        // Store individual trend texts
        if (timeframe == PERIOD_H4) {
            H4TrendText = trendText;
        } else if (timeframe == PERIOD_H1) {
            H1TrendText = trendText;
        } else if (timeframe == PERIOD_M30) {
            M30TrendText = trendText;
        } else if (timeframe == PERIOD_M15) {
            M15TrendText = trendText;
        } else if (timeframe == PERIOD_M5) {
            M5TrendText = trendText;
        } else if (timeframe == PERIOD_M1) {
            M1TrendText = trendText;
            currentTrend = trend;  // Capture the current trend for M1
        }

        // Check the current timeframe trend and the next ones based on TimeFrameLevelsUp
        if (TrendFollowMethod == "C" && i >= startLevel && i < startLevel + endLevel) {
            if (i == startLevel) {
                currentLevelTrend = trend;  // Start with the current timeframe's trend
            } else if (trend != currentLevelTrend) {
                currentLevelTrend = UNKNOWN;
                break;  // Exit early if trends do not align
            }
        }
    }

    // Set the overall trend to the calculated current trend for method "C"
    if (TrendFollowMethod == "C") {
        overallTrend = currentLevelTrend;
    } else {
        // Default logic: Determine the overall trend by checking all timeframes
        overallTrend = results[0].trend;
        for (int i = 1; i < ArraySize(results); i++) {
            if (results[i].trend != overallTrend) {
                overallTrend = UNKNOWN;
                break;
            }
        }
    }

    // Set the overall trend text
    if (overallTrend == UPTREND) {
        TrendTextDisp = "UPTREND";
    } else if (overallTrend == DOWNTREND) {
        TrendTextDisp = "DOWNTREND";
    } else if (overallTrend == CONSOLIDATION) {
        TrendTextDisp = "CONSOLIDATION";
    } else {
        TrendTextDisp = "UNKNOWN";
    }

    return overallTrend;
}


double CalculateProfitOrLoss(ulong positionTicket, double tickSize, double tickValue) {
    if (PositionSelectByTicket(positionTicket)) {
        int positionType = PositionGetInteger(POSITION_TYPE);
        double positionSize = PositionGetDouble(POSITION_VOLUME);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentPrice = 0.0;
        double profitOrLoss = 0.0;

        if (positionType == POSITION_TYPE_BUY) {
            // Get the current price for BUY position
            currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            // Calculate profit or loss for BUY position
            profitOrLoss = ((currentPrice - openPrice) / tickSize) * tickValue * positionSize;
        } else if (positionType == POSITION_TYPE_SELL) {
            // Get the current price for SELL position
            currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            // Calculate profit or loss for SELL position
            profitOrLoss = ((openPrice - currentPrice) / tickSize) * tickValue * positionSize;
        }

        // Normalize profit or loss to ensure correct decimal places
        return NormalizeDouble(profitOrLoss, _Digits);
    }

    return 0.0; // Return 0 if position is not found or invalid
}


void WolfProtect() {
    if (WolfProtectFlag != "Y") {
        return;  // Exit if WolfProtect is not activated or TradeWithTrendFlag is not set to "Y"
    }

    ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4};
    int currentTrend = UNKNOWN;

    // Determine the trend based on the selected TrendFollowMethod
    if (TrendFollowMethod == "C") {
        for (int i = 0; i <= TimeFrameLevelsUp && i < ArraySize(timeframes); i++) {
            int trend = TrendDetector(timeframes[i], i);
            if (i == 0) {
                currentTrend = trend;  // The trend of the current timeframe
            } else if (trend != currentTrend) {
                currentTrend = UNKNOWN;
                break;
            }
        }
    } else if (TrendFollowMethod == "O") {
        for (int i = 0; i < ArraySize(timeframes); i++) {
            int trend = TrendDetector(timeframes[i], i);
            if (i == 0) {
                currentTrend = trend;
            } else if (trend != currentTrend) {
                currentTrend = UNKNOWN;
                break;
            }
        }
    }

    // Iterate through open positions and modify stop loss if needed
    int totalPositions = PositionsTotal();
    for (int i = 0; i < totalPositions; i++) {
        ulong positionTicket = PositionGetTicket(i);
        if (positionTicket != 0 && PositionSelectByTicket(positionTicket)) {
            string symbol = PositionGetString(POSITION_SYMBOL);
            int positionType = PositionGetInteger(POSITION_TYPE);
            double positionSize = PositionGetDouble(POSITION_VOLUME);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentStopLoss = PositionGetDouble(POSITION_SL);

            if (symbol == _Symbol) {
//                double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
//                double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
TickInfo tickInfo = CalculateTickInfo(_Symbol);
double tickValue = tickInfo.tickValue;
double tickSize = tickInfo.tickSize;


                // Calculate profit or loss using the new function
                double profitOrLoss = CalculateProfitOrLoss(positionTicket, tickSize, tickValue);

                if (profitOrLoss >= WolfBreakEven) {
                    double tpValue = PositionGetDouble(POSITION_TP);
                    double slValue = currentStopLoss;
                    if (WolfTrailAfterBreakEven) { WolfBreakEvenTrailHit = true; }

                    // Calculate the partial lot size to close
                    double partialLotSize = NormalizeDouble(positionSize * WolfPartial, 2);

                    // Close the partial trade
                    if (!WolfTakenPartial) {
                        if (partialLotSize > 0 && partialLotSize < positionSize) {
                            if (positionType == POSITION_TYPE_BUY) {
                                if (trade.PositionClosePartial(positionTicket, partialLotSize)) {
                                    Print("Closed partial BUY position: ", partialLotSize, " lots for ticket: ", positionTicket);
                                    WolfTakenPartial = true;

                                    // Recalculate profit or loss after partial close
                                    profitOrLoss = CalculateProfitOrLoss(positionTicket, tickSize, tickValue);
                                } else {
                                    Print("Failed to close partial BUY position: ", positionTicket);
                                }
                            } else if (positionType == POSITION_TYPE_SELL) {
                                if (trade.PositionClosePartial(positionTicket, partialLotSize)) {
                                    Print("Closed partial SELL position: ", partialLotSize, " lots for ticket: ", positionTicket);
                                    WolfTakenPartial = true;

                                    // Recalculate profit or loss after partial close
                                    profitOrLoss = CalculateProfitOrLoss(positionTicket, tickSize, tickValue);
                                } else {
                                    Print("Failed to close partial SELL position: ", positionTicket);
                                }
                            }
                        }
                    }

                    // Move stop loss to breakeven for the remaining position
                    if (positionType == POSITION_TYPE_BUY && currentStopLoss < openPrice) {
                        slValue = openPrice;   // Move stop loss to breakeven for BUY position

                        if (trade.PositionModify(positionTicket, slValue, tpValue)) {
                            Print("Stop loss set to breakeven for remaining BUY position: ", positionTicket);
                        } else {
                            Print("Failed to set stop loss to breakeven for remaining BUY position: ", positionTicket);
                        }
                    } else if (positionType == POSITION_TYPE_SELL && currentStopLoss > openPrice) {
                        slValue = openPrice;  // Move stop loss to breakeven for SELL position

                        if (trade.PositionModify(positionTicket, slValue, tpValue)) {
                            Print("Stop loss set to breakeven for remaining SELL position: ", positionTicket);
                        } else {
                            Print("Failed to set stop loss to breakeven for remaining SELL position: ", positionTicket);
                        }
                    }
                }

                // Convert the desired dollar profit or loss into the equivalent in points
                double pointLoss = WolfStopPrice / (tickValue * positionSize);

                // Determine if WolfProtect should be activated
                bool activateWolfProtect = false;

                // Wolf Protect Activation Logic
                // *** 01 *** Positive Profit Level Hit - Release the Wolf!
                if (profitOrLoss >= WolfPositivePrice) {
                    if (WolfTakenPartial) { activateWolfProtect = true; }
                    WolfPositiveHIT     = true;
                }
                // *** 02 *** Negative Tolerance Hit - Release the Wolf!
                if (profitOrLoss <= -WolfNegativePrice) {
                    activateWolfProtect = true;
                    if (WolfTrailAfterNegative) { WolfNegativeHIT = true; }
                }
                // *** 03 *** Trend gone Opposite direction - Release the Wolf!
                if ((positionType == POSITION_TYPE_BUY && currentTrend == DOWNTREND) || 
                    (positionType == POSITION_TYPE_SELL && currentTrend == UPTREND)) {
                    if (RevWolfProtect) {
                                          activateWolfProtect = true; 
                                          if (WolfTrailAfterNegative) { WolfNegativeHIT = true; 
                                        }
                    }
                }
                

                if (activateWolfProtect || WolfNegativeHIT || WolfBreakEvenTrailHit) {
                    double newStopLossPrice = 0;
                    double currentPrice = 0.0;

                    if (positionType == POSITION_TYPE_BUY) {
                        currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                        newStopLossPrice = currentPrice - pointLoss * _Point;
                        newStopLossPrice = NormalizeDouble(newStopLossPrice, _Digits);
                        // Only modify if new stop loss is tighter and different from the existing stop loss
                        if (newStopLossPrice > currentStopLoss && currentStopLoss != newStopLossPrice) {
                            if (trade.PositionModify(positionTicket, newStopLossPrice, PositionGetDouble(POSITION_TP))) {
                                Print("Stop loss modified for BUY position: ", positionTicket);
                            } else {
                                Print("Failed to modify stop loss for BUY position: ", positionTicket);
                            }
                        }
                    }



                    if (positionType == POSITION_TYPE_SELL) {
                        // Calculate stop loss for SELL position
                        currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                        newStopLossPrice = currentPrice + pointLoss * _Point;
                        newStopLossPrice = NormalizeDouble(newStopLossPrice, _Digits);

                        // Only modify if new stop loss is tighter and different from the existing stop loss
                        if (newStopLossPrice < currentStopLoss && currentStopLoss != newStopLossPrice) {
                            if (trade.PositionModify(positionTicket, newStopLossPrice, PositionGetDouble(POSITION_TP))) {
                                Print("Stop loss modified for SELL position: ", positionTicket);
                            } else {
                                Print("Failed to modify stop loss for SELL position: ", positionTicket);
                            }
                        }
                    }
                }
                
               
            }
        }
    }
}


//+------------------------------------------------------------------+
//| DISPLAY LOGIC - ON THE CHARTS                                    |
//+------------------------------------------------------------------+


void TriDeviDisplay() {
    panel_y = chart_height - panel_height - panel_y_offset;

    datetime now = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(now, timeStruct);
    
// Then, when formatting the display string, include both date and time:
string dateTimeStr = StringFormat("%04d.%02d.%02d %02d:%02d:%02d", 
    timeStruct.year, timeStruct.mon, timeStruct.day, 
    timeStruct.hour, timeStruct.min, timeStruct.sec);

// Use dateTimeStr in your display or logging
    int currentHour = timeStruct.hour;
    string timeText = dateTimeStr + " - " + WorldSessionText;

//  BOT Status
    label3 = CreateCustomLabel("BotStatus", "BOT Status: ", 310, panel_y + 750, clrBlack);
    if (TradeProtocolFlag == "Y" && BotAborted != "Y")
      {
        label3 = CreateCustomLabel("statusText", "ACTIVE", 470, panel_y + 750, clrBlue);
        BotErrorMsg = " ";
        label3 = CreateCustomLabel("BotErr2", BotErrorMsg, 590, panel_y + 750, clrBlue);
      }
    else
      {
        string BotNotActive = "INACTIVE";
        if (BotAborted == "Y") BotNotActive = "ABORTED - " + BotAbortedReason;
        label3 = CreateCustomLabel("statusText", BotNotActive, 470, panel_y + 750, clrRed);
        
        label3 = CreateCustomLabel("BotErr1", BotErrorMsg, 600, panel_y + 750, clrBlack);
        
        
      }


// ATR Display
    if (ATRDriven || MoneyDriven) { // Show ATR regardless of mode for consistency
        label3 = CreateCustomLabel("ATRLabel1", "ATR: Min: " + DoubleToString(MinATRThreshold, 2) + "% ", 310, panel_y + 185, clrBlack);
        label3 = CreateCustomLabel("ATRLabel2", "Curr: ", 540, panel_y + 185, clrBlack);
        label3 = CreateCustomLabel("ATRValue", DoubleToString(atr, 2), 620, panel_y + 185, clrBlack); // 5 digits for precision
        if (atrPercentage > MinATRThreshold) {
            label3 = CreateCustomLabel("ATRPercent", DoubleToString(atrPercentage, 2) + "% ", 700, panel_y + 185, clrGreen);
        } else {
            label3 = CreateCustomLabel("ATRPercent", DoubleToString(atrPercentage, 2) + "% ", 700, panel_y + 185, clrRed);
        }
    }
    
// Drawdown Display
    label3 = CreateCustomLabel("DrawdownLabel1", "Drawdown: Max: " + DoubleToString(MaxAllowedDrawdown, 2) + "% ", 310, panel_y + 250, clrBlack);
    label3 = CreateCustomLabel("DrawdownLabel2", "Curr: ", 620, panel_y + 250, clrBlack);
    if (drawdownPercent >= MaxAllowedDrawdown) {
        label3 = CreateCustomLabel("DrawdownValue", DoubleToString(drawdownPercent, 2) + "% ", 720, panel_y + 250, clrRed);
    } else {
        label3 = CreateCustomLabel("DrawdownValue", DoubleToString(drawdownPercent, 2) + "% ", 730, panel_y + 250, clrGreen);
    }
    
    // Wolf Protect Flags Display
    label3 = CreateCustomLabel("WolfNegHitLabel", "Trail: -ve: ", 310, panel_y + 290, clrBlack);
    label3 = CreateCustomLabel("WolfNegHitValue", WolfNegativeHIT ? "Yes" : "No", 430, panel_y + 290, clrRed);
    label3 = CreateCustomLabel("WolfBETrailHitLabel", "  BE: : ", 460, panel_y + 290, clrBlack);
    label3 = CreateCustomLabel("WolfBETrailHitValue", WolfBreakEvenTrailHit ? "Yes" : "No", 530, panel_y + 290, clrRed);


if (ATRDriven)
  {
    label3 = CreateCustomLabel("Atr1", " ATR: Min: " + DoubleToString(MinATRThreshold, 2) + "% ", 310, panel_y + 230, clrBlack);
    label3 = CreateCustomLabel("Atr3", " Curr: ", 540, panel_y + 230, clrBlack);
    label3 = CreateCustomLabel("Atr4", DoubleToString(atr, 2), 720, panel_y + 230, clrBlack);
    if (atrPercentage > MinATRThreshold)
     {
       label3 = CreateCustomLabel("Atr2", DoubleToString(atrPercentage, 2) + "% ", 620, panel_y + 230, clrGreen);
     }
    else 
     {
       label3 = CreateCustomLabel("Atr2", DoubleToString(atrPercentage, 2) + "% ", 620, panel_y + 230, clrRed);
     }
     
   }

// Show Trade Mode: MoneyDriven or ATRDriven
string tradeModeText = "Mode: ";
string tradeModeValue = "";

if (MoneyDriven)
{
    tradeModeValue = "MoneyDriven";
    label3 = CreateCustomLabel("TradeModeText", tradeModeText, 310, panel_y + 150, clrBlack);
    label3 = CreateCustomLabel("TradeModeValue", tradeModeValue, 390, panel_y + 150, clrBlue);
}
else if (ATRDriven)
{
    tradeModeValue = "ATRDriven";
    label3 = CreateCustomLabel("TradeModeText", tradeModeText, 310, panel_y + 150, clrBlack);
    label3 = CreateCustomLabel("TradeModeValue", tradeModeValue, 390, panel_y + 150, clrGreen);
}
else
{
    tradeModeValue = "Manual/Undefined";
    label3 = CreateCustomLabel("TradeModeText", tradeModeText, 310, panel_y + 270, clrBlack);
    label3 = CreateCustomLabel("TradeModeValue", tradeModeValue, 460, panel_y + 270, clrRed);
}

if (MoneyDriven)
  {
    label3 = CreateCustomLabel("Money1", " SL: $ " + DoubleToString(SL_Money, 2), 550, panel_y + 150, clrRed);
    label3 = CreateCustomLabel("Money2", " TP: $ " + DoubleToString(TP_Money, 2), 720, panel_y + 150, clrGreen);
   }
 
// Wolf Protect Disp
    string WolfProtectActive;
    if (activateWolfProtect || WolfNegativeHIT || WolfBreakEvenTrailHit) 
       {   WolfProtectActive = "Active";
           label3 = CreateCustomLabel("WolfProtectActive", WolfProtectActive, 85, panel_y + 710, clrBlue);
       }
     else {
           WolfProtectActive = "Inactive";
           label3 = CreateCustomLabel("WolfProtectActive", WolfProtectActive, 85, panel_y + 710, clrBlack);
          }
       
    string WolfProtectActiveText = "Wolf : ";
    label3 = CreateCustomLabel("WolfProtectActiveText", WolfProtectActiveText, 10, panel_y + 710, clrBlack);

    
    string WolfPnLText = "WPnL: " + DoubleToString(profitOrLoss, 2) 
                          + "   W+: " + WolfPositivePrice + "   W-: " + WolfNegativePrice + "   W-0: " + WolfBreakEven 
                          + "   W*: " + WolfStopPrice;
    label3 = CreateCustomLabel("WolfPnLText", WolfPnLText, 230, panel_y + 710, clrBlack);


    string WolfProtectEnabled;
    if (WolfProtectFlag == "Y") 
       {   WolfProtectEnabled = "Enabled";
           label3 = CreateCustomLabel("WolfProtectEnabled", WolfProtectEnabled, 180, panel_y + 750, clrBlue);
       }
     else {
           WolfProtectEnabled = "Disabled";
           label3 = CreateCustomLabel("WolfProtectEnabled", WolfProtectEnabled, 180, panel_y + 750, clrRed);
          }
       
    string WolfProtectText = "Wolf Protect: ";
    label3 = CreateCustomLabel("WolfProtectText", WolfProtectText, 10, panel_y + 750, clrBlack);



// Trend Disp  

// Loop through the trendArray to assign values to the individual strings
for (int i = 0; i < 6; i++) {
    switch (i) {
        case 0: // M1
            M1ADX = trendArray[i][0];
            M1FAN = trendArray[i][1];
            M1HA = trendArray[i][2];
            M1MA = trendArray[i][3];
            M1NRTR = trendArray[i][4];
            M1ZZ = trendArray[i][5];
            break;
        case 1: // M5
            M5ADX = trendArray[i][0];
            M5FAN = trendArray[i][1];
            M5HA = trendArray[i][2];
            M5MA = trendArray[i][3];
            M5NRTR = trendArray[i][4];
            M5ZZ = trendArray[i][5];
            break;
        case 2: // M15
            M15ADX = trendArray[i][0];
            M15FAN = trendArray[i][1];
            M15HA = trendArray[i][2];
            M15MA = trendArray[i][3];
            M15NRTR = trendArray[i][4];
            M15ZZ = trendArray[i][5];
            break;
        case 3: // M30
            M30ADX = trendArray[i][0];
            M30FAN = trendArray[i][1];
            M30HA = trendArray[i][2];
            M30MA = trendArray[i][3];
            M30NRTR = trendArray[i][4];
            M30ZZ = trendArray[i][5];
            break;
        case 4: // H1
            H1ADX = trendArray[i][0];
            H1FAN = trendArray[i][1];
            H1HA = trendArray[i][2];
            H1MA = trendArray[i][3];
            H1NRTR = trendArray[i][4];
            H1ZZ = trendArray[i][5];
            break;
        case 5: // H4
            H4ADX = trendArray[i][0];
            H4FAN = trendArray[i][1];
            H4HA = trendArray[i][2];
            H4MA = trendArray[i][3];
            H4NRTR = trendArray[i][4];
            H4ZZ = trendArray[i][5];
            break;
    }
}


    string ChartTrendText = "Overall Trend: ";
    label3 = CreateCustomLabel("ChartTrendText", ChartTrendText, 310, panel_y + 400, clrBlack);
    string ChartTrendText1 = TrendTextDisp;


    if (TrendTextDisp == "UPTREND")
      {
        label3 = CreateCustomLabel("ChartTrendText1", ChartTrendText1, 490, panel_y + 400, clrBlue);
      }
      else if (TrendTextDisp == "DOWNTREND")
      {
        label3 = CreateCustomLabel("ChartTrendText1", ChartTrendText1, 490, panel_y + 400, clrRed);
      }
      else 
      {
        label3 = CreateCustomLabel("ChartTrendText1", ChartTrendText1, 490, panel_y + 400, clrBlack);
      }
      
    
    string TrendMethodText1;
    if (TrendFollowMethod == "C") 
      {
        TrendMethodText1 = IntegerToString(TimeFrameLevelsUp);

      }
    else if (TrendFollowMethod == "O") 
      {
        TrendMethodText1 = "ALL";
      }
    string TrendMethodText = "Level UP: " + TrendMethodText1;
    label3 = CreateCustomLabel("TrendMethodText", TrendMethodText, 730, panel_y + 400, clrBlack);

    
    string TrendHeader1 = "M1    M5    M15     M30     H1     H4";
    label3 = CreateCustomLabel("TrendHeader1", TrendHeader1, 390, panel_y + 440, clrBlack);
    
    string OVChartTrendText = M1TrendText + "      " + M5TrendText + "       " + M15TrendText + "         " + M30TrendText
                               + "         " + H1TrendText + "       " + H4TrendText;
    label3 = CreateCustomLabel("OVChartTrendText", OVChartTrendText, 390, panel_y + 480, clrBlue);
    
// Display statements for ADX
string ADXText = "ADX";
label3 = CreateCustomLabel("ADXText", ADXText, 310, panel_y + 520, clrBlueViolet);
string ADXChartTrendText = M1ADX + "      " + M5ADX + "       " + M15ADX + "         " + M30ADX
                           + "         " + H1ADX + "       " + H4ADX;
label3 = CreateCustomLabel("ADXChartTrendText", ADXChartTrendText, 390, panel_y + 520, clrBlack);

// Display statements for FAN
string FANText = "FAN";
label3 = CreateCustomLabel("FANText", FANText, 310, panel_y + 550, clrBlueViolet);
string FANChartTrendText = M1FAN + "      " + M5FAN + "       " + M15FAN + "         " + M30FAN
                            + "         " + H1FAN + "       " + H4FAN;
label3 = CreateCustomLabel("FANChartTrendText", FANChartTrendText, 390, panel_y + 550, clrBlack);

// Display statements for Heiken Ashi (HA)
string HAText = "HA";
label3 = CreateCustomLabel("HAText", HAText, 310, panel_y + 580, clrBlueViolet);
string HAChartTrendText = M1HA + "      " + M5HA + "       " + M15HA + "         " + M30HA
                           + "         " + H1HA + "       " + H4HA;
label3 = CreateCustomLabel("HAChartTrendText", HAChartTrendText, 390, panel_y + 580, clrBlack);

// Display statements for Moving Average (MA)
string MAText = "MA";
label3 = CreateCustomLabel("MAText", MAText, 310, panel_y + 610, clrBlueViolet);
string MAChartTrendText = M1MA + "      " + M5MA + "       " + M15MA + "         " + M30MA
                           + "         " + H1MA + "       " + H4MA;
label3 = CreateCustomLabel("MAChartTrendText", MAChartTrendText, 390, panel_y + 610, clrBlack);

// Display statements for NRTR
string NRTRText = "NRTR";
label3 = CreateCustomLabel("NRTRText", NRTRText, 310, panel_y + 640, clrBlueViolet);
string NRTRChartTrendText = M1NRTR + "      " + M5NRTR + "       " + M15NRTR + "         " + M30NRTR
                             + "         " + H1NRTR + "       " + H4NRTR;
label3 = CreateCustomLabel("NRTRChartTrendText", NRTRChartTrendText, 390, panel_y + 640, clrBlack);

// Display statements for ZigZag (ZZ)
string ZZText = "ZZ";
label3 = CreateCustomLabel("ZZText", ZZText, 310, panel_y + 670, clrBlueViolet);
string ZZChartTrendText = M1ZZ + "      " + M5ZZ + "       " + M15ZZ + "         " + M30ZZ
                           + "         " + H1ZZ + "       " + H4ZZ;
label3 = CreateCustomLabel("ZZChartTrendText", ZZChartTrendText, 390, panel_y + 670, clrBlack);
    
    string tradeMode = TradeWithTrendFlag == "Y" ? "Y" : "N";
    
    string higherTFString = EnumToString((ENUM_TIMEFRAMES)higherTF);
    string ChartTimeDisp = StringSubstr(higherTFString, 7);
    string counterTrend = DoTheOpposite ? "Y" : "N";
    
    string TradeWithTrendText = "Follow Trend: " + tradeMode + " DoOpp: " + counterTrend;

    label3 = CreateCustomLabel("timeText", timeText, 200, panel_y + 10, clrBlueViolet);
    label3 = CreateCustomLabel("TradeWithTrendText", TradeWithTrendText, 315, panel_y + 220, clrBlack);
    string BuySellScoreText = "Score:       Buy: " + BuyScore + " Sell: " + SellScore;
    label3 = CreateCustomLabel("BuySellScoreText", BuySellScoreText, 310, panel_y + 80, clrBlueViolet);
    
    string ThresholdText = "Threshold: Buy: " + buyThreshold + " Sell: " + sellThreshold + " Opp: " + oppositeThreshold;
    label3 = CreateCustomLabel("ThresholdText", ThresholdText, 310, panel_y + 45, clrBlack);
    
    string AdxPeriodText = "ADX: " + DoubleToString(adx, 2) + "  +Di: " + DoubleToString((plusDi -minusDi), 2)
                                    + "  Threshold: " + DoubleToString(threshold, 2);
    label3 = CreateCustomLabel("AdxPeriodText", AdxPeriodText, 310, panel_y + 115, clrBlack);
}


TickInfo CalculateTickInfo(string symbol) {
    TickInfo info;

    // ✅ Hardcoded known instruments
    if (symbol == "XAUUSD") {
        info.tickValue = 1.0;
        info.tickSize = 0.01;
        info.contractSize = 100.0;
        info.point = 0.01;
        return info;
    }
    if (symbol == "BTCUSD") {
        info.tickValue = 0.01;
        info.tickSize = 0.01;
        info.contractSize = 1.0;
        info.point = 0.01;
        return info;
    }
    if (symbol == "EURUSD") {
        info.tickValue = 1.0;
        info.tickSize = 0.00001;
        info.contractSize = 100000.0;
        info.point = 0.00001;
        return info;
    }
    if (symbol == "USDJPY") {
        info.tickValue = 0.6771672739; // from your broker print
        info.tickSize = 0.001;
        info.contractSize = 100000.0;
        info.point = 0.001;
        return info;
    }
    if (symbol == "DJ30") {
        info.tickValue = 0.01;
        info.tickSize = 0.01;
        info.contractSize = 1.0;
        info.point = 0.01;
        return info;
    }

    // 🔄 Try to fetch from broker
    info.tickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    info.tickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    info.contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    info.point        = SymbolInfoDouble(symbol, SYMBOL_POINT);

    // ⚠️ Fallback warning
    if (info.tickValue <= 0 || info.tickSize <= 0 || info.contractSize <= 0 || info.point <= 0) {
        Print("⚠ Warning: Broker values are invalid for ", symbol, ". Manual fallback may be required.");
    }

    return info;
}
