#define NAME MQLInfoString(MQL_PROGRAM_NAME)
#define VERSION "1.0"
#property version VERSION
#property copyright "Copyright 5 May 2019, R. M."
#property link "https://www.mql5.com/en/users/beerrun"
#property strict

enum _tf_ {Current,M1,M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440,W1=10080,MN=43200};
extern _tf_ tf=0;
extern int period=2;
extern int signalbar=1;
extern color nupcolour=clrMediumTurquoise;//nUp Arrow Colour
extern color ndwcolour=clrViolet;//nDown Arrow Colour
extern color iupcolour=clrBlue;//iUp Arrow Colour
extern color idwcolour=clrRed;//iDown Arrow Colour
extern string _trd_="------------------------------------";//---Trade Options-----------------------------
enum ny {No,Yes};
extern ny man=Yes;//Include User-placed Market Orders
enum _strat_ {nor,//Normal Indicator
              inv,//Inverted Indicator
              comb//Combined Indicator
              };
extern _strat_ STRAT=comb;//Trading Method
extern double MAX=20;//Maximum Spread To Open (Points)
extern double lotsize=0.01;//Lot Size
extern int slip=1;//Slippage
extern string comment="";//Order Comment
extern int magic=99;//Magic Number
datetime newbar=0;
int initsw=1;
double normal[],invert[];

int init(){
  ArrayResize(normal,iBars(NULL,tf));
  ArrayInitialize(normal,-1);
  ArrayResize(invert,iBars(NULL,tf));
  ArrayInitialize(invert,-1);
  return(0);}

int deinit(){
  for(int i=ObjectsTotal()-1;i>=0;i--){
   if(IsStopped())break;
   if(StringFind(ObjectName(i),NAME)>-1)ObjectDelete(ObjectName(i));}
    return(0);}

void OnTick(){
  if(!IsTesting())return;
  if(man)Trades(0,0,0);
  if(newbar>=iTime(NULL,tf,0))return;
  double nvalue=0,nvalue1=0,nfish=0,nlo=0,nhi=0,
         ivalue=0,ivalue1=0,ifish=0,ilo=0,ihi=0;
  
  for(int i=0;i<iBars(NULL,tf)-1;i++){
   if(IsStopped())break;
    if(STRAT==0||STRAT==2){
    if(initsw==0)ArrayResize(normal,ArraySize(normal)+1);
    nhi=iHigh(NULL,tf,iHighest(NULL,tf,MODE_CLOSE,period,i));
    nlo=iLow(NULL,tf,iLowest(NULL,tf,MODE_CLOSE,period,i));                          
    if(nhi==0||nlo==0)continue;
    nvalue=MathMin(MathMax((0.33*2*((((iOpen(NULL,tf,i)+iClose(NULL,tf,i))/2)-nhi)/(nlo-nhi)-0.5)+0.67*nvalue1),-0.999),0.999);  
    if(nhi==nlo)nvalue=MathMin(MathMax((0.33*2*(0-0.5)+0.67*nvalue1),-0.999),0.999);
    normal[i]=(0.5*MathLog((1+nvalue)/(1-nvalue))+0.5*nfish);
    if(nvalue==1)normal[i]=(0.5+0.5*nfish);
    nvalue1=nvalue;
    nfish=normal[i];}
     
   if(STRAT==1||STRAT==2){
    if(initsw==0)ArrayResize(invert,ArraySize(invert)+1);
    ihi=iHigh(NULL,tf,iHighest(NULL,tf,MODE_CLOSE,period,i));
    ilo=iLow(NULL,tf,iLowest(NULL,tf,MODE_CLOSE,period,i));                          
    if(ihi==0||ilo==0)continue;
    ivalue=MathMin(MathMax((0.33*2*((((iOpen(NULL,tf,i)+iClose(NULL,tf,i))/2)-ihi)/(ilo-ihi)-0.5)+0.67*ivalue1),-0.999),0.999);  
    if(ihi==ilo)ivalue=MathMin(MathMax((0.33*2*(0-0.5)+0.67*ivalue1),-0.999),0.999);
    double denominator=(0.5*MathLog((1+ivalue)/(1-ivalue))+0.5*ifish);
    if(denominator!=0)invert[i]=1/denominator;
    if(denominator==0)invert[i]=0;
    double _denominator=(0.5+0.5*ifish);
    if(_denominator!=0)if(ivalue==1)invert[i]=1/_denominator;
    if(_denominator==0)if(ivalue==1)invert[i]=0;
    ivalue1=ivalue;
    ifish=invert[i];}}

     for(int j=iBars(NULL,tf)-4;j>=0;j--){
      if(IsStopped())break;
      if(normal[j+signalbar+1]>0.0&&normal[j+signalbar]<0.0)if(STRAT!=1)nDraw(j+1,nupcolour);
      if(normal[j+signalbar+1]<0.0&&normal[j+signalbar]>0.0)if(STRAT!=1)nDraw(j+1,ndwcolour);
      if(invert[j+signalbar+1]>0.0&&invert[j+signalbar]<0.0)if(STRAT!=0)iDraw(j+1,iupcolour);
      if(invert[j+signalbar+1]<0.0&&invert[j+signalbar]>0.0)if(STRAT!=0)iDraw(j+1,idwcolour);}
    
    newbar=iTime(NULL,tf,0);
    initsw=0;
    return;}
    
void nDraw(int b,color colour){
    static datetime lasttime=0;
    static int dir=0;
    int theCode=(colour==nupcolour)?233:234;
    if((dir==1&&theCode==233)||(dir==-1&&theCode==234))return;
    for(int i=0;i<=ObjectsTotal()-1;i++){
     if(IsStopped())break;
     string name=ObjectName(i);
     if(iTime(NULL,tf,b)==(datetime)ObjectGet(name,0))return;}
    string objName=IntegerToString(b)+NAME;
    double gap=3.0*iATR(NULL,tf,20,b)/4.0;
    if(ObjectCreate(objName,OBJ_ARROW,0,iTime(NULL,tf,b),0)){
     ObjectSet(objName,OBJPROP_COLOR,colour);  
     ObjectSet(objName,OBJPROP_WIDTH,1);  
     double price=0;
     if(colour==nupcolour)price=iClose(NULL,tf,b)-gap;
     if(colour==ndwcolour)price=iOpen(NULL,tf,b)+gap;
     ObjectSet(objName,OBJPROP_PRICE1,price);
     if(iTime(NULL,tf,b)>lasttime){
      ObjectSet(objName,OBJPROP_ARROWCODE,theCode);
      lasttime=iTime(NULL,tf,b); 
      if(theCode==233)dir=1;
      if(theCode==234)dir=-1;
      if(STRAT==0||STRAT==2)Trades(dir,price,1);
      return;}
     int rptcode=0;
     if(theCode==233)rptcode=241;
     if(theCode==234)rptcode=242;
     ObjectSet(objName,OBJPROP_ARROWCODE,rptcode);}}
     
void iDraw(int b,color colour){
    static datetime lasttime=0;
    static int dir=0;
    int theCode=(colour==iupcolour)?233:234;
    if((dir==1&&theCode==233)||(dir==-1&&theCode==234))return;
    for(int i=0;i<=ObjectsTotal()-1;i++){
     if(IsStopped())break;
     string name=ObjectName(i);
     if(iTime(NULL,tf,b)==(datetime)ObjectGet(name,0))return;}
    string objName=IntegerToString(b)+NAME;
    double gap=3.0*iATR(NULL,tf,20,b)/4.0;
    if(ObjectCreate(objName,OBJ_ARROW,0,iTime(NULL,tf,b),0)){
     ObjectSet(objName,OBJPROP_COLOR,colour);  
     ObjectSet(objName,OBJPROP_WIDTH,1);  
     double price=0;
     if(colour==iupcolour)price=iClose(NULL,tf,b)-gap;
     if(colour==idwcolour)price=iOpen(NULL,tf,b)+gap;
     ObjectSet(objName,OBJPROP_PRICE1,price);
     if(iTime(NULL,tf,b)>lasttime){
      ObjectSet(objName,OBJPROP_ARROWCODE,theCode);
      lasttime=iTime(NULL,tf,b);
      if(theCode==233)dir=1;
      if(theCode==234)dir=-1;
      if(STRAT==1||STRAT==2)Trades(dir,price,-1);
      return;}
     int rptcode=0;
     if(theCode==233)rptcode=241;
     if(theCode==234)rptcode=242;
     ObjectSet(objName,OBJPROP_ARROWCODE,rptcode);}}
     
bool Trades(int dir,double price,int ind){
  if(initsw==1)return(false);
  static bool ticket=false;
  static int tempdir=0;
  
  if(dir==0){
    for(int mo=OrdersTotal()-1;mo>=0;mo--)
     if(OrderSelect(mo,SELECT_BY_POS,MODE_TRADES))
      if(OrderSymbol()==Symbol())
       if(OrderType()==0||OrderType()==1){
        ticket=true;return(true);}
   return(ticket);}
  
  if((ticket||man)&&tempdir!=dir){
   for(int ord=OrdersTotal()-1;ord>=0;ord--){
    if(IsStopped())break;
    if(OrderSelect(ord,SELECT_BY_POS,MODE_TRADES))
     if(OrderSymbol()==Symbol()){
      if(OrderType()==2||OrderType()==3)if(OrderDelete(OrderTicket()))continue;
      if(man){
       if(OrderType()==0)if(OrderClose(OrderTicket(),OrderLots(),Bid,slip))continue;
       if(OrderType()==1)if(OrderClose(OrderTicket(),OrderLots(),Ask,slip))continue;}}}
   ticket=false;}
  
  price=round(price/_Point)*Point;
  
  if(!ticket){
   if(ind==1)return(false);
   if(dir==1)
    if(OrderSend(NULL,2,lotsize,price,slip,0,0,comment,magic)){
     tempdir=dir;
     ticket=true;
     return(true);}
    else Print("OrderSend error! Error# "+IntegerToString(GetLastError()));
   if(dir==-1)
    if(OrderSend(NULL,3,lotsize,price,slip,0,0,comment,magic)){
     tempdir=dir;
     ticket=true;
     return(true);}
    else Print("OrderSend error! Error# "+IntegerToString(GetLastError()));}
   
   return(false);}