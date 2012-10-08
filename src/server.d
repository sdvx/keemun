import std.stdio;
import std.conv;
import core.thread;
import pipe;
import player;

class Server
{
private:

    FILE* f;
    
public:

    this (immutable char[] s)
    {
        f = wpopen(cast(char*) s, cast(char*) "w");
    }
        
    void announce(char[] s)
    {
        wfputs(cast(char*)("say " ~ s ~ "\n"), f);
        wfflush(f);
    }
    
    void save()
    {
        wfputs(cast(char*) "save\n", f);
        wfflush(f);
    }
    
    void quit()
    {
        wfputs(cast(char*) "exit\n", f);
        wfflush(f);
    }
}
