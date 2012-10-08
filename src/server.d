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
        
        int i;
        while (getc() != '\0') {}
    }
    
    char getc()
    {
        int i;
        i = wfgetc(f);
        return (i > -1) ? to!char(i) : '\0';
    }
    
    char[] getln()
    {
        char[] buf;
        char c;
        
        while ((c = getc()) != '\0') {
            buf ~= c;
            if (c == '\n')
                break;
        }
        
        return buf;
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