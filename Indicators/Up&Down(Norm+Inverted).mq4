#property strict
#property copyright "Copyright 27 May 2019, R. M."
#property link "https://www.mql5.com/en/users/beerrun"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_level1 0
#define NAME MQLInfoString(MQL_PROGRAM_NAME)
#define VERSION "1.0"
#property version VERSION

enum _tf_ {Current,M1,M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440,W1=10080,MN=43200};
extern _tf_ tf=0;
extern int period=18;
extern int signalbar=1;
extern color nupcolour=clrMediumTurquoise;//nUp Arrow Colour
extern color ndwcolour=clrViolet;//nDown Arrow Colour
extern color iupcolour=clrBlue;//iUp Arrow Colour
extern color idwcolour=clrRed;//iDown Arrow Colour

datetime newbar=0;
int initsw=1;
double normal[],invert[];

int init(){
  SetIndexBuffer(0,normal);
  SetIndexStyle(0,DRAW_LINE,0,1,clrYellow);
  
  SetIndexBuffer(1,invert);
  SetIndexStyle(1,DRAW_LINE,0,1,clrGray);
  
  
  return(0);}

int deinit(){
  for(int i=ObjectsTotal()-1;i>=0;i--)
   if(StringFind(ObjectName(i),NAME)>-1)ObjectDelete(ObjectName(i));
    return(0);}

void start(){
  if(newbar>=iTime(NULL,tf,0))return;
  double nvalue=0,nvalue1=0,nfish=0,nlo=0,nhi=0,
         ivalue=0,ivalue1=0,ifish=0,ilo=0,ihi=0;
  
  for(int i=0;i<iBars(NULL,tf)-1;i++){
     nhi=iHigh(NULL,tf,iHighest(NULL,tf,MODE_CLOSE,period,i));
     nlo=iLow(NULL,tf,iLowest(NULL,tf,MODE_CLOSE,period,i));                          
     if(nhi==0||nlo==0)continue;
     nvalue=MathMin(MathMax((0.33*2*((((iOpen(NULL,tf,i)+iClose(NULL,tf,i))/2)-nhi)/(nlo-nhi)-0.5)+0.67*nvalue1),-0.999),0.999);  
     if(nhi==nlo)nvalue=MathMin(MathMax((0.33*2*(0-0.5)+0.67*nvalue1),-0.999),0.999);
     normal[i]=(0.5*MathLog((1+nvalue)/(1-nvalue))+0.5*nfish);
     if(nvalue==1)normal[i]=(0.5+0.5*nfish);
     nvalue1=nvalue;
     nfish=normal[i];
     
     ihi=iHigh(NULL,tf,iHighest(NULL,tf,MODE_CLOSE,period,i));
     ilo=iLow(NULL,tf,iLowest(NULL,tf,MODE_CLOSE,period,i));                          
     if(ihi==0||ilo==0)continue;
     ivalue=MathMin(MathMax((0.33*2*((((iOpen(NULL,tf,i)+iClose(NULL,tf,i))/2)-ihi)/(ilo-ihi)-0.5)+0.67*ivalue1),-0.999),0.999);  
     if(ihi==ilo)ivalue=MathMin(MathMax((0.33*2*(0-0.5)+0.67*ivalue1),-0.999),0.999);
     invert[i]=1/(0.5*MathLog((1+ivalue)/(1-ivalue))+0.5*ifish);
     if(ivalue==1)invert[i]=1/(0.5+0.5*ifish);
     ivalue1=ivalue;
     ifish=invert[i];}

     for(int j=iBars(NULL,tf)-4;j>=0;j--){
      if(normal[j+signalbar+1]>0.0&&normal[j+signalbar]<0.0)nDraw(j+1,nupcolour);
      if(normal[j+signalbar+1]<0.0&&normal[j+signalbar]>0.0)nDraw(j+1,ndwcolour);
      if(invert[j+signalbar+1]>0.0&&invert[j+signalbar]<0.0)iDraw(j+1,iupcolour);
      if(invert[j+signalbar+1]<0.0&&invert[j+signalbar]>0.0)iDraw(j+1,idwcolour);
      }
    
    newbar=iTime(NULL,tf,0);
    initsw=0;
    return;}
    
void nDraw(int b,color colour){
    static datetime lasttime=0;
    static int dir=0;
    int theCode=(colour==nupcolour)?233:234;
    if((dir==1&&theCode==233)||(dir==-1&&theCode==234))return;
    for(int i=0;i<=ObjectsTotal();i++){
     string name=ObjectName(i);
     if(iTime(NULL,tf,b)==(datetime)ObjectGet(name,0))return;}
    string objName=IntegerToString(b)+NAME;
    double gap=3.0*iATR(NULL,tf,20,b)/4.0;
    if(ObjectCreate(objName,OBJ_ARROW,0,iTime(NULL,tf,b),0)){
     ObjectSet(objName,OBJPROP_COLOR,colour);  
     ObjectSet(objName,OBJPROP_WIDTH,1);  
     if(colour==nupcolour)ObjectSet(objName,OBJPROP_PRICE1,iClose(NULL,tf,b)-gap);
     if(colour==ndwcolour)ObjectSet(objName,OBJPROP_PRICE1,iOpen(NULL,tf,b)+gap);
     if(iTime(NULL,tf,b)>lasttime){
      ObjectSet(objName,OBJPROP_ARROWCODE,theCode);
      lasttime=iTime(NULL,tf,b); 
      if(theCode==233)dir=1;
      if(theCode==234)dir=-1;
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
    for(int i=0;i<=ObjectsTotal();i++){
     string name=ObjectName(i);
     if(iTime(NULL,tf,b)==(datetime)ObjectGet(name,0))return;}
    string objName=IntegerToString(b)+NAME;
    double gap=3.0*iATR(NULL,tf,20,b)/4.0;
    if(ObjectCreate(objName,OBJ_ARROW,0,iTime(NULL,tf,b),0)){
     ObjectSet(objName,OBJPROP_COLOR,colour);  
     ObjectSet(objName,OBJPROP_WIDTH,1);  
     if(colour==iupcolour)ObjectSet(objName,OBJPROP_PRICE1,iClose(NULL,tf,b)-gap);
     if(colour==idwcolour)ObjectSet(objName,OBJPROP_PRICE1,iOpen(NULL,tf,b)+gap);
     if(iTime(NULL,tf,b)>lasttime){
      ObjectSet(objName,OBJPROP_ARROWCODE,theCode);
      lasttime=iTime(NULL,tf,b);
      if(theCode==233)dir=1;
      if(theCode==234)dir=-1;
      return;}
     int rptcode=0;
     if(theCode==233)rptcode=241;
     if(theCode==234)rptcode=242;
     ObjectSet(objName,OBJPROP_ARROWCODE,rptcode);}}