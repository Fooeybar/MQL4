#property copyright "Copyright 6 January 2019, Beerrun(R.M.)"
#property link "https://www.forexfactory.com/beerrun"
#property strict
#property show_inputs
enum _scn_ {n,//0 Seconds
          s1,//1 Second
          s3=3,//3 Seconds
          s10=10,//10 Seconds
          s30=30,//30 Seconds
          m1=60,//1 Minute
          m5=300,//5 Minutes
          m15=900,//15 Minutes
          };
enum _type_ {Long,Short,None};
enum _ny_ {No,Yes};
enum _trail_ {Immediate,Increment};
input _ny_ symbol=0;//Restrict To Chart Symbol
input _scn_ Scan=1;//Time Between Stoploss Scans
input _ny_ sticky=1;//Script Remains On Chart
input string div1="----------------------------------------------";//---Break-Even-Trailing-Stop----------------------------------------
input int BE=9;//Points To BE
input int bep=3;//BE+ In Points
input int bStep=6;//Points To Begin Trail After BE
input _trail_ _trail=0;//Trail Type
input int Trail=9;//Points To Trail Price
input string div2="----------------------------------------------";//---Hidden-Market-Order-----------------------------------------
input _type_ hiddentype=None;//Hidden Order Type
input double hiddenprice;//Price
input double hiddenlots=0.01;//Lots
input int hiddenslip=2;//Slippage
input double hiddensl;//StopLoss
input double hiddentp;//TakeProfit
input int hiddenmagic=99;//Magic Number
#define orgCom "Scanning Orders"
#define orgEnd "Scan Finished\nStoplosses Adjusted: "
string com=orgCom;
int comcnt=0;

int start(){
  for(;;){
     if(IsStopped()){Comment("");return 0;}
     int adjcnt=0;
     
     static bool hiddensw=1;
     if(hiddensw&&hiddentype!=2)
      if((hiddentype==1&&(Bid>=hiddenprice))||(hiddentype==0&&(Ask<=hiddenprice)))
       if(OrderSend(_Symbol,hiddentype,hiddenlots,hiddenprice,hiddenslip,hiddensl,hiddentp,MQLInfoString(MQL_PROGRAM_NAME),hiddenmagic))hiddensw=0;
     
      Comment(com);
      for(int i=OrdersTotal()-1;i>=0;i--){
       com+=".";
       comcnt++;
       if(comcnt==4){com=orgCom;comcnt=0;}
       Comment(com);
       if(IsStopped())return 0;
       
       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
        string ordersymbol=OrderSymbol();
        RefreshRates();
        double point=_Point,ask=Ask,bid=Bid;
        if(ordersymbol!=_Symbol){
         if(symbol)continue;
         else{point=SymbolInfoDouble(ordersymbol,SYMBOL_POINT);ask=SymbolInfoDouble(ordersymbol,SYMBOL_ASK);bid=SymbolInfoDouble(ordersymbol,SYMBOL_BID);}}
        double OOP=OrderOpenPrice(),SL=OrderStopLoss(),pTrail=Trail*point;
         
         if(OrderType()==0)
          if(bid>=OOP+(BE*point)){
           if(SL<OOP||SL==0)SL=OOP+(bep*point);
           if(bid>=OOP+((BE+bStep)*point)){
            if(_trail==0)if(SL<bid-pTrail)SL=bid-pTrail;
            if(_trail==1)if(SL<bid-(pTrail*2))SL=bid-pTrail;
            }
           SL=round(SL/point)*point;
           if(OrderStopLoss()>=SL)continue;
           if(OrderModify(OrderTicket(),OOP,SL,0,0)){adjcnt++;continue;}}       
            
         if(OrderType()==1)
          if(ask<=OOP-(BE*point)){
           if(SL>OOP||SL==0)SL=OOP-(bep*point);
           if(ask<=OOP-((BE+bStep)*point)){
            if(_trail==0)if(SL>=ask+pTrail)SL=ask+pTrail;
            if(_trail==1)if(SL>=ask+(pTrail*2))SL=ask+pTrail;
            }
           SL=round(SL/point)*point;
           if(OrderStopLoss()<=SL)continue;
           if(OrderModify(OrderTicket(),OOP,SL,0,0)){adjcnt++;continue;}}}}
     
     Comment(orgEnd+(string)adjcnt);
     Sleep(Scan);
     if(!sticky)break;
     }
  return 0;}