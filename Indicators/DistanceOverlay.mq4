//SDG
#property strict
#property copyright "Copyright 2020, FooeyBar (R.M.)"
#property link      "https://www.forexfactory.com/beerrun"
#property version   "1.00"
#property indicator_chart_window
#define NAME MQLInfoString(MQL_PROGRAM_NAME)+" / "

input double riskPips=3;//Pips
input double ratio=2;//RR (reward/risk)
input color riskCol=clrFireBrick;//Risk Colour
input color rewardCol=clrForestGreen;//Reward Colour
input double lotSize=0.01;//Lot Size
extern int magicNum=100;//Magic Number
#define pip Point*10
int tf=0;

int init(){
   EventSetMillisecondTimer(1);
   GetTradeDir();
   ChartSetInteger(0,CHART_COLOR_ASK,clrForestGreen);
   ChartSetInteger(0,CHART_COLOR_GRID,clrFireBrick);
   return 0;}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){Main();return 0;}
void OnTimer(){Main();}
int deinit(){ShortLines(1);LongLines(1);return 0;}
void Main(){
	ShortLines();
	LongLines();
	}

#define SHORTNAMERISK "Short Risk"
#define SHORTNAMEREWARD "Short Reward"
double ShortReward(){return Bid-((ratio*riskPips)*pip);}
double ShortRisk(){return Ask+(riskPips*pip);}
void ShortLines(bool del=false){
   ObjectDelete(NAME+SHORTNAMEREWARD);ObjectDelete(NAME+SHORTNAMERISK);
   if(del)return;
   if(DIR==1)return;
   if(ObjectCreate(NAME+SHORTNAMEREWARD,OBJ_HLINE,0,Time[0],ShortReward())){
      ObjectSet(NAME+SHORTNAMEREWARD,OBJPROP_WIDTH,1);
      ObjectSet(NAME+SHORTNAMEREWARD,OBJPROP_COLOR,!DIR?rewardCol:clrDimGray);}
   if(ObjectCreate(NAME+SHORTNAMERISK,OBJ_HLINE,0,Time[0],ShortRisk())){
      ObjectSet(NAME+SHORTNAMERISK,OBJPROP_WIDTH,1);
      ObjectSet(NAME+SHORTNAMERISK,OBJPROP_STYLE,0);
      ObjectSet(NAME+SHORTNAMERISK,OBJPROP_COLOR,!DIR?riskCol:clrDimGray);}
   }

#define LONGNAMERISK "Long Risk"
#define LONGNAMEREWARD "Long Reward"
double LongReward(){return Ask+((ratio*riskPips)*pip);}
double LongRisk(){return Bid-(riskPips*pip);}
void LongLines(bool del=false){
   ObjectDelete(NAME+LONGNAMEREWARD);ObjectDelete(NAME+LONGNAMERISK);
   if(del)return;
   if(DIR==0)return;
   if(ObjectCreate(0,NAME+LONGNAMEREWARD,OBJ_HLINE,0,Time[0],LongReward())){
      ObjectSet(NAME+LONGNAMEREWARD,OBJPROP_WIDTH,1);
      ObjectSet(NAME+LONGNAMEREWARD,OBJPROP_COLOR,DIR?rewardCol:clrDimGray);}
   if(ObjectCreate(0,NAME+LONGNAMERISK,OBJ_HLINE,0,Time[0],LongRisk())){
      ObjectSet(NAME+LONGNAMERISK,OBJPROP_WIDTH,1);
      ObjectSet(NAME+LONGNAMERISK,OBJPROP_STYLE,0);
      ObjectSet(NAME+LONGNAMERISK,OBJPROP_COLOR,DIR?riskCol:clrDimGray);}
   }
bool DIR;
bool GetTradeDir(){
   string nme=AccountName();
   if(StringFind(nme,"hort")>-1){DIR=false;magicNum-=1;return false;}
   if(StringFind(nme,"ong")>-1){DIR=true;magicNum+=1;return true;}
   return NULL;}