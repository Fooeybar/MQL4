//SDG
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property copyright "Copyright 2 May 2020, FooeyBar/Beerrun"
#property link      "https://www.forexfactory.com/beerrun"

enum _tf_ {Current,M1=1,M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440,W1=10080,MH1=43200};
enum _type_{Line,
           Arrow=3//Arrow
           };
enum _style_{Solid,Dash,Dot,DashDot,DashDotDot};
enum _width_{One=1,Two=2,Three=3,Four=4,Five=5};
extern int lbk=50;//Display Length
extern _tf_ timeframe=0;//Timeframe
extern _type_ type=0;//Type
extern string arrowCode="242,241";//Arrow Codes
extern _style_ style=2;//Style
extern _width_ width=1;//Width
extern color colourUpper=clrMediumTurquoise;//Upper Colour
extern color colourLower=clrViolet;//Lower Colour
double upper[],lower[];

int init(){
   if(lbk>0){SetIndexDrawBegin(0,Bars-lbk);SetIndexDrawBegin(1,Bars-lbk);}
   if(type==3){
      string temp[];
      StringSplit(arrowCode,',',temp);
      int code2=ArraySize(temp)==2?(int)temp[1]:(int)temp[0];
      SetIndexArrow(0,(int)temp[0]);SetIndexArrow(1,code2);}
   SetIndexBuffer(0,upper);SetIndexStyle(0,type,style,width,colourUpper);SetIndexLabel(0,"Current Hi");
   SetIndexBuffer(1,lower);SetIndexStyle(1,type,style,width,colourLower);SetIndexLabel(1,"Current Lo");
   fillArray(upper,iHigh(NULL,timeframe,0));fillArray(lower,iLow(NULL,timeframe,0));
   return 0;}
   
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   if(rates_total==prev_calculated)return rates_total;
   double hi=iHigh(NULL,timeframe,0),lo=iLow(NULL,timeframe,0);
   if(upper[0]!=hi)fillArray(upper,hi);
   if(lower[0]!=lo)fillArray(lower,lo);
   return rates_total;}

void fillArray(double &arr[],double val){for(int i=0,len=ArraySize(arr);i<len;i++)arr[i]=val;}


