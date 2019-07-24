//+------------------------------------------------------------------+
//|                                                  Portuguese.mq5  |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                              drenjanind@mail.ru  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include   <Trade\Trade.mqh>
#include   <Trade\SymbolInfo.mqh> 
#include   <Trade\PositionInfo.mqh>

CSymbolInfo    _symbol;
CTrade         trade;
CPositionInfo  _position; 
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
input int                        ma_period= 5;                              // MA period
input int                        ma_shift = 6;                              // change shift, 0 is current point
input int                        ma_period2= 10;                            // MA period 2
input int                        ma_shift2 = 2;                             // change shift 2, 0 is current point
input int                        ma_period3= 15;                            // MA period 3
input int                        ma_shift3 = 3;                             // change shift 3, 0 is current point
input int                        ma_period4= 20;                            // MA period 4
input int                        ma_shift4 = 4;                             // change shift 4, 0 is current point
input int                        ma_period5= 25;                            // MA period 5
input int                        ma_shift5 = 5;                             // change shift 5, 0 is current point
input ulong                      magic_number=191817;                       // magic number
input ulong                      dev_point = 10;                            // deviations point
input ENUM_MA_METHOD             ma_method = MODE_SMA;                      // MA method
input ENUM_APPLIED_PRICE         ma_price=PRICE_CLOSE;                      // MA price type
input ENUM_MA_METHOD             ma_method2 = MODE_SMA;                     // MA method
input ENUM_APPLIED_PRICE         ma_price2=PRICE_CLOSE;                     // MA price type
input ENUM_MA_METHOD             ma_method3 = MODE_SMA;                     // MA method
input ENUM_APPLIED_PRICE         ma_price3=PRICE_CLOSE;                     // MA price type
input ENUM_MA_METHOD             ma_method4 = MODE_SMA;                     // MA method
input ENUM_APPLIED_PRICE         ma_price4=PRICE_CLOSE;                     // MA price type
input ENUM_MA_METHOD             ma_method5 = MODE_SMA;                     // MA method
input ENUM_APPLIED_PRICE         ma_price5=PRICE_CLOSE;                     // MA price type
input ENUM_ORDER_TYPE_FILLING    order_type_filling=ORDER_FILLING_RETURN;   // choose order filling type
input double                     lot=0.01;                                  // volume
input ushort                     stop_loss=500;                             // stop loss in point
input ushort                     take_profit=500;                           // take profit in point
input ushort                     break_even=5;                              // break even in point
input ushort                     trailing_stop = 6;                         // trailing stop in point
input ushort                     trailing_step = 2;                         // trailing step in point
//---
double          PRC;
double          STL;
double          TKP;           
double          adjusted_point;
double          ask,bid,last;
double          smaArray[];
int             smaHandle;
double          smaArray2[];
int             smaHandle2;
double          smaArray3[];
int             smaHandle3;
double          smaArray4[];
int             smaHandle4;
double          smaArray5[];
int             smaHandle5;
//---
MqlTick         last_tick;
MqlRates        rates[];
MqlDateTime     _time;
//+------------------------------------------------------------------+
//|If you want to use this option , just replace the lot with Dynamic|
//|Position Size in the trade function below.                        |
//+------------------------------------------------------------------+
double Balance= AccountInfoDouble(ACCOUNT_BALANCE);
double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
//double DynamicPositionSize = NormalizeDouble((Equity/1000000),2);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   smaHandle=iMA(_Symbol,_Period,ma_period,ma_shift,ma_method,ma_price);
   if (smaHandle==INVALID_HANDLE){
      Print(" Greska prilikom kreiranja indikatora Moving Averidz - greska  ",GetLastError());
      return(INIT_FAILED);
   }
   ArraySetAsSeries(smaArray,true);
//---
   smaHandle2=iMA(_Symbol,_Period,ma_period2,ma_shift2,ma_method2,ma_price2);
   if (smaHandle2==INVALID_HANDLE){
      Print(" Greska prilikom kreiranja indikatora Moving Averidz - greska  ",GetLastError());
      return(INIT_FAILED);
   }
   ArraySetAsSeries(smaArray2,true);
//---
   smaHandle3=iMA(_Symbol,_Period,ma_period3,ma_shift3,ma_method3,ma_price3);
   if (smaHandle3==INVALID_HANDLE){
      Print(" Greska prilikom kreiranja indikatora Moving Averidz - greska  ",GetLastError());
      return(INIT_FAILED);
   }
   ArraySetAsSeries(smaArray3,true);
//---
   smaHandle4=iMA(_Symbol,_Period,ma_period4,ma_shift4,ma_method4,ma_price4);
   if (smaHandle4==INVALID_HANDLE){
      Print(" Greska prilikom kreiranja indikatora Moving Averidz - greska  ",GetLastError());
      return(INIT_FAILED);
   }
   ArraySetAsSeries(smaArray4,true);
//---
   smaHandle5=iMA(_Symbol,_Period,ma_period5,ma_shift5,ma_method5,ma_price5);
   if (smaHandle5==INVALID_HANDLE){
      Print(" Greska prilikom kreiranja indikatora Moving Averidz - greska  ",GetLastError());
      return(INIT_FAILED);
   }
   ArraySetAsSeries(smaArray5,true);
//---  
   ArraySetAsSeries(rates,true);
//---
   trade.SetTypeFilling(order_type_filling);
   trade.SetDeviationInPoints(dev_point);
   trade.SetExpertMagicNumber(magic_number);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   last= NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST), _Digits);
//---
   if (SymbolInfoTick(Symbol(),last_tick)){
      Print(last_tick.time,": Bid = ",last_tick.bid," Ask = ",last_tick.ask,"  Volume = ",last_tick.volume);
      }
   else{
      Print("Error getting price information - error:  ",GetLastError());
      }
//---
   if (CopyRates(_Symbol,_Period,0,10,rates)<0){
      Print(" Error getting copying data - error:  ",GetLastError());
      }
   else{
      Print("Price data copied successfully for  ",ArraySize(rates),"  candles");
      }
//---
   if (CopyBuffer(smaHandle,0,0,3,smaArray)<0){
      Print("Error getting information from MA indicator (smaHandle)- error warning:  ",GetLastError());
      }
   else{
      Print("smaArray of Moving Average successfully created");
      }  
   if (CopyBuffer(smaHandle2,0,0,3,smaArray2)<0){
      Print("Error getting information from MA indicator (smaHandle2) - error warning:   ",GetLastError());
      }
   else{
      Print("smaArray2 of Moving Average successfully created");
      }  
   if (CopyBuffer(smaHandle3,0,0,3,smaArray3)<0){
      Print("Error getting information from MA indicator (smaHandle3) - error warning:  ",GetLastError());
      }
   else{
      Print("smaArray3 of Moving Average successfully created");
      }
   if (CopyBuffer(smaHandle4,0,0,3,smaArray4)<0){
      Print("Error getting information from MA indicator (smaHandle4) - error warning:  ",GetLastError());
      }
   else{
      Print("smaArray4 of Moving Average successfully created");
      }
   if (CopyBuffer(smaHandle5,0,0,3,smaArray5)<0){
      Print("Error getting information from MA indicator (smaHandle5) - error warning:  ",GetLastError());
      }
   else{
      Print("smaArray5 of Moving Average successfully created");
      }  
//---
   bool up_trend= last_tick.last > smaArray5[0] &&
                  smaArray[0] > smaArray5[0] &&
                  rates[0].close > rates[1].close;
                  
   bool dow_trend= last_tick.last < smaArray5[0] && 
                  smaArray[0] < smaArray5[0] &&
                  rates[0].close < rates[1].close;
//---
   if (up_trend  && PositionsTotal() < 1){
      PRC = NormalizeDouble(last_tick.ask, _Digits);
      STL = NormalizeDouble(PRC - stop_loss * _Point, _Digits);
      TKP = NormalizeDouble(PRC + take_profit * _Point, _Digits);
   if (trade.Buy(lot,_Symbol,PRC,STL,TKP,"")){
      Print("Successful open buy position. ResultRetcode: ",trade.ResultRetcode(),"RetcodeDescription: ",trade.ResultRetcodeDescription());
      }
   else{
      Print("Open buy position failed. ResultRetcode: ",trade.ResultRetcode(),"\nRetcodeDescription: ",trade.ResultRetcodeDescription());
      }
   }
//---
   if (dow_trend &&  PositionsTotal() < 1 ){
      
      PRC = NormalizeDouble(last_tick.bid, _Digits);
      STL = NormalizeDouble(PRC + stop_loss * _Point, _Digits);
      TKP = NormalizeDouble(PRC - take_profit * _Point, _Digits);
      if (trade.Sell(lot,_Symbol,PRC,STL,TKP,"")){
         Print("Successful open sell position. ResultRetcode: ",trade.ResultRetcode(),"RetcodeDescription: ",trade.ResultRetcodeDescription());
         }
         else{
         Print("Open sell position failed. ResultRetcode: ",trade.ResultRetcode(),"RetcodeDescription: ",trade.ResultRetcodeDescription());
         }
   }
   BreakEven(last_tick.last);
   TrailingStop(last_tick.last);
}
//+--------------------------------------------------------------------+
//TRAILING STOOP                                                       |
//+--------------------------------------------------------------------+
void TrailingStop(double price){ 
   for (int i = PositionsTotal()-1; i>=0; i--){
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (symbol==_Symbol && magic == magic_number){
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         double StopLossCurr = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits); 
         double TakeProfitCurr = NormalizeDouble(PositionGetDouble(POSITION_TP),_Digits);
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            price=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
             if (price > ( StopLossCurr + trailing_stop * _Point)){
                double newSL = NormalizeDouble((StopLossCurr + trailing_step * _Point),_Digits);
               if (trade.PositionModify(PositionTicket, newSL, TakeProfitCurr)){
                  Print("TrainingStop has successfully modified position buy. ResultRetcode:  ", trade.ResultRetcode(), ",  RetcodeDescription: ", trade.ResultRetcodeDescription());             
               }
               else{
                     Print("TrailingStop Error- modification of buy position failed. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
               }
            }
         }
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  price =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
                  if ( price < ( StopLossCurr - trailing_stop * _Point)){
                       double newSL = NormalizeDouble((StopLossCurr - trailing_step * _Point),_Digits);
                     if (trade.PositionModify(PositionTicket, newSL, TakeProfitCurr)){
                           Print("TrainingStop has successfully modified position sell. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                     }
                     else{
                           Print("TrailingStop Error- modification of sell position failed. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                        }
                  }
         }
      }
   }
}
//+--------------------------------------------------------------------+
//BREAK EVEN STOP                                                      |
//+--------------------------------------------------------------------+
void BreakEven(double price){
   for (int i=PositionsTotal()-1; i>=0; i--){
         string symbol=PositionGetSymbol(i);
         ulong magic=PositionGetInteger(POSITION_MAGIC);
         if (symbol==_Symbol && magic==magic_number){
         ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
         double PriceEntry=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
         double CurrentTakeProfit=NormalizeDouble(PositionGetDouble(POSITION_TP),_Digits);
         if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
            price=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
            if (price > (PriceEntry + break_even * _Point)){
               if (trade.PositionModify(PositionTicket,PriceEntry,CurrentTakeProfit)){
                  Print("BreakEven has successfully modified position buy. ResultRetcode: ",trade.ResultRetcode(),", RetcodeDescription: ",trade.ResultRetcodeDescription());
               }
               else{
                  Print("BreakEven - modification of  buy position failed. ResultRetcode: ",trade.ResultRetcode(),", RetcodeDescription: ",trade.ResultRetcodeDescription());
               }
            }
      }
         if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
               price =NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
                if (price < (PriceEntry - break_even * _Point)){
                  if (trade.PositionModify(PositionTicket,PriceEntry,CurrentTakeProfit)){
                     Print("BreakEven has successfully modified position sell. ResultRetcode: ",trade.ResultRetcode(),", RetcodeDescription: ",trade.ResultRetcodeDescription());
                  }
                  else{
                        Print("BreakEven- modification of  sell position failed. ResultRetcode: ",trade.ResultRetcode(),", RetcodeDescription: ",trade.ResultRetcodeDescription());
                     }
                  }
      }
      }
   }
}
//+------------the end---------------------------------------------+
