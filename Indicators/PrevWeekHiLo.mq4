//SDG
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property copyright "Copyright 2 May 2020, FooeyBar/Beerrun"
#property link      "https://www.forexfactory.com/beerrun"

enum ny{No,Yes};
extern ny thurFri=1;//Use Th/Fr Trigger
enum _style_{Solid,Dash,Dot,DashDot,DashDotDot};
extern _style_ style=2;//Style
enum _width_{One=1,Two=2,Three=3,Four=4,Five=5};
extern _width_ width=1;//Width
extern color upperColour=clrMediumTurquoise;//Upper Colour
extern color lowerColour=clrViolet;//Lower Colour
double upperBuffer[],lowerBuffer[];

#define none -1
#define daySeconds 86400
#define dayMinutes 1440
#define weekMinutes 10080
#define Th 4
#define Fr 5
#define upper "Previous Week High"
#define lower "Previous Week Low"

int init(){
   SetIndexBuffer(0,upperBuffer);SetIndexStyle(0,0,style,width,upperColour);SetIndexLabel(0,upper);
   SetIndexBuffer(1,lowerBuffer);SetIndexStyle(1,0,style,width,lowerColour);SetIndexLabel(1,lower);
   return 0;}
   
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   if(rates_total==prev_calculated)return rates_total;
   bool flag=false;
   datetime hiTime=0,loTime=0;
   double hi=0,lo=1000000000000;
   for(int i=daySeconds+(int)iTime(NULL,weekMinutes,1),end=(int)iTime(NULL,weekMinutes,0);i<end;i+=daySeconds){
      int day=iBarShift(NULL,dayMinutes,(datetime)i,true);
      int altDay=iBarShift(NULL,dayMinutes,(datetime)i,false);
      double tempHi=iHigh(NULL,dayMinutes,altDay),tempLo=iLow(NULL,dayMinutes,altDay);
      int tempDay=TimeDayOfWeek((datetime)i);
      if(hi<tempHi){hi=tempHi;hiTime=(datetime)i;
         if(day>-1)if(tempDay==Th||tempDay==Fr)flag=true;
         }
      if(lo>tempLo){lo=tempLo;loTime=(datetime)i;
         if(day>-1)if(tempDay==Th||tempDay==Fr)flag=true;
         }
      }
   if(flag||!thurFri){fillArray(0,upperBuffer,hi,hiTime);fillArray(1,lowerBuffer,lo,loTime);setLabels(hi,lo,time[0]);}
   else{fillArray(0,upperBuffer,none,0);fillArray(1,lowerBuffer,none,0);setLabels(none,none);}
   return rates_total;}

void OnDeinit(const int re){setLabels(none,none);}

void fillArray(int buff,double &arr[],double val,datetime time){
   int idx=iBarShift(NULL,0,time);
   for(int i=ArraySize(arr)-1;i>=0;i--)arr[i]=val;
   if(val!=none)SetIndexShift(buff,Bars-1-idx);
      }
   
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam){
   if(ArraySize(upperBuffer)>0&&ArraySize(lowerBuffer)>0)if(upperBuffer[0]!=none&&lowerBuffer[0]!=none)setLabels(upperBuffer[0],lowerBuffer[0],Time[0]);
   }
   
void setLabels(double hi,double lo,datetime time=0){
   if(hi==none&&lo==none){ObjectDelete(0,upper);ObjectDelete(0,lower);return;}
   
   int vis=(int)ChartGetInteger(0,CHART_VISIBLE_BARS),wid=(int)ChartGetInteger(0,CHART_WIDTH_IN_BARS);
   datetime timeAdj=time+PeriodSeconds()*(wid-vis);
   
   if(ObjectFind(upper)<0)if(!ObjectCreate(0,upper,OBJ_TEXT,0,timeAdj,hi)){Print("ObjectCreate Fail: upper / Error: "+(string)GetLastError());return;}
   if(ObjectFind(lower)<0)if(!ObjectCreate(0,lower,OBJ_TEXT,0,timeAdj,lo)){Print("ObjectCreate Fail: lower / Error: "+(string)GetLastError());return;}
   
   ObjectSetInteger(0,upper,OBJPROP_TIME,timeAdj);
   ObjectSetDouble(0,upper,OBJPROP_PRICE,hi);
   ObjectSetText(upper,upper,10,"Arial",upperColour);
   ObjectSetInteger(0,upper,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,upper,OBJPROP_SELECTABLE,0);
   
   ObjectSetInteger(0,lower,OBJPROP_TIME,timeAdj);
   ObjectSetDouble(0,lower,OBJPROP_PRICE,lo);
   ObjectSetText(lower,lower,10,"Arial",lowerColour);
   ObjectSetInteger(0,lower,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,lower,OBJPROP_SELECTABLE,0);
   }
