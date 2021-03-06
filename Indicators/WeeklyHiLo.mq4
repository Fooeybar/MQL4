//SDG
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property copyright "Copyright 2 May 2020, FooeyBar/Beerrun"
#property link      "https://www.forexfactory.com/beerrun"

extern color colourUpper=clrMediumTurquoise;//Upper Colour
extern color colourLower=clrViolet;//Lower Colour
double upper[],lower[];

int init(){
   SetIndexBuffer(0,upper);SetIndexStyle(0,0,0,1,colourUpper);
   SetIndexBuffer(1,lower);SetIndexStyle(1,0,0,1,colourLower);
   double hi=iHigh(NULL,10080,0),lo=iLow(NULL,10080,0);
   fillArray(upper,hi);fillArray(lower,lo);
   return 0;}
   
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   if(rates_total==prev_calculated)return 0;
   double hi=iHigh(NULL,10080,0),lo=iLow(NULL,10080,0);
   if(upper[0]!=hi)fillArray(upper,hi);
   if(lower[0]!=lo)fillArray(lower,lo);
   return rates_total;}

void fillArray(double &arr[],double val){for(int i=0,len=ArraySize(arr);i<len;i++)arr[i]=val;}