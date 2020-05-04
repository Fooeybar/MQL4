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
extern string arrowCode="242,241";//Arrow Codes
enum _style_{Solid,Dash,Dot,DashDot,DashDotDot};
extern _style_ style=2;//Style
enum _width_{One=1,Two=2,Three=3,Four=4,Five=5};
extern _width_ width=1;//Width
extern color colourUpper=clrMediumTurquoise;//Upper Colour
extern color colourLower=clrViolet;//Lower Colour
enum ny{No,Yes};
extern ny thurFri=1;//Use Th/Fr Trigger
double upper[],lower[];
#define none -1
#define daySeconds 86400
#define dayMinutes 1440
#define weekMinutes 10080
#define Th 4
#define Fr 5
#define upperLabel "Previous Week High"
#define lowerLabel "Previous Week Low"

int init(){
   if(lbk>0){SetIndexDrawBegin(0,type==3?Bars-lbk:Bars-1-lbk);SetIndexDrawBegin(1,type==3?Bars-lbk:Bars-1-lbk);}
   if(type==3){string temp[];StringSplit(arrowCode,',',temp);
      int code2=ArraySize(temp)==2?(int)temp[1]:(int)temp[0];
      SetIndexArrow(0,(int)temp[0]);SetIndexArrow(1,code2);}
   SetIndexBuffer(0,upper);SetIndexStyle(0,type,style,width,colourUpper);SetIndexLabel(0,"Week Hi");
   SetIndexBuffer(1,lower);SetIndexStyle(1,type,style,width,colourLower);SetIndexLabel(1,"Week Lo");
   return 0;}
   
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   if(rates_total==prev_calculated)return rates_total;
   bool flag=false;
   double hi=0,lo=1000000000000;
   for(int i=daySeconds+(int)iTime(NULL,weekMinutes,1),end=(int)iTime(NULL,weekMinutes,0);i<end;i+=daySeconds){
      int day=iBarShift(NULL,dayMinutes,(datetime)i,true);
      int altDay=iBarShift(NULL,dayMinutes,(datetime)i,false);
      double tempHi=iHigh(NULL,dayMinutes,altDay),tempLo=iLow(NULL,dayMinutes,altDay);
      int tempDay=TimeDayOfWeek((datetime)i);
      if(hi<tempHi){hi=tempHi;
         if(day>-1)if(tempDay==Th||tempDay==Fr)flag=true;
         }
      if(lo>tempLo){lo=tempLo;
         if(day>-1)if(tempDay==Th||tempDay==Fr)flag=true;
         }
      }
   if(flag||!thurFri){fillArray(upper,hi);fillArray(lower,lo);setLabels(hi,lo);}
   else{fillArray(upper,none);fillArray(lower,none);setLabels(none,none);}
   return rates_total;}

void fillArray(double &arr[],double val){for(int i=0,len=ArraySize(arr);i<len;i++)arr[i]=val;}

void setLabels(double hi,double lo){
   if(hi==none&&lo==none){
      ObjectDelete(0,);
      ObjectDelete(0,);
      return;}
   //if(ObjectCreate(0,upperLabel,OBJ_LABEL,0,
   
   
   }
ChartXYToTimePrice
   
   
   
   
   
   
   
   









