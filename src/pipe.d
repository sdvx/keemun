import std.stdio;
import std.file;

alias extern (C) FILE* function(const(char)*, const(char)*) _popen;
alias extern (C) int function(FILE*) _pclose;
alias extern (C) int function(const(char)*, FILE*) _fputs;
alias extern (C) int function(FILE*) _fflush;

_popen wpopen;
_pclose wpclose;
_fputs wfputs;
_fflush wfflush;

version (Windows)
{
    import core.sys.windows.windows;
    
    static this()
    {
        auto hMsvcrt = GetModuleHandleA("msvcrt.dll");
        wpopen = cast(_popen) GetProcAddress(hMsvcrt, "_popen");
        wpclose = cast(_pclose) GetProcAddress(hMsvcrt, "_pclose");
        wfputs = cast(_fputs) GetProcAddress(hMsvcrt, "fputs");
        wfflush = cast(_fflush) GetProcAddress(hMsvcrt, "fflush");
    }
}
