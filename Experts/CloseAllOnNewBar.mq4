#property copyright "Copyright 16 September 2019, R.M."
#property link "https://www.mql5.com/en/users/beerrun"
#property strict

enum _orders {All,
              symbol//Only This Symbol
              };
extern _orders orders=0;//Close Which Orders?
extern int slip=2;//Slippage

int start(){
  static datetime newbar=Time[0];
  bool close=NULL;
  if(newbar>=Time[0])return(0);
  newbar=Time[0];
  for(int ord=OrdersTotal()-1;ord>=0;ord--){
   if(OrderSelect(ord,SELECT_BY_POS,MODE_TRADES)){
    if(orders==1)
     if(OrderSymbol()==_Symbol){
      if(OrderType()==0)close=OrderClose(OrderTicket(),OrderLots(),Bid,slip,clrNONE);
      if(OrderType()==1)close=OrderClose(OrderTicket(),OrderLots(),Ask,slip,clrNONE);
      if(OrderType()>=2)close=OrderDelete(OrderTicket(),clrNONE);
      continue;}
    if(orders==0){
     if(OrderType()==0)close=OrderClose(OrderTicket(),OrderLots(),Bid,slip,clrNONE);
     if(OrderType()==1)close=OrderClose(OrderTicket(),OrderLots(),Ask,slip,clrNONE);
     if(OrderType()>=2)close=OrderDelete(OrderTicket(),clrNONE);
     continue;}}}
     
  return(0);}
