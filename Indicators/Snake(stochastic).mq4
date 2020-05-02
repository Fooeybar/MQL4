#define NAME MQLInfoString(MQL_PROGRAM_NAME)
#property copyright "Copyright 7 June 2019, R.M."
#property link      "https://www.forexfactory.com/Beerrun"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_maximum 1.0
#property indicator_minimum -1.0

extern double levels=80;//OS/OB Levels %
extern int ind1p=12;//Snake HalfCycle
extern color colour=clrGray;//Colour
extern color coloursine=clrWhiteSmoke;//Sine Colour
extern color colourcorr=clrPink;//Correlation Colour
enum _style {Solid,Dashed,Dotted,DD1,//Dashes+Dots(single)
          DD2//Dashes+Dots(double)
          };
extern _style style=0;//Line Style
enum _width{One=1,Two=2,Three=3,Four=4,Five=5};
extern _width width=1;//Line Width

datetime newbar=0;
double Snake[],SNAKE[],Snake_sine[],Corr[];

int init(){
  IndicatorSetInteger(INDICATOR_LEVELS,1);
  IndicatorSetInteger(INDICATOR_LEVELSTYLE,0);
  IndicatorSetInteger(INDICATOR_LEVELCOLOR,clrGray);
  IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0);
  ObjectCreate("OS",OBJ_HLINE,1,0,-levels*0.01);
  ObjectSetInteger(0,"OS",OBJPROP_COLOR,clrMediumTurquoise);
  ObjectCreate("OB",OBJ_HLINE,1,0,levels*0.01);
  ObjectSetInteger(0,"OB",OBJPROP_COLOR,clrViolet);
  SetIndexBuffer(0,Snake);SetIndexStyle(0,0,style,width,colour);
  SetIndexBuffer(1,SNAKE);SetIndexStyle(1,12,EMPTY,EMPTY,clrNONE);
  SetIndexBuffer(2,Snake_sine);SetIndexStyle(2,0,style,width,coloursine);
  SetIndexBuffer(3,Corr);SetIndexStyle(3,0,style,width,colourcorr);
  return(0);}

int deinit(){
 ObjectDelete(0,"OS");
 ObjectDelete(0,"OB");
 return(-1);}

int start(){
  if(newbar<iTime(NULL,0,0))newbar=iTime(NULL,0,0);
  Snake(-1,ind1p);
  return(-1);}

double nmz(double buffer){
  double val=(_Digits!=3)?buffer*(_Digits*1000):buffer*(_Digits*10); 
  return((val/sqrt(1+pow(val,2))));}

double minmax(double in){in*=10;double max=1,min=-1;return (((in-min)/(max-min))*(max-min)+min);}

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
    if(i>=Snake_HalfCycle){SNAKE[i]=Snake(2,i);Snake[i]=nmz(SNAKE[i]-SNAKE[i+1]);Snake_sine[i]=sin(Snake[i]);Corr[i]=minmax(Snake[i]-Snake_sine[i]);continue;}
    SNAKE[i]=Snake(1,i);Snake[i]=nmz(SNAKE[i]-SNAKE[i+1]);Snake_sine[i]=sin(Snake[i]);Corr[i]=minmax(Snake[i]-Snake_sine[i]);}}
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