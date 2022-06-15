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
      double tr = ATRValue(true);
      double atr = ATRValue(false);
      
      /* 
      É realizada a compra se a média rápida cruza a média lenta para cima,
      se o volume de negociações está crescente, 
      e se o indicador RSI não está em região de sobrecompra. 
      */
      if (MovingAverageCross() == 1 && IsVolumeIncreasing() && RsiValue() < 70 && tr < atr) {
         trade.Buy(200, _Symbol, 0, 0, 0, "Ordem de compra");
      }

      /* 
      É realizada a venda se a média rápida cruza a média lenta para baixo,
      se o volume de negociações está decrescente, 
      e se o indicador RSI não está em região de sobrevenda. 
      */
      else if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
         //venda
         if (MovingAverageCross() == -1 && !IsVolumeIncreasing() && RsiValue() > 30 ){
            trade.Sell(200, _Symbol, 0, 0, 0, "Ordem de Venda");
         }
      }
      
  }
   
  }

// Verifica se é novo candle.
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

/*
Analisa o preço de fechamento de candles,
cria uma média móvel rápida considerando 5 candles,
uma média móvel lenta considerando 20 candles,
e retorna 1 se: média rápida cruza a média lenta para cima,
retorna -1 se: média rápida cruza a média lenta para baixo,
retorna 0 se: não houve cruzamento de médias.
*/
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
      // média rapida cruza a média lenta para cima
      return 1;
   }
   else if (bufferMMRapida[2] > bufferMMLenta[2] && bufferMMRapida[1] < bufferMMLenta[1]){
      // média rapida cruza a média lenta para baixo
      return -1;
   }
   else{
      // não houve cruzamento
      return 0;
   }
   
}

/*
Analisa se o valor atual do OBV é maior que o valor dos últimos 5 pontos do indicador
retorna true se é maior, indicando volume crescente
retorna false se não é maior, indicando volume não crescente.
*/
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

/*
Acessa e retorna o valor mais atual do indicador RSI,
considerando um período de 14 candles.
*/
double RsiValue()
{
   int handleRSI;
   double bufferRSI[];
   
   handleRSI = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   
   CopyBuffer(handleRSI, 0, 0, 2, bufferRSI);
   ArraySetAsSeries(bufferRSI, true);
   
   return bufferRSI[0];
}

double ATRValue(bool flag)
{
   if(flag){
      int handleATR;
      double bufferATR[];
      
      handleATR = iATR(_Symbol, _Period, 14);
      
      CopyBuffer(handleATR, 0, 0, 14, bufferATR);
      ArraySetAsSeries(bufferATR, true);
      
      return bufferATR[0];
   }
   else{
      double tr = fmax(candle[1].high, candle[2].close) - fmin(candle[1].low, candle[2].close);
      return tr;
   }
}