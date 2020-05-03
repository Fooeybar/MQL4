//SDG
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property copyright "Copyright 2 May 2020, FooeyBar/Beerrun"
#property link      "https://www.forexfactory.com/beerrun"

extern int lbk=50;//Display Length
enum _type_{Line,
           Arrow=3//Arrow
           };
extern _type_ type=0;//Type
enum _style_{Solid,Dash,Dot,DashDot,DashDotDot};
extern _style_ style=2;//Style
enum _width_{One=1,Two=2,Three=3,Four=4,Five=5};
extern _width_ width=1;//Width
extern color colourUpper=clrMediumTurquoise;//Upper Colour
extern color colourLower=clrViolet;//Lower Colour
enum ny{No,Yes};
extern ny thurFri=1;//Use Th/Fr Trigger
double upper[],lower[];

int init(){
   if(lbk>0){SetIndexDrawBegin(0,Bars-lbk);SetIndexDrawBegin(1,Bars-lbk);}
   if(type==3){SetIndexArrow(0,242);SetIndexArrow(1,241);}
   SetIndexBuffer(0,upper);SetIndexStyle(0,type,style,width,colourUpper);SetIndexLabel(0,"Week Hi");
   SetIndexBuffer(1,lower);SetIndexStyle(1,type,style,width,colourLower);SetIndexLabel(1,"Week Lo");
   return 0;}
   
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   if(rates_total==prev_calculated)return rates_total;
   bool flag=false;
   double hi=0,lo=1000000000000;
   for(int i=(int)iTime(NULL,10080,1),end=(int)iTime(NULL,10080,0);i<end;i+=86400){
      int day=iBarShift(NULL,1440,(datetime)i,true);
      int altDay=iBarShift(NULL,1440,(datetime)i,false);
      double tempHi=iHigh(NULL,1440,altDay),tempLo=iLow(NULL,1440,altDay);
      int tempDay=TimeDayOfWeek((datetime)i);
      if(hi<tempHi){hi=tempHi;
         if(day>-1)if(tempDay==4||tempDay==5)flag=true;
         }
      if(lo>tempLo){lo=tempLo;
         if(day>-1)if(tempDay==4||tempDay==5)flag=true;
         }
      }
   if(flag||!thurFri){fillArray(upper,hi);fillArray(lower,lo);}
   else{fillArray(upper,-1);fillArray(lower,-1);}
   return rates_total;}

void fillArray(double &arr[],double val){for(int i=0,len=ArraySize(arr);i<len;i++)arr[i]=val;}



   
   
   
   
   
   
   
   









