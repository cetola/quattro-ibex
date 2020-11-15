#include <signal.h>
#include <string>
#include <iostream>
#include <fstream>

#include "tbxcmanager.hxx"
#ifndef TBX_WITH_LINT
#include "tbxChannel.hxx"
#endif

using std::string;
using namespace std;

static bool doneFlag = false;

static void finishSimCallback(
    SceMiControlCallbackReason reason,
    SceMiU64 time,
    void* context)
{
    if (reason == SceMiFinishSimReason)
    {
        if (time != 0xffffffffffffffffULL)
            cout << "Simulation Finished at time " << time << endl;
        doneFlag = true;
    }
}


#ifndef TBX_WITH_LINT  
extern bool gIsTBXDefaultCMainUsed;
#endif
int main(int argc, char* argv[])
{
#ifndef TBX_WITH_LINT  
    gIsTBXDefaultCMainUsed = true;
#endif    
    try
    {
        TbxCManager tbx(argc, argv);
        TbxManager::RegisterControlCallbackFunction(finishSimCallback);
        while (!doneFlag)
            tbx.Synchronize();
    }
    catch(string message)
    {
        cerr << message << endl;
        cerr << "Fatal Error: Program aborting." << endl;
        return -1;
    }
    return 0;
}
