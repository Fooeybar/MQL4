//sdg
#property copyright "Copyright 1 May 2020, Beerrun"
#property link "https://www.forexfactory.com/beerrun"
#property strict
#property indicator_chart_window
#define label MQLInfoString(MQL_PROGRAM_NAME)+" Label"

extern color bullColour=clrForestGreen;//Bull Colour
extern color bearColour=clrFireBrick;//Bear Colour
extern color dojiColour=clrGray;//Doji Colour

int OnInit(){
   if(ObjectCreate(label,OBJ_LABEL,0,0,0)){
      ObjectSet(label,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSet(label,OBJPROP_XDISTANCE,300);
      ObjectSet(label,OBJPROP_YDISTANCE,20);
      }
   return 0;}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime& time[],const double& open[],const double& high[],
                const double& low[],const double& close[],const long& tick_volume[],const long& volume[],const int& spread[]){
       if(prev_calculated==rates_total)return rates_total;
       static int bullCnt=0,bearCnt=0,dojiCnt=0;
       for(int i=prev_calculated==0?rates_total-1:rates_total-prev_calculated;i>0;i--){
         if(close[i]>open[i]){bullCnt++;continue;}
         if(close[i]<open[i]){bearCnt++;continue;}
         dojiCnt++;         
         }
       
       static color lastColour=NULL;
       color colour=bullCnt>bearCnt?bullColour:bullCnt<bearCnt?bearColour:lastColour;
       if(dojiCnt>bullCnt&&dojiCnt>bearCnt)colour=dojiColour;
       lastColour=colour;
       ObjectSetText(label,"Bulls:"+(string)bullCnt+"  Bears:"+(string)bearCnt+"  Doji:"+(string)dojiCnt,14,"Arial",colour);
       
       return rates_total;}

void OnDeinit(const int re){ObjectDelete(label);}  