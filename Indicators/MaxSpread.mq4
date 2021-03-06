//SDG
#property strict
#property indicator_chart_window
#property copyright "Copyright 24 April 2020, FooeyBar/Beerrun"
#property link "https://www.forexfactory.com/beerrun"
#define NAME MQLInfoString(MQL_PROGRAM_NAME)
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
extern int lbk=50;//Lookback
extern int _maxSpread=20;//Maximum Spread (Points)
extern color colour=clrRed;//Colour
enum ny{No,Yes};
extern ny timer=1;//Timer
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
int start(){MaxSpread();return 0;}
void OnTimer(){MaxSpread();}
int deinit(){MaxSpread(-99);return 0;}
//---Max-Spread-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
bool MaxSpread(int id=0){
   //---Timer-Init-------------------------------------------------------------------------------
   //if using in your own code and want tick operation only, delete the next three lines
   if(timer){
      static bool initTimer=false;
      if(!initTimer){EventSetMillisecondTimer(1);initTimer=true;}}
   //--------------------------------------------------------------------------------------------
   if(id<0){bool ret=ObjectDelete(0,NAME);Comment("");return ret;}
   static bool initObject=false;
   if(ObjectFind(NAME)<0)initObject=false;
   if(!initObject){
      initObject=ObjectCreate(0,NAME,OBJ_RECTANGLE,0,lbk>=0?Time[lbk]:Time[0],Ask,lbk>=0?Time[0]:Time[0]+(PeriodSeconds()*(-lbk)),Bid);
      if(!initObject)return false;
      else ObjectSet(NAME,OBJPROP_COLOR,clrNONE);}
   static bool check=false;   
   RefreshRates();
   double temp=Ask-Bid;
   Comment("Spread: "+DoubleToStr(temp*10000,3));
   if(temp>_maxSpread*_Point){
      ObjectSet(NAME,OBJPROP_PRICE1,Ask);
      ObjectSet(NAME,OBJPROP_PRICE2,Bid);
      ObjectSet(NAME,OBJPROP_TIME2,lbk>=0?Time[0]:Time[0]+(PeriodSeconds()*(-lbk)));
      ObjectSet(NAME,OBJPROP_COLOR,colour);      
      check=true;
      Alerts();
      return true;}
   else if(check){ObjectSet(NAME,OBJPROP_COLOR,clrNONE);check=false;}
   return false;}
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
extern _alttype_ ALERTS=7;//Type
extern string ALTMSG="";//Message
void Alerts(){
   if(ALERTS==7)return;
   static datetime newbar=0;
   datetime newtime=Time[0];
   if(newbar>=newtime)return;
   newbar=newtime;
   string header=MQLInfoString(MQL_PROGRAM_NAME)+" | "+_Symbol;
   string msg=ALTMSG;
   if(ALERTS==0||ALERTS==1||ALERTS==2||ALERTS==6)Alert(header+" | "+msg);
   if(ALERTS==1||ALERTS==3||ALERTS==4||ALERTS==6)SendNotification(header+" | "+msg);
   if(ALERTS==2||ALERTS==4||ALERTS==5||ALERTS==6)SendMail(header,msg);
   }
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
