//sdg
#property strict
#property indicator_chart_window
#property copyright "Copyright 13 May 2020, FooeyBar/Beerrun"
#define NAME "_MA(x6)"
#define dif PeriodSeconds()
#define none -1
enum _tf_ {None,M1,M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440,W1=10080,MN1=43200};
enum _width_{One=1,Two=2,Three=3,Four=4,Five=5};
enum _sty_{Solid,Dashed,Dotted,DD1,//Dashes+Dots(single)
           DD2//Dashes+Dots(double)
           };
enum _ny_{No,Yes};
enum _ma_{SMA,EMA,SMMA,LWMA};
enum _ap_{cl,//Close
          op,//Open
          hi,//High
          lo,//Low
          me,//Median
          ty,//Typical
          we//Weighted
          };
extern int maPeriod=80;//Period
extern int offset=5;//Line Start Offset
extern int lenght=7;//Line Length
extern _ma_ maType=1;//Method
extern _ap_ ap=0;//Price
extern int idx=0;//Index
extern _tf_ ma1=30;//MA 1
extern _tf_ ma2=60;//MA 2
extern _tf_ ma3=240;//MA 3
extern _tf_ ma4=1440;//MA 4
extern _tf_ ma5=10080;//MA 5
extern _tf_ ma6=43200;//MA 6
extern _width_ width=1;//Line Width
extern _sty_ style=2;//Line Style
extern color UpCandleColor=clrLime;//Up Colour
extern color DownCandleColor=clrRed;//Down Colour
extern _ny_ showLabels=1;//Display Labels
extern int labelSize=8;//Label Size
   
void OnDeinit(const int re){Trendline();GPS(-1);return;}
  
int OnCalculate(const int rates_total,const int prev_calculated,const datetime& time[],const double& open[],const double& high[],const double& low[],const double& close[],const long& tick_volume[],const long& volume[],const int& spread[]){
   if(myId==NULL)myId=GPS(0);
   
   datetime dtStart=datetime(time[0]+dif*offset),dtEnd=datetime(time[0]+dif*offset*lenght);
   
   if(ma1>0){
      double _ma1=iMA(NULL,ma1,maPeriod,0,(int)maType,(int)ap,idx);
      string _ma1String=EnumToString(ma1);
      Trendline(_ma1String,dtStart,_ma1,dtEnd,_ma1<=Bid?UpCandleColor:DownCandleColor,_ma1String);
      }
   if(ma2>0){
      double _ma2=iMA(NULL,ma2,maPeriod,0,(int)maType,(int)ap,idx);
      string _ma2String=EnumToString(ma2);
      Trendline(_ma2String,dtStart,_ma2,dtEnd,_ma2<=Bid?UpCandleColor:DownCandleColor,_ma2String);
      }
   if(ma3>0){
      double _ma3=iMA(NULL,ma3,maPeriod,0,(int)maType,(int)ap,idx);
      string _ma3String=EnumToString(ma3);
      Trendline(_ma3String,dtStart,_ma3,dtEnd,_ma3<=Bid?UpCandleColor:DownCandleColor,_ma3String);
      }
   if(ma4>0){
      double _ma4=iMA(NULL,ma4,maPeriod,0,(int)maType,(int)ap,idx);
      string _ma4String=EnumToString(ma4);
      Trendline(_ma4String,dtStart,_ma4,dtEnd,_ma4<=Bid?UpCandleColor:DownCandleColor,_ma4String);
      }
   if(ma5>0){
      double _ma5=iMA(NULL,ma5,maPeriod,0,(int)maType,(int)ap,idx);
      string _ma5String=EnumToString(ma5);
      Trendline(_ma5String,dtStart,_ma5,dtEnd,_ma5<=Bid?UpCandleColor:DownCandleColor,_ma5String);
      }
   if(ma6>0){
      double _ma6=iMA(NULL,ma6,maPeriod,0,(int)maType,(int)ap,idx);
      string _ma6String=EnumToString(ma6);
      Trendline(_ma6String,dtStart,_ma6,dtEnd,_ma6<=Bid?UpCandleColor:DownCandleColor,_ma6String);
      }
   
   return rates_total;}

void Trendline(string name=NULL,datetime time1=0,double price=0,datetime time2=0,color colour=clrNONE,string text=NULL){
   if(name==NULL){ObjectsDeleteAll(0,NAME+myId);return;}
   string labelName=NAME+myId+" | Label | "+name;
   name=NAME+myId+" | Line | "+name;
   if(ObjectFind(name)<0){
      if(!ObjectCreate(0,name,OBJ_TREND,0,time1,price,time2,price)){Print("ObjectCreate Fail: Trendline | Error:",GetLastError());return;}
      ObjectSet(name,OBJPROP_WIDTH,width);
      ObjectSet(name,OBJPROP_RAY,0);
      ObjectSet(name,OBJPROP_STYLE,style);
      ObjectSet(name,OBJPROP_SELECTABLE,0);
      ObjectSetText(name,text,10,NULL,colour);
      setLabels(labelName,price,time2,colour,text);
      return;}
   ObjectSet(name,OBJPROP_TIME1,time1);
   ObjectSet(name,OBJPROP_PRICE1,price);
   ObjectSet(name,OBJPROP_TIME2,time2);
   ObjectSet(name,OBJPROP_PRICE2,price);
   ObjectSet(name,OBJPROP_COLOR,colour);
   setLabels(labelName,price,time2,colour);
   }

void setLabels(string labelName,double price,datetime time,color col,string text=NULL){
   if(!showLabels)return;
   time+=dif;
   if(ObjectFind(labelName)<0){
      if(!ObjectCreate(0,labelName,OBJ_TEXT,0,time,price)){Print("ObjectCreate Fail: Label | Error: "+(string)GetLastError());return;}
      ObjectSetText(labelName,text,labelSize,"Arial",col);
      ObjectSetInteger(0,labelName,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetInteger(0,labelName,OBJPROP_SELECTABLE,0);
      }
   ObjectSetInteger(0,labelName,OBJPROP_TIME,time);
   ObjectSetDouble(0,labelName,OBJPROP_PRICE,price);
   ObjectSet(labelName,OBJPROP_COLOR,col);
   ObjectSetInteger(0,labelName,OBJPROP_SELECTABLE,0);
   }

string myId=NULL;
string GPS(int event){
  static string progName=NAME+" ";
  static string mutex=progName+"Mutex";
  static int symID=0,id=0;
  string idtag=" ID#",sep=".";
  string position=progName+_Symbol+idtag;
  string savepos=position;
  int temp=0,temp2=2;
  
  if(!GlobalVariableCheck(mutex))GlobalVariableSet(mutex,0);
  if(symID!=0&&id!=0)if(!GlobalVariableCheck(savepos+" "+(string)symID))GlobalVariableSet(savepos+" "+(string)symID,id);
  
  if(event==0&&id==0){
   for(;;){if(GlobalVariableSetOnCondition(mutex,1,0))break;}
   for(int gt=GlobalVariablesTotal();gt>=0;gt--)if(StringFind(GlobalVariableName(gt),idtag,0)>-1)temp++;
   for(;temp>0;temp--){ 
    int tpos=id;
    for(int gvt=GlobalVariablesTotal(),v=0;gvt>=0;gvt--){
     string name=GlobalVariableName(gvt);
     if(StringFind(name,idtag,0)>-1){
      v=(int)GlobalVariableGet(name);
      if(v==id+1){id++;break;}}}   
    if(tpos==id)break;}
   id++;
   if(GlobalVariableCheck(savepos+" "+IntegerToString(1))){
    int try=2;
    for(int gv=GlobalVariablesTotal();;){
     if(gv>=0){
      string n=GlobalVariableName(gv);
      savepos=position+" "+IntegerToString(try);
      if(StringFind(n,savepos,0)>-1)try++;
      gv--;}
     if(gv<0){
      if(temp2==try)break;
      temp2=try;
      gv=GlobalVariablesTotal();}}
    savepos=position+" "+IntegerToString(try);
    symID=try;
    GlobalVariableSet(savepos,id);
    GlobalVariableSetOnCondition(mutex,0,1);
    return (string)symID+sep+(string)id;}     
   savepos=savepos+" "+IntegerToString(1);
   symID=1;
   GlobalVariableSet(savepos,id);
   GlobalVariableSetOnCondition(mutex,0,1);
   return (string)symID+sep+(string)id;}
     
  if(event==-1&&id!=0){ 
   for(;;){if(GlobalVariableSetOnCondition(mutex,1,0))break;}
   for(int g=GlobalVariablesTotal();g>=0;g--)if(StringFind(GlobalVariableName(g),idtag,0)>-1)temp++;
   savepos=savepos+" "+IntegerToString(symID);
   GlobalVariableDel(savepos);
   if(temp==1){
    GlobalVariableSetOnCondition(mutex,1,0);
    GlobalVariableDel(mutex);
    return (string)symID+sep+(string)id;}
   GlobalVariableSetOnCondition(mutex,0,1);
   return (string)symID+sep+(string)id;}

  return (string)symID+sep+(string)id;}