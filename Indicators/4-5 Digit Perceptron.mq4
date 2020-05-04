//sdg
#define   NAME MQLInfoString(MQL_PROGRAM_NAME)
#property copyright   "Copyright 8 Feb 2019, R.M."
#property link        "https://www.mql5.com/en/users/beerrun"
#property strict
#property indicator_chart_window
#property indicator_buffers 1

extern color colour=clrMediumTurquoise;//Colour
double x=0,sum=0,rate=1,t=0;
int dRelu=0;
//simple peristence model example, small weights just as good as random, not suitable for trading information
double wclose=0.05,wopen=0.05,wlow=0.05,whigh=0.05,prelu=0.1;
double line[];
//=================================================================================================//
int init(){
   SetIndexShift(0,1);
   SetIndexBuffer(0,line);
   SetIndexStyle(0,DRAW_LINE,0,1,colour);
   return(0);}
   
int start(){
   for(int i=Bars-1-IndicatorCounted();i>=0;i--){      
      //sum=(High[i]*whigh)+(Close[i]*wclose)+(Open[i]*wopen)+(Low[i]*wlow);  
      sum=(Close[i]*wclose)+(Open[i]*wopen); 
      x=(sum>t)?sum:prelu*sum;//Relu and PRelu do not normally belong in this, just an example
      dRelu=(x>0)?1:0;
      line[i]=x;

      wopen-=(x-Open[i])*dRelu*wopen;
      wclose-=(x-Close[i])*dRelu*wclose;
      //too much noise
      //whigh-=(x-High[i])*dRelu*whigh;
      //wlow-=(x-Low[i])*dRelu*wlow;
      prelu-=(0-prelu)*dRelu*prelu;
      t-=rate*(x-sum);}
      
return(0);}
