//sdg
#property strict
#property indicator_chart_window

extern string closeLine="TotalCloseLine";
extern string closeLabel="EstimateClose";
extern color posClr=clrMediumTurquoise;//Positive Profit Colour
extern color zeroClr=clrGray;//Zero Profit Colour
extern color negClr=clrViolet;//Negative Profit Colour
enum _width{Zero,One,Two,Three,Four,Five};
extern _width width=2;//Line Width
double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);

void OnInit(){
   if(width>0)
      if(ObjectCreate(closeLine,OBJ_HLINE,0,0,(Ask+Bid)*0.5)){
         ObjectSet(closeLine,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet(closeLine,OBJPROP_WIDTH,width);
         }
   if(ObjectCreate(closeLabel,OBJ_LABEL, 0,0,0)){
      ObjectSet(closeLabel,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSet(closeLabel,OBJPROP_XDISTANCE,300);
      ObjectSet(closeLabel,OBJPROP_YDISTANCE,20);
      }
   EventSetMillisecondTimer(1);
   if(ticksize==0.00001||ticksize==0.001)ticksize*=10;  
   }
 
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
              {main();return(rates_total);}
void OnTimer(){main();}
 
void OnDeinit(const int re){
   if(re==1||re==4||re==5){ObjectDelete(0,closeLine);ObjectDelete(0,closeLabel);}
   }
 
void main(){
   long chart=ObjectFind(closeLine);
   double myProfit=chart>=0?profit(ObjectGetDouble(chart,closeLine,OBJPROP_PRICE)):profit();
   color colour=myProfit>0?posClr:myProfit<0?negClr:zeroClr;
   ObjectSetText(closeLabel,"Estimated Profit: $"+DoubleToStr(myProfit/ticksize,2),14,"Arial",colour);
   ObjectSet(closeLine,OBJPROP_COLOR,colour);
   }

double profit(double _price=NULL,int _pips=10){
  double x=0;
  for(int i=OrdersTotal()-1;i>=0;i--)
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      if(OrderSymbol()==Symbol()){
        if(_price!=NULL){
         int type=OrderType();
         if(type)x+=((OrderOpenPrice()-_price)*OrderLots()*_pips);
         if(type==0)x+=((_price-OrderOpenPrice())*OrderLots()*_pips);
         }
        else x+=OrderProfit();
        }
  return x;}


