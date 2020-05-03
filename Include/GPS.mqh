//GPS by FooeyBar/Beerrun
//#property copyright "Copyright 15 March 2019, FooeyBar/Beerrun"

//The function returns a unique-ish ID as a string, to be used in chart objects
//and other objects/variables needing an identifier unique to the program instance.
//The id value is subject to change upon re-initialization, however each program
//instance will still have a unique-ish id.

//Call in init() if desired: GPS(0);
//Call in tick or timer event: string myID=GPS(0);
//Call in deinit(): GPS(-1);

string GPS(int event){
  static string progName=MQLInfoString(MQL_PROGRAM_NAME)+" ";
  static string mutex=progName+"Mutex";
  static int symID=0,id=0;
  string idtag=" ID#",sep=".";
  string position=progName+_Symbol+idtag;
  string savepos=position;
  int temp=0,temp2=2;
  
  if(!GlobalVariableCheck(mutex))GlobalVariableSet(mutex,0);
  if(symID!=0&&id!=0)if(!GlobalVariableCheck(savepos+" "+(string)symID))GlobalVariableSet(savepos+" "+(string)symID,id);
  
  if(event==0&&id==0){
   for(;;){if(GlobalVariableSetOnCondition(mutex,1,0))break;}
   for(int gt=GlobalVariablesTotal();gt>=0;gt--)if(StringFind(GlobalVariableName(gt),idtag,0)>-1)temp++;
   for(;temp>0;temp--){ 
    int tpos=id;
    for(int gvt=GlobalVariablesTotal(),v=0;gvt>=0;gvt--){
     string name=GlobalVariableName(gvt);
     if(StringFind(name,idtag,0)>-1){
      v=(int)GlobalVariableGet(name);
      if(v==id+1){id++;break;}}}   
    if(tpos==id)break;}
   id++;
   if(GlobalVariableCheck(savepos+" "+IntegerToString(1))){
    int try=2;
    for(int gv=GlobalVariablesTotal();;){
     if(gv>=0){
      string n=GlobalVariableName(gv);
      savepos=position+" "+IntegerToString(try);
      if(StringFind(n,savepos,0)>-1)try++;
      gv--;}
     if(gv<0){
      if(temp2==try)break;
      temp2=try;
      gv=GlobalVariablesTotal();}}
    savepos=position+" "+IntegerToString(try);
    symID=try;
    GlobalVariableSet(savepos,id);
    GlobalVariableSetOnCondition(mutex,0,1);
    return (string)symID+sep+(string)id;}     
   savepos=savepos+" "+IntegerToString(1);
   symID=1;
   GlobalVariableSet(savepos,id);
   GlobalVariableSetOnCondition(mutex,0,1);
   return (string)symID+sep+(string)id;}
     
  if(event==-1&&id!=0){ 
   for(;;){if(GlobalVariableSetOnCondition(mutex,1,0))break;}
   for(int g=GlobalVariablesTotal();g>=0;g--)if(StringFind(GlobalVariableName(g),idtag,0)>-1)temp++;
   savepos=savepos+" "+IntegerToString(symID);
   GlobalVariableDel(savepos);
   if(temp==1){
    GlobalVariableSetOnCondition(mutex,1,0);
    GlobalVariableDel(mutex);
    return (string)symID+sep+(string)id;}
   GlobalVariableSetOnCondition(mutex,0,1);
   return (string)symID+sep+(string)id;}

  return (string)symID+sep+(string)id;}