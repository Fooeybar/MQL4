//_GPS by Beerrun (FooyBar)
//#property copyright "Copyright 23 June 2022, Beerrun (FooyBar)"
//#property version   "2.10"

//The class creates a unique-ish "_Id" as a string, to be used in chart objects
//and other objects/variables needing an identifier unique to the program instance.
//The id value is subject to change upon re-initialization, however each program
//instance will still have a unique-ish id.

class _GPS{
    private:
        string MUTEX;
        string TAG;
        uint id_num;
        void CheckMutex(double val=0);
        void LockMutex();
        void UnlockMutex();
        void DestroyMutex();
    public:
        string _Id;
        string Id();
        uint TotalIds();
        void CreateId();
        void DeleteId();
        _GPS();
        ~_GPS();
}GPS;

//===Mutex=================================================
void _GPS::CheckMutex(double val=0){
    if(!GlobalVariableCheck(MUTEX))GlobalVariableSet(MUTEX,val);
};

void _GPS::LockMutex(){
    CheckMutex();
    while(!GlobalVariableSetOnCondition(MUTEX,1,0));
};

void _GPS::UnlockMutex(){
    CheckMutex(1);
    GlobalVariableSetOnCondition(MUTEX,0,1);
};

void _GPS::DestroyMutex(){
    if(GlobalVariableCheck(MUTEX))GlobalVariableDel(MUTEX);
};

//===Constructor/Destructor================================
_GPS::_GPS(){
    TAG="GPS_ID_";
    MUTEX="GPS_MUTEX";
    id_num=0;
    _Id=NULL;
};

_GPS::~_GPS(){
    DeleteId();
};

//===Id====================================================
string _GPS::Id(){
    _Id=TAG+(string)id_num;
    return _Id;
};

uint _GPS::TotalIds(){
    uint out=0;
    for(int g=GlobalVariablesTotal();g>=0;g--)if(StringFind(GlobalVariableName(g),TAG,0)>-1)out++;
    return out;
};

void _GPS::DeleteId(){
    if(id_num>0){
        LockMutex();
        GlobalVariableDel(Id());
        if(TotalIds()<1)DestroyMutex();
        else UnlockMutex();        
    }
};

void _GPS::CreateId(){
    if(id_num<1){
        LockMutex();
        while(true){
            id_num++;
            if(!GlobalVariableCheck(Id()))break;
        }
        GlobalVariableSet(_Id,id_num);
        UnlockMutex();        
    }
};