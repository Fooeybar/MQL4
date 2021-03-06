//sdg
#property strict
#property indicator_chart_window
extern int timer=10;//Seconds
enum _alttype_{alert,//Alerts
               alertnot,//Alerts and Notifications
               alertmail,//Alerts and Emails
               not,//Notifications
               notmail,//Notifications and Emails
               email,//Emails
               all,//All
               none//None
               };
extern _alttype_ ALERTS=0;//Alert Type
extern string askALTMSG="Ask==Ask";//Ask Message
extern string bidALTMSG="Bid==Bid";//Bid Message
bool initsw=true;
int init(){EventSetTimer(timer);return 0;}
int start(){return 0;}
void OnTimer(){
   static double ask=Ask,bid=Bid;
   if(ask==Ask)Alerts(1);
   if(bid==Bid)Alerts(0);
   ask=Ask;
   bid=Bid;
   if(initsw)initsw=0;
   }
//---Alerts---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void Alerts(bool dir){
   if(initsw||ALERTS==7)return;
   string header=MQLInfoString(MQL_PROGRAM_NAME)+" | "+_Symbol;
   string msg=dir?askALTMSG:bidALTMSG;
   if(ALERTS==0||ALERTS==1||ALERTS==2||ALERTS==6)Alert(header+" | "+msg);
   if(ALERTS==1||ALERTS==3||ALERTS==4||ALERTS==6)SendNotification(header+" | "+msg);
   if(ALERTS==2||ALERTS==4||ALERTS==5||ALERTS==6)SendMail(header,msg);
   }
