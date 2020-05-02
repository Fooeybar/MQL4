#property copyright "26 April 2019 Beerrun"
#property strict
//===Settings=============================================================//
#define     Simba 3    //Strategy Type: Original(1), Re-engineered(2), Version3 (3) 
#define      Size 0.01 //Lotsize
#define     Trend 400  //Trend in Points
#define        CC 3    //Candle Count
#define   Retrace 160  //Retrace in Points
#define MaxSpread 40   //Maximum Spread in Points
#define        TC 3    //Number of Trades Opened
#define      Slip 2    //Slippage
#define        TP 100  //Trade 1 TP
#define       TPI 50   //TP Increment
#define        SL 250  //All Trade SL
#define       MSG "Hi" //Order Comment (Message To Broker)
#define     MAGIC 99   //Magic Number
#define        BE 50   //First BE
#define       BEP 20   //First BE+
#define       BEA 1    //Additional BE's
#define       BEI 100  //BE Increment
#define      BEIP 30   //BE+ Increment
//========================================================================//
void OnDeinit(const int re){Comment("");}   
void OnTick(){                                 
  static datetime newbar=0;static int up=0,dw=0,cc=0;static double temp=0,begin=0;                                      //static variables declaration
  if(Trades(-1,0))return;                                                           //check open trades,opened trades handled internally //or if spread above maxspread, do nothing
  double close=Close[1],open=Open[1];                                                           //last closed candle close and open
  if(up!=2&&dw!=2&&up!=3&&dw!=3){                                                                                             //if no trend defined
   if(newbar>=Time[0])return;                                                                           //if not new bar then do nothing
   newbar=Time[0];                                                                                      //if new bar update bar time
   if(up==0&&close>open){begin=open;cc=1;temp=close-open;up=1;dw=0;return;}                                                //first candle in up trend, temp equals bar size
   if(dw==0&&close<open){begin=open;cc=1;temp=open-close;dw=1;up=0;return;}                                                //first candle in dw trend, temp equals bar size
   if(up==1&&close>open){cc++;temp+=close-open;}                                                                //additional up candles, bar size added to temp (trend size sum)
   if(dw==1&&close<open){cc++;temp+=open-close;}                                                                //additional dw candles, bar size added to temp (trend size sum)
   if(temp>=(Trend*_Point)&&cc>=CC){temp=Close[1];if(up==1)up=2;if(dw==1)dw=2;}}                        //trend defined, temp changes its purpose from trend sum to trend hi/lo
  close=Close[0];                                                                                       //current price
  if(Simba==1){                                                                                                 //Original Simba
   if(up==2){                                                                                                   //up trend
    if(close<=temp-(Retrace*_Point)){Trades(1,0);up=0;return;}                                                    //if retrace, open trades
    if(Close[1]>temp)temp=Close[1];return;}                                                     //if contination, move trend hi
   if(dw==2){                                                                                                   //dw trend
    if(close>=temp+(Retrace*_Point)){Trades(0,0);dw=0;return;}                                                    //if retrace, open trades
    if(Close[1]<temp)temp=Close[1];return;}return;}                                             //if continuation, move trend lo
  if(Simba==2){                                                                                                 //Simba Re-Engineered
   if(dw==2){                                                                                                   //dw trend
    if(close<=temp-(Retrace*_Point)){Trades(1,0);dw=0;return;}                                                    //if continuation, open trades
    if(Close[1]>temp)temp=Close[1];return;}                                                     //if no continuation, move trend lo
   if(up==2){                                                                                                   //up trend
    if(close>=temp+(Retrace*_Point)){Trades(0,0);up=0;return;}                                                    //if continuation, open trades
    if(Close[1]<temp)temp=Close[1];return;}return;}                                             //if no continuation, move trend hi
  if(Simba==3){
   if(up==2){
    if(Close[1]<Open[1]){Print(IntegerToString(1));up=3;temp=Close[1];return;}
    if(Close[1]<=begin){Print(IntegerToString(-1));up=0;return;}
    return;}
   if(up==3){
    if(close>=temp+(Retrace*_Point)){Print(IntegerToString(2));Trades(5,temp);up=0;return;}
    if(Close[1]<=begin){Print(IntegerToString(-2));up=0;return;}
    if(Close[1]<temp)temp=Close[1];
    return;}
   if(dw==2){
    if(Close[1]>Open[1]){Print(IntegerToString(1));dw=3;temp=Close[1];return;}
    if(Close[1]>=begin){Print(IntegerToString(-1));dw=0;return;}
    return;}
   if(dw==3){
    if(close<=temp-(Retrace*_Point)){Print(IntegerToString(2));Trades(4,temp);dw=0;return;}
    if(Close[1]>=begin){Print(IntegerToString(-2));dw=0;return;}
    if(Close[1]>temp)temp=Close[1];
    return;}
   return;}
  return;}                                                                                                      //return from OnTick

bool Trades(int id,double price){
  static bool trades=false;                                                                                     //program open orders flag
  static struct order{                                                                                          //order struct
   double sl,tp,size,oop,be,bep,begap;int tkt,type,becnt;                                                       //order struct variables declaration
   order(){type=-1;oop=tkt=becnt=0;sl=SL*_Point;tp=TP*_Point;size=Size;                                            //constructor
           be=BE*_Point;bep=BEP*_Point;begap=(BEI-BEIP)*_Point;}                                                //constructor
   void store(int id){if(OrderSelect(tkt,SELECT_BY_TICKET)){                                                    //store function //order select with current ticket
         oop=OrderOpenPrice();sl=OrderStopLoss();tp=OrderTakeProfit();type=id;                                 //order info saved
         if(type==0||type==4){be=(oop+be);bep=(oop+bep);return;}if(type==1||type==5){be=(oop-be);bep=(oop-bep);return;}}         //first BE stored
         else Print("store failed, order# "+IntegerToString(tkt));}                                             //if orderselect fails, send error message with failed ticket number
   void breakeven(){if(becnt>BEA||BE<=0)return;                                                                 //breakeven function //if attempt is greater than allowed BE adjustments, do nothing
         if(type==4)type=0;if(type==5)type=1;
         if(OrderSelect(tkt,SELECT_BY_TICKET))if(OrderCloseTime()!=0){reset();return;}                          //if the order is closed, reset order's struct
         if(type==0)if(sl>=tp-_Point)return;if(type==1)if(sl<=tp+_Point)return;                                 //if attempted sl is too close to tp, do nothing
         sl=round(bep/_Point)*_Point;                                                                           //normalize sl
         if(OrderModify(tkt,oop,sl,tp,0)){becnt++;                                                              //if ordermodify successful, add to order's breakeven count
          if(type==0){be+=(BEI*_Point);bep=sl+(BEIP*_Point);}                                                   //if ordermodify successful, set up buy BE values for next attempt
          if(type==1){be-=(BEI*_Point);bep=sl-(BEIP*_Point);}}}                                                 //if ordermodify successful, set up sell BE values for next attempt
   void reset(){if(type==4||type==5)type=OrderDelete(tkt);
         type=-1;oop=tkt=becnt=0;sl=SL*_Point;tp=TP*_Point;be=BE*_Point;bep=BEP*_Point;}                    //order struct reset function
   }simba[TC];                                                                                                  //declare struct array with size
  
  if(id==-1){                                                                                                   //open orders check
   if(!trades)return(trades);                                                                                   //if trades flag not set by program, return false
   int cnt=0;                                                                                                   //order count variable declaration
   for(int i=OrdersTotal()-1;i>=0;i--){if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))if(OrderSymbol()==Symbol())  //for loop to check open orders //if orderselect succeeds, if selected order is this chart
    if(OrderMagicNumber()==MAGIC)if(OrderType()<2)cnt++;}                                                                        //if selected order magic# is this program's, increment order count
   if(cnt>0)return(Trades(5+cnt,0));                                                                            //if order(s) found, recursive return count to order management
   for(int del=TC-1;del>=0;del--)simba[del].reset();trades=false;return(trades);}                                       //if no order found, allow new orders by returning false
  
  if(id>=6){                                                                                                    //Trailing Stops (BE's)
   if(simba[id-6].type==0||simba[id-6].type==4){                                                                                     //if order type is buy
    if(BE>0)if(Bid>=simba[id-6].be)for(int i=id-6;i>=0;i--)simba[i].breakeven();                                //if Bid is greater than current BE, adjust sl
    return(trades);}                                                                                            //return to OnTick for efficiency
   if(simba[id-6].type==1||simba[id-6].type==5){                                                                                     //if order type is sell
    if(BE>0)if(Ask<=simba[id-6].be)for(int i=id-6;i>=0;i--)simba[i].breakeven();                                //if Ask is less than current BE, adjust sl
    return(trades);}                                                                                            //return to OnTick for efficiency
   return(trades);}                                                                                             //return to OnTick for efficiency 
  
  if(id==0||id==4){                                                                                             //Opening Trades Buy (will not work on ECN due to SL+TP sent with the Order Open)//if first order fails, return false
   if(id==0&&(Ask-Bid)>(MaxSpread*_Point))return(trades);
   for(int i=TC-1;i>=0;i--){RefreshRates();                                                                     //begin loop
    if(simba[i].tkt!=0)simba[i].reset();                                                                        //if order struct is not cleared, reset
    double Oprice=(id==0)?Ask:price;
    if(i==TC-1)simba[i].tp=round((Oprice+simba[i].tp)/_Point)*_Point;                                              //set first order tp
    else simba[i].tp=simba[i+1].tp+(TPI*_Point);                                                                //increment tp's
    simba[i].sl=round((Oprice-simba[i].sl)/_Point)*_Point;                                                         //normalize sl's
    simba[i].tkt=OrderSend(NULL,id,simba[i].size,Oprice,Slip,simba[i].sl,simba[i].tp,MSG,MAGIC);                   //send order
    if(simba[i].tkt!=-1){simba[i].store(id);if(!trades)trades=true;}}                                           //if order successful store info, flag trades as true
   return(trades);}
   
  if(id==1||id==5){                                                                                             //Opening Trades Sell (will not work on ECN due to SL+TP sent with the Order Open)//if first order fails, return false
   if(id==1&&(Ask-Bid)>(MaxSpread*_Point))return(trades);
   for(int i=TC-1;i>=0;i--){RefreshRates();                                                                     //begin loop
    if(simba[i].tkt!=0)simba[i].reset();                                                                        //if order struct is not cleared, reset
    if(i==TC-1)simba[i].tp=round((Bid-simba[i].tp)/_Point)*_Point;                                              //set first order tp
    else simba[i].tp=simba[i+1].tp-(TPI*_Point);                                                                //increment tp's
    simba[i].sl=round((Bid+simba[i].sl)/_Point)*_Point;                                                         //normalize sl's
    simba[i].tkt=OrderSend(NULL,id,simba[i].size,Bid,Slip,simba[i].sl,simba[i].tp,MSG,MAGIC);                   //send order
    if(simba[i].tkt!=-1){simba[i].store(id);if(!trades)trades=true;}}                                           //if order successful store info, flag trades as true
   return(trades);}
  
  return(true);}                                                                                                //if for some reason code totally fails, prevent trades by returning true
