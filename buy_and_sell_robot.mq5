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
      double tr = ATRValue(1);
      double atr = ATRValue(14);
      
      // minTick guarda quantidade mínima de ticks/pontos que um ativo pode se mover
      double minTick = SymbolInfoDouble(Symbol() , SYMBOL_TRADE_TICK_SIZE);
      
      /* 
      É realizada a compra se a média rápida cruza a média lenta para cima,
      se o volume de negociações está crescente, 
      se o indicador RSI não está em região de sobrecompra,
      e também se o valor do TR no candle atual é menor que o ATR, média dos TR's.
      Além disso, é definido um valor de stop loss a partir do indicador de volatilidade ATR.
      O valor de stop loss é arredondado para respeitar o minTick do ativo considerado.
      */
      if (MovingAverageCross() == 1 && IsVolumeIncreasing() && RsiValue() < 70 && tr < atr) {
         double stopLossValue = candle[1].close - tr * 2;
         stopLossValue = MathRound(stopLossValue/minTick) * minTick;
         trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, 200, 0, stopLossValue, 0, "Ordem de compra");
      }

      /* 
      É realizada a venda se a média rápida cruza a média lenta para baixo,
      se o volume de negociações está decrescente, 
      se o indicador RSI não está em região de sobrevenda,
      e se o valor do TR for maior ou igual ao do ATR, que é o contrário da lógica de compra.
      */
      else if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
         if (MovingAverageCross() == -1 && !IsVolumeIncreasing() && RsiValue() > 30 && tr >= atr){
            //venda planejada
            trade.Sell(200, _Symbol, 0, 0, 0, "Ordem de Venda");
         }
         else{
            //modifica valor de stop loss em posição existente

            double newStopLossValue = candle[1].close - tr * 2;
            //O valor de stop loss é arredondado para respeitar o minTick do ativo considerado
            newStopLossValue = MathRound(newStopLossValue/minTick) * minTick;
            //Só modifica valor de stop loss se ele for maior que o stop loss atual e se ele for menor que o preço atual do ativo considerado
            if ( newStopLossValue > PositionGetDouble(POSITION_SL) && newStopLossValue < PositionGetDouble(POSITION_PRICE_CURRENT)){
               trade.PositionModify(_Symbol, newStopLossValue, 0);
            }
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

/*
Acessa e retorna o valor mais atual do indicador de volatilidade ATR,
considerando um período determinado como parâmetro. Usamos ou um período de 1 candle,
ou de 14 candles, que é o padrão.
*/
double ATRValue(int period_size)
{
   int handleATR;
   double bufferATR[];
   
   handleATR = iATR(_Symbol, _Period, period_size);
   
   CopyBuffer(handleATR, 0, 0, 2, bufferATR);
   ArraySetAsSeries(bufferATR, true);
   
   return bufferATR[1];
}