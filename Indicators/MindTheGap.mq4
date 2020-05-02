#property strict
#property copyright "Copyright 15 May 2019, Beerrun"
#property link      "https://www.mql5.com/en/users/beerrun"
#define NAME MQLInfoString(MQL_PROGRAM_NAME)
#property description "--detect price gaps between the close and open of adjacent candles.\n--can detect price gaps below the size of a Point."
#property indicator_chart_window
#property indicator_buffers 4

extern double GAP=10;//Minimum Gap Size (Points)
enum _shift {cl=-1,//Close
             op//Open
             };
extern _shift SHIFT=op;//Arrow Price Point
enum _arrow {Thumbs,Arrows,
             stop,//Stop Sign
             check//Check Sign
             };
extern _arrow DRAW=Arrows;//Arrow Type
extern int SIZE=2;//Arrow Size
enum ny {No,Yes};
extern color COLOURUP=clrMediumTurquoise;//Up Colour
extern color COLOURDW=clrViolet;//Down Colour
extern ny DOJI=Yes;//Include Doji Candles
extern color COLOURDJ=clrYellow;//Doji Colour

double up_arrow[],dw_arrow[],dj_arrowup[],dj_arrowdw[];

int init(){
  SetIndexBuffer(0,up_arrow);SetIndexBuffer(1,dw_arrow);
  SetIndexBuffer(2,dj_arrowup);SetIndexBuffer(3,dj_arrowdw);
  SetIndexStyle(0,3,0,SIZE,COLOURUP);SetIndexStyle(1,3,0,SIZE,COLOURDW);
  SetIndexStyle(2,3,0,SIZE,COLOURDJ);SetIndexStyle(3,3,0,SIZE,COLOURDJ);

  if(DRAW==Thumbs){SetIndexArrow(0,67);SetIndexArrow(1,68);SetIndexArrow(2,67);SetIndexArrow(3,68);}
  if(DRAW==Arrows){SetIndexArrow(0,241);SetIndexArrow(1,242);SetIndexArrow(2,241);SetIndexArrow(3,242);}
  if(DRAW==stop){SetIndexArrow(0,251);SetIndexArrow(1,251);SetIndexArrow(2,251);SetIndexArrow(3,251);}
  if(DRAW==check){SetIndexArrow(0,252);SetIndexArrow(1,252);SetIndexArrow(2,252);SetIndexArrow(3,252);}
  if(SHIFT==cl){SetIndexShift(0,cl);SetIndexShift(1,cl);SetIndexShift(2,cl);SetIndexShift(3,cl);}
  if(SHIFT==op){SetIndexShift(0,op);SetIndexShift(1,op);SetIndexShift(2,op);SetIndexShift(3,op);}
  return(0);}
  
int start(){
  static datetime newbar=0;
  if(newbar>=iTime(NULL,0,0))return(-1);
  newbar=iTime(NULL,0,0);
  for(int i=Bars(NULL,0)-IndicatorCounted()-1;i>=0;i--){
   double close1=iClose(NULL,0,i+1),open1=iOpen(NULL,0,i+1),close0=iClose(NULL,0,i),open0=iOpen(NULL,0,i);
  
   if(close1>open1)
    if(open0>close1)
     if((open0-close1)>=(GAP*_Point)){
      up_arrow[i]=close1;
      Comment(NAME+"\nLast Gap: Up "+DoubleToString((open0-close1)*pow(10,Digits()),0)+" pts");}
  
    if(close1<open1)
     if(open0<close1)
      if((close1-open0)>=(GAP*_Point)){
       dw_arrow[i]=close1;
       Comment(NAME+"\nLast Gap: Down "+DoubleToString((close1-open0)*pow(10,Digits()),0)+" pts");}

    if(close1==open1&&DOJI){
     if(open0>close1)
      if((open0-close1)>=(GAP*_Point)){
       dj_arrowup[i]=close1;
       Comment(NAME+"\nLast Gap: Up Doji "+DoubleToString((open0-close1)*pow(10,Digits()),0)+" pts");}
     if(open0<close1)
      if((close1-open0)>=(GAP*_Point)){
       dj_arrowdw[i]=close1;
       Comment(NAME+"\nLast Gap: Down Doji "+DoubleToString((close1-open0)*pow(10,Digits()),0)+" pts");}}}

  return(0);}

int deinit(){
  Comment("");
  return(0);}