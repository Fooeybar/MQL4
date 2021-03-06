#property strict
#property copyright "Copyright 13 May 2020, Beerrun"
#property indicator_chart_window
#define dif timeframe/_Period
#define resistance 1
#define support -1
#define end -99
#define prefix "_"+MQLInfoString(MQL_PROGRAM_NAME)+"("+EnumToString(timeframe)+")"

enum _tf_ {M1=1,M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440,W1=10080,MH1=43200};
enum _sty_{Solid,Dashed,Dotted,DD1,//Dashes+Dots(single)
           DD2//Dashes+Dots(double)
           };
enum _ny_{No,Yes};
enum _width_{One=1,Two=2,Three=3,Four=4,Five=5};

extern _tf_ timeframe=D1;//Timeframe
extern int lbk=1000;//Lookback
extern _width_ arrowWidth=1;//Arrow Width
extern color colourUp=clrViolet;//Resistance Colour
extern color colourDw=clrMediumTurquoise;//Support Colour
extern _ny_ displayLines=1;//Display Lines
extern _sty_ lineStyle=2;//Line Style
extern _width_ lineWidth=1;//Line Width

bool initsw=true;

int deinit(){Objects(end,0,0,0,0);return 0;}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime& time[],const double& open[],const double& high[],const double& low[],const double& close[],const long& tick_volume[],const long& volume[],const int& spread[]){
  static datetime newBar=0;
  datetime tempBar=iTime(NULL,timeframe,0);
  if(tempBar==newBar)return rates_total;
  newBar=tempBar;
  
  static int aRCnt=1,aSCnt=1;
  
  for(int i=initsw==1?lbk:2;i>=0;i--){
   Objects(0,0,1,0,i);
   
   double resFrac=iFractals(NULL,timeframe,1,i),supFrac=iFractals(NULL,timeframe,2,i);
   
   if(resFrac>0){
      aRCnt++;
      datetime time1=iTime(NULL,timeframe,i),time2=iTime(NULL,timeframe,i-1);
      DrawArrow(true,time1,resFrac,colourUp,arrowWidth,timeframe==D1?108:242,aRCnt);
      if(displayLines)Objects(1,time1,resFrac,time2,i-1,aRCnt);
      continue;}
   
   if(supFrac>0){
      aSCnt++;
      datetime time1=iTime(NULL,timeframe,i),time2=iTime(NULL,timeframe,i-1);
      DrawArrow(false,time1,supFrac,colourDw,arrowWidth,timeframe==D1?108:241,aSCnt);
      if(displayLines)Objects(-1,time1,supFrac,time2,i-1,aSCnt);
      continue;}
   
   }
  if(initsw)initsw=false;
  return rates_total;}

//---Objects---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void DrawArrow(bool dir,datetime time=0,double price=0,color col=0,int width=1,int aCode=NULL,int cnt=1){
   string name=prefix+(!dir?" Arrow S:":" Arrow R:")+(string)cnt;
   if(!ObjectCreate(0,name,OBJ_ARROW,0,time,price)){Print("ObjectCreate Arrow Fail | Error:"+(string)GetLastError());return;}
   ObjectSet(name,OBJPROP_ARROWCODE,aCode);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_HIDDEN,1);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
   ObjectSet(name,OBJPROP_BACK,0);
   }

void Objects(int id,datetime time,double price,datetime time2,int bar,int cnt=-1,int style=2){
  
  if(id==end){ObjectsDeleteAll(0,prefix);return;}
   
   if(id==0&&price==1){
    for(int i=0,bar1;;i++){
      bool broken=false;
      int size=ArraySize(lines);
      if(i>=size)break;
      if(lines[i].type==resistance){
       for(bar1=lines[i].bartime2;bar1>bar;bar1--)if(lines[i].price<=iClose(NULL,timeframe,bar1)){Alerts(1,lines[i].desc);del_array_element(i);broken=true;break;}
        if(!broken){ObjectSet(lines[i].name,OBJPROP_TIME2,iTime(NULL,timeframe,bar1));lines[i].bartime2=bar;}
        continue;}
      if(lines[i].type==support){
       for(bar1=lines[i].bartime2;bar1>bar;bar1--)if(lines[i].price>=iClose(NULL,timeframe,bar1)){Alerts(-1,lines[i].desc);del_array_element(i);broken=true;break;}
       if(!broken){ObjectSet(lines[i].name,OBJPROP_TIME2,iTime(NULL,timeframe,bar1));lines[i].bartime2=bar;}
        continue;}}
    return;}

   if(id==1||id==-1){
    int size=ArraySize(lines);
    ArrayResize(lines,size+1);
    color colour=NULL;
    string desc=NULL;
    lines[size].time2=time2;
    if(id==1){
     colour=colourUp;
     desc="Resistance Line";
     lines[size].desc="R:"+(string)cnt;
     lines[size].name=prefix+" R:"+(string)cnt;
     lines[size].price=price;
     lines[size].time1=time;
     lines[size].type=resistance;
     lines[size].bartime2=bar;}
    if(id==-1){
     colour=colourDw;
     desc="Support Line";
     lines[size].desc="S:"+(string)cnt;
     lines[size].name=prefix+" S:"+(string)cnt;
     lines[size].price=price;
     lines[size].time1=time;
     lines[size].type=support;
     lines[size].bartime2=bar;}
    if(ObjectCreate(0,lines[size].name,OBJ_TREND,0,time,price,lines[size].time2,price)){
     ObjectSet(lines[size].name,OBJPROP_COLOR,colour);
     ObjectSetText(lines[size].name,desc);
     ObjectSet(lines[size].name,OBJPROP_RAY_RIGHT,false);
     ObjectSet(lines[size].name,OBJPROP_STYLE,style);
     ObjectSet(lines[size].name,OBJPROP_BACK,1);
     return;}
    else Print("ObjectCreate error:"+(string)GetLastError()+"| "+desc+" ("+(string)cnt+") ");
    }
   }

struct _lines_{
  string name,desc;
  double price;
  datetime time1,time2;
  int bartime2,type;  
  }lines[];

void del_array_element(int arraypos){
  int size=ArraySize(lines);
  lines[arraypos]=lines[size-1];
  ArrayResize(lines,size-1);}
  
//---Alerts---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
extern string SEP0="-----------------------------------";//---Alerts---------------------------------
enum _alttype_{alert,//Alerts
               alertnot,//Alerts and Notifications
               alertmail,//Alerts and Emails
               not,//Notifications
               notmail,//Notifications and Emails
               email,//Emails
               all,//All
               none//None
               };
extern _alttype_ ALERTS=0;//Type
void Alerts(int dir=0,string desc=NULL){
   if(ALERTS==7||initsw)return;
   static datetime newbar=0;
   string header=MQLInfoString(MQL_PROGRAM_NAME)+" ("+EnumToString(timeframe)+") "+_Symbol;
   string msg=dir==1?"Resistance Fractal "+desc+" Broken!":dir==-1?"Support Fractal "+desc+" Broken!":"Alert!";
   if(ALERTS==0||ALERTS==1||ALERTS==2||ALERTS==6)Alert(header+" | "+msg);
   if(ALERTS==1||ALERTS==3||ALERTS==4||ALERTS==6)SendNotification(header+" | "+msg);
   if(ALERTS==2||ALERTS==4||ALERTS==5||ALERTS==6)SendMail(header,msg);
   }
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
