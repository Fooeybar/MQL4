//SDG
#define NAME MQLInfoString(MQL_PROGRAM_NAME)
#property copyright "Copyright 14 September 2019, Beerrun (R.M.)"
#property link      "https://www.mql5.com/en/users/beerrun"
#property version   "2.00"
#property description "Support and Resistance lines are drawn by an indicator crossing out of overbought or oversold areas.\nExample: RSI crosses 70 downwards, a resistance line is created at the highest candle high."
#property strict
#property indicator_chart_window
#define resistance 1
#define support -1

enum sty {Solid,Dashed,Dotted,DD1,//Dashes+Dots(single)
          DD2//Dashes+Dots(double)
          };
extern int lkbk=5;//Lookback
extern int period=7;//Period
extern double resLevel=70;//Resistance Level
extern color resColour=clrViolet;//Resistance Colour
extern double supLevel=30;//Support Level
extern color supColour=clrMediumTurquoise;//Support Colour
extern sty style=0;//Line Style
bool initsw=true;

int deinit(){Objects(0,0,0,0,0);return 0;}
  
int start(){
  if(!initsw&&IndicatorCounted()==0)return 0;
  for(int i=(initsw)?lkbk:2;i>0;i--){
   Objects(0,0,1,0,i);
   double temp=0,pricei=0,priceii=0;
   datetime time1=0,time2=0;
   int bartemp=-1;
   pricei=iRSI(NULL,0,period,0,i);
   priceii=iRSI(NULL,0,period,0,i+1);
   if(priceii>=resLevel)
    if(pricei<resLevel){
     for(int r=i+period;r>=i;r--){double high1=High[r];if(temp<high1){temp=high1;time1=Time[r];time2=Time[r-1];bartemp=r-1;}}
     Objects(1,time1,temp,time2,bartemp);
     continue;}
   if(priceii<=supLevel)
    if(pricei>supLevel){temp=10000000;
     for(int s=i+period;s>=i;s--){double low1=Low[s];if(temp>low1){temp=low1;time1=Time[s];time2=Time[s-1];bartemp=s-1;}}
     Objects(-1,time1,temp,time2,bartemp);
     continue;}}
  if(initsw)initsw=false;
  return 0;}

struct _lines_{
  string name;
  double price;
  datetime time1,time2;
  int bartime2,type;  
  }lines[];

void del_array_element(int arraypos){
  int size=ArraySize(lines);
  lines[arraypos]=lines[size-1];
  ArrayResize(lines,size-1);}

void Objects(int id,datetime time,double price,datetime time2,int bar){
  
  if(id==0&&price==0){
   for(int obj=ObjectsTotal()-1;obj>=0;obj--){
    string nme=ObjectName(obj);
    if(StringFind(nme,NAME)>-1)ObjectDelete(nme);}
   return;}
   
   if(id==0&&price==1){
    for(int i=0,bar1;;i++){
      bool broken=false;
      int size=ArraySize(lines);
      if(i>=size)break;
      if(lines[i].type==resistance){
       for(bar1=lines[i].bartime2;bar1>bar;bar1--)if(lines[i].price<=iClose(NULL,0,bar1)){del_array_element(i);broken=true;break;}
        if(!broken){ObjectSet(lines[i].name,OBJPROP_TIME2,iTime(NULL,0,bar1));lines[i].bartime2=bar;}
        continue;}
      if(lines[i].type==support){
       for(bar1=lines[i].bartime2;bar1>bar;bar1--)if(lines[i].price>=iClose(NULL,0,bar1)){del_array_element(i);broken=true;break;}
       if(!broken){ObjectSet(lines[i].name,OBJPROP_TIME2,iTime(NULL,0,bar1));lines[i].bartime2=bar;}
        continue;}}
    return;}

   if(id==1||id==-1){
    int size=ArraySize(lines);
    ArrayResize(lines,size+1);
    color colour=NULL;
    static int rescnt=0,supcnt=0;
    string desc=NULL;
    lines[size].time2=time2;
    if(id==1){
     colour=resColour;
     rescnt++;
     desc+="Resistance TF:"+(string)0;
     lines[size].name=NAME+" R:"+(string)rescnt;
     lines[size].price=price;
     lines[size].time1=time;
     lines[size].type=resistance;
     lines[size].bartime2=bar;}
    if(id==-1){
     colour=supColour;
     supcnt++;
     desc="Support TF:"+(string)0;
     lines[size].name=NAME+" S:"+(string)supcnt;
     lines[size].price=price;
     lines[size].time1=time;
     lines[size].type=support;
     lines[size].bartime2=bar;}
    if(ObjectCreate(0,lines[size].name,OBJ_TREND,0,time,price,lines[size].time2,price)){
     ObjectSet(lines[size].name,OBJPROP_COLOR,colour);
     ObjectSetText(lines[size].name,desc);
     ObjectSet(lines[size].name,OBJPROP_RAY_RIGHT,false);
     ObjectSet(lines[size].name,OBJPROP_STYLE,style);
     return;}
    else Print("ObjectCreate error:"+(string)GetLastError()+" "+desc);}}

