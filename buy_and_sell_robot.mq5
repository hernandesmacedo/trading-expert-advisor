#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

MqlRates candle[];

CTrade trade;

int OnInit()
  {
   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   
  }
void OnTick()
  {
  if (IsNewCandle()){
      CopyRates(_Symbol, _Period, 0, 20, candle);
      ArraySetAsSeries(candle, true);
      
      if (MovingAverageCross() == 1 && IsVolumeIncreasing() && RsiValue() < 70 ) {
         trade.Buy(100, _Symbol, 0, 0, 0, "Ordem de compra");
      }
      else if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
         //venda
         if (MovingAverageCross() == -1 && !IsVolumeIncreasing() && RsiValue() > 30 ){
            trade.Sell(100, _Symbol, 0, 0, 0, "Ordem de Venda");
         }
      }
      
  }
   
  }

bool IsNewCandle() 
{
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   if(last_time==0)
   {
      last_time=lastbar_time;
      return false;
   }
   if(last_time!=lastbar_time)
   {
      last_time=lastbar_time;
      return true;
   }
   return false;
}

int MovingAverageCross()
{

   int handleMMRapida;
   double bufferMMRapida[];
   
   int handleMMLenta;
   double bufferMMLenta[];
   
   handleMMRapida = iMA(_Symbol, _Period, 5, 0, MODE_SMA, PRICE_CLOSE);
   handleMMLenta = iMA(_Symbol, _Period, 20, 0, MODE_SMA, PRICE_CLOSE);
   
   CopyBuffer(handleMMRapida, 0, 0, 5, bufferMMRapida);
   ArraySetAsSeries(bufferMMRapida, true);
   
   CopyBuffer(handleMMLenta, 0, 0, 5, bufferMMLenta);
   ArraySetAsSeries(bufferMMLenta, true);
   
   if (bufferMMRapida[2] < bufferMMLenta[2] && bufferMMRapida[1] > bufferMMLenta[1]){
      // media rapida cruza a media lenta para cima
      return 1;
   }
   else if (bufferMMRapida[2] > bufferMMLenta[2] && bufferMMRapida[1] < bufferMMLenta[1]){
      // media rapida cruza a media lenta para baixo
      return -1;
   }
   else{
      // não houve cruzamento
      return 0;
   }
   
}

bool IsVolumeIncreasing()
{
   int handleOBV;
   double bufferOBV[];
   
   handleOBV = iOBV(_Symbol, _Period, VOLUME_TICK);
   
   CopyBuffer(handleOBV, 0, 0, 7, bufferOBV);
   ArraySetAsSeries(bufferOBV, true);
   
   for(int i = 2; i < ArraySize(bufferOBV); i++){
      if ( bufferOBV[1] < bufferOBV[i] ){
         return false;
      }
   }
   
   return true;
}

double RsiValue()
{
   int handleRSI;
   double bufferRSI[];
   
   handleRSI = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   
   CopyBuffer(handleRSI, 0, 0, 2, bufferRSI);
   ArraySetAsSeries(bufferRSI, true);
   
   return bufferRSI[0];
}