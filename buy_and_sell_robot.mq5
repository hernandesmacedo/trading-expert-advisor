#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
int OnInit()
  {
   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   
  }
void OnTick()
  {
   
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
