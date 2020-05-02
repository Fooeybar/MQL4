#property copyright "Copyright 29 June 2019, R. M."
#property link      "https://www.forexfactory.com/beerrun"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2

enum _gl {greater,//Greater Than
          less//Less Than
          };
enum hgt {EMA,Points};
extern _gl GL=0;//Greater/Less
extern double RATIO=50;//Ratio
extern hgt HGT=0;//Dots Placement
extern int PER=7;//Dot Height/ EMA Period
extern color UPCLR=clrMediumTurquoise;//Up Colour
extern color DWCLR=clrViolet;//Down Colour

double UP[],DW[];
long temp=0,scale=ChartGetInteger(0,CHART_SCALE);

int init(){
  SetIndexBuffer(0,UP);SetIndexArrow(0,159);SetIndexStyle(0,3,0,(int)scale-1,UPCLR);SetIndexLabel(0,NULL);
  SetIndexBuffer(1,DW);SetIndexArrow(1,159);SetIndexStyle(1,3,0,(int)scale-1,DWCLR);SetIndexLabel(1,NULL);
  EventSetTimer(1);
  return(0);}

void OnTimer(){
  temp=ChartGetInteger(0,CHART_SCALE);  
  if(temp!=scale){
   SetIndexStyle(0,3,0,(int)temp-1,UPCLR);
   SetIndexStyle(1,3,0,(int)temp-1,DWCLR);
   scale=temp;
   ChartRedraw(0);}}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){

  for(int i=rates_total-prev_calculated-1;i>=0;i--){
   double candle=(high[i]-low[i]),body=fabs(close[i]-open[i]);
   if(!GL)if((body/(candle+_Point))>RATIO*0.01){
     if(close[i]>open[i]){
      if(HGT==0)UP[i]=iMA(NULL,0,PER,0,MODE_EMA,PRICE_MEDIAN,i);
      else UP[i]=high[i]+(PER*_Point);}
     if(close[i]<open[i]){
      if(HGT==0)DW[i]=iMA(NULL,0,PER,0,MODE_EMA,PRICE_MEDIAN,i);
      else DW[i]=high[i]+(PER*_Point);}}
   if(GL)if((body/(candle+_Point))<RATIO*0.01){
     if(close[i]>open[i]){
      if(HGT==0)UP[i]=iMA(NULL,0,PER,0,MODE_EMA,PRICE_MEDIAN,i);
      else UP[i]=high[i]+(PER*_Point);}
     if(close[i]<open[i]){
      if(HGT==0)DW[i]=iMA(NULL,0,PER,0,MODE_EMA,PRICE_MEDIAN,i);
      else DW[i]=high[i]+(PER*_Point);}}}
  return(rates_total);}

