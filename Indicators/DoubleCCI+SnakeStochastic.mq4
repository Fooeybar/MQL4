#define NAME MQLInfoString(MQL_PROGRAM_NAME)
#property copyright "Copyright 7 June 2019, R.M."
#property link "https://www.forexfactory.com/Beerrun"
#property strict
#property indicator_separate_window
#property indicator_buffers 8
#define cci 0
#define snake 1

extern double levels=70;//OS/OB Levels %
input int cci1period=50;//CCI 1 Period
extern color cci1col=clrPink;//CCI 1 Colour
extern int cci2period=100;//CCI 2 Period
extern color cci2col=clrLightBlue;//CCI 1 Colour
extern int snakehalfcycle=12;//Snake HalfCycle
extern color snakecolour=clrLemonChiffon;//Colour

bool initsw=true;
datetime newbar=0;
double CCI1[],Price1[],Mov1[],CCI2[],Price2[],Mov2[],
       Snake[],SNAKE[];
//+------------------------------------------------------------------+
int init(){
  IndicatorSetString(INDICATOR_SHORTNAME,NAME);
  IndicatorSetInteger(INDICATOR_LEVELS,1);
  IndicatorSetInteger(INDICATOR_LEVELSTYLE,2);
  IndicatorSetInteger(INDICATOR_LEVELCOLOR,clrGray);
  IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0);
  
  ObjectCreate(0,NAME+" OS",OBJ_HLINE,ChartWindowFind(0,NAME),0,-levels*0.01);
  ObjectSetInteger(0,NAME+" OS",OBJPROP_COLOR,clrMediumTurquoise);
  ObjectCreate(0,NAME+" OB",OBJ_HLINE,ChartWindowFind(0,NAME),0,levels*0.01);
  ObjectSetInteger(0,NAME+" OB",OBJPROP_COLOR,clrViolet);
  
  SetIndexBuffer(0,CCI1);SetIndexLabel(0,"CCI "+IntegerToString(cci1period));
  SetIndexStyle(0,DRAW_LINE,0,EMPTY,cci1col);
  SetIndexBuffer(1,Price1);SetIndexLabel(1,NULL);
  SetIndexBuffer(2,Mov1);SetIndexLabel(2,NULL);
  SetIndexBuffer(3,CCI2);SetIndexLabel(3,"CCI "+IntegerToString(cci2period));
  SetIndexStyle(3,DRAW_LINE,0,EMPTY,cci2col);
  SetIndexBuffer(4,Price2);SetIndexLabel(4,NULL);
  SetIndexBuffer(5,Mov2);SetIndexLabel(5,NULL);
  
  SetIndexBuffer(6,Snake);SetIndexStyle(6,0,0,1,snakecolour);SetIndexLabel(6,"Snake "+IntegerToString(snakehalfcycle));
  SetIndexBuffer(7,SNAKE);SetIndexLabel(7,NULL);

  return(0);}

//+------------------------------------------------------------------+
int deinit(){
 ObjectDelete(0,NAME+" OS");
 ObjectDelete(0,NAME+" OB");
 return(-1);}
 
//+------------------------------------------------------------------+
int start(){
  CCI(1);
  CCI(2);
  Snake(-1,snakehalfcycle);
  return(-1);}
  
//+------------------------------------------------------------------+
void CCI(int ind){
  int    i=0,k=0,pos=0;
  double dSum=0,dMul=0;
  if(ind==1){
   ArraySetAsSeries(CCI1,false);
   ArraySetAsSeries(Price1,false);
   ArraySetAsSeries(Mov1,false);}
  if(ind==2){
   ArraySetAsSeries(CCI2,false);
   ArraySetAsSeries(Price2,false);
   ArraySetAsSeries(Mov2,false);}
  ArraySetAsSeries(High,false);
  ArraySetAsSeries(Low,false);
  ArraySetAsSeries(Close,false);
  if(initsw){
   if(ind==1)for(i=0;i<cci1period;i++){CCI1[i]=Mov1[i]=0.0;Price1[i]=(High[i]+Low[i]+Close[i])/3;}
   if(ind==2)for(i=0;i<cci2period;i++){CCI2[i]=Mov2[i]=0.0;Price2[i]=(High[i]+Low[i]+Close[i])/3;}}
  pos=IndicatorCounted()-1;
  if(ind==1)if(pos<cci1period)pos=cci1period;
  if(ind==2)if(pos<cci2period)pos=cci2period;
  if(ind==1)for(i=pos;i<Bars;i++){Price1[i]=(High[i]+Low[i]+Close[i])/3;Mov1[i]=SimpleMA(i,cci1period,Price1);}
  if(ind==2)for(i=pos;i<Bars;i++){Price2[i]=(High[i]+Low[i]+Close[i])/3;Mov2[i]=SimpleMA(i,cci2period,Price2);}
  if(ind==1){dMul=0.015/cci1period;pos=cci1period-1;}
  if(ind==2){dMul=0.015/cci2period;pos=cci2period-1;}
  if(pos<IndicatorCounted()-1)pos=IndicatorCounted()-2;
  for(i=pos;i<Bars;i++){
   dSum=0.0;
   if(ind==1)for(k=i+1-cci1period;k<=i;k++)dSum+=MathAbs(Price1[k]-Mov1[i]);
   if(ind==2)for(k=i+1-cci2period;k<=i;k++)dSum+=MathAbs(Price2[k]-Mov2[i]);
   dSum*=dMul;
   if(ind==1){
    if(dSum==0.0)CCI1[i]=0.0;
    else CCI1[i]=nmz(cci,(Price1[i]-Mov1[i])/dSum);}
   if(ind==2){
    if(dSum==0.0)CCI2[i]=0.0;
    else CCI2[i]=nmz(cci,(Price2[i]-Mov2[i])/dSum);}}
  ArraySetAsSeries(High,true);
  ArraySetAsSeries(Low,true);
  ArraySetAsSeries(Close,true);
  return;}

//+------------------------------------------------------------------+
double SimpleMA(int position,int tf,double &price[]){
  double result=0.0;
  if(position>=tf-1&&tf>0){
   for(int i=0;i<tf;i++)result+=price[position-i];
   result/=tf;}
  return(result);}
  
//+------------------------------------------------------------------+
//min/max linear scaling normalization-- ((buffervalue-rmin)/(rmax-rmin))*(tmax-tmin)+tmin
//sigmoid type normalization--             buffervalue/sqrt(1+buffervalue^2)
double nmz(int id,double buffer){
  if(id==cci){
   double val=buffer*(_Digits*0.001); 
   return((val/sqrt(1+pow(val,2))));}
  if(id==snake){
   double val=(_Digits!=3)?buffer*(_Digits*1000):buffer*(_Digits*10); 
   return((val/sqrt(1+pow(val,2))));}
  return(0);}

//+------------------------------------------------------------------+
double Snake(int id,int Shift){
  static int Snake_HalfCycle=-99;
  static double Snake_Sum,Snake_Weight,Snake_Sum_Minus,Snake_Sum_Plus;
  
  if(id==-1){
   if(Snake_HalfCycle==-99)Snake_HalfCycle=Shift;
   int i=0;
   if(Snake_HalfCycle<3)Snake_HalfCycle=3;
   i=(IndicatorCounted()>0)?Snake_HalfCycle+2:Bars-Snake_HalfCycle-2;
   if(i<Snake_HalfCycle+2)i=Snake_HalfCycle+2;
   SNAKE[i]=Snake(1,i);
   i--;
   for(;i>=0;i--){
    if(i>=Snake_HalfCycle){SNAKE[i]=Snake(2,i);Snake[i]=nmz(snake,SNAKE[i]-SNAKE[i+1]);continue;}
    SNAKE[i]=Snake(1,i);Snake[i]=nmz(snake,SNAKE[i]-SNAKE[i+1]);}}
  if(id==0)return((Open[Shift]+Close[Shift]+High[Shift]+Low[Shift])/4);
  if(id==1){
   int i=0,j=0,w=0;
   Snake_Weight=Snake_Sum=0.0;
   if(Shift<Snake_HalfCycle){
    w=Shift+Snake_HalfCycle;
    while(w>=Shift){
     i++;
     Snake_Sum=Snake_Sum+i*Snake(0,w);
     Snake_Weight=Snake_Weight+i;
     w--;}
    while(w>=0){
     i--;
     Snake_Sum=Snake_Sum+i*Snake(0,w);
     Snake_Weight=Snake_Weight+i;
     w--;}}
   else{
    Snake_Sum_Plus=Snake_Sum_Minus=0.0;
    for(j=Shift-Snake_HalfCycle,i=Shift+Snake_HalfCycle,w=1;w<=Snake_HalfCycle;j++,i--,w++){
     Snake_Sum=Snake_Sum+w*(Snake(0,i)+Snake(0,j));
     Snake_Weight=Snake_Weight+2*w;
     Snake_Sum_Minus=Snake_Sum_Minus+Snake(0,i);
     Snake_Sum_Plus=Snake_Sum_Plus+Snake(0,j);}
    Snake_Sum=Snake_Sum+(Snake_HalfCycle+1)*Snake(0,Shift);
    Snake_Weight=Snake_Weight+Snake_HalfCycle+1;
    Snake_Sum_Minus=Snake_Sum_Minus+Snake(0,Shift);}
   return(Snake_Sum/Snake_Weight);}
  if(id==2){
   Snake_Sum_Plus=Snake_Sum_Plus+Snake(0,Shift-Snake_HalfCycle);
   Snake_Sum=Snake_Sum-Snake_Sum_Minus+Snake_Sum_Plus;
   Snake_Sum_Minus=Snake_Sum_Minus-Snake(0,Shift+Snake_HalfCycle+1)+Snake(0,Shift);
   Snake_Sum_Plus=Snake_Sum_Plus-Snake(0,Shift);
   return(Snake_Sum/Snake_Weight);}
  
  return(-99);}

//+------------------------------------------------------------------+