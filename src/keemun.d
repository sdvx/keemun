import std.stdio;
import std.process;
import core.thread;
import server;
import player;
import bot;
import event;

class Keemun : Thread
{
private:

    void parse(char[] s)
    {

    }
    
    int handle(Event e)
    {
        switch (e.type) {
            case EventType.CMD:
                //Handle commands
                break;
                
            case EventType.SAY:
                srv.announce(e.data);
                break;
                
            case EventType.SAVE:
                srv.save();
                break;

            case EventType.EXIT:
                srv.quit();
                return -1;
                break;
                
             default:
                break;
        }
        
        return 0;
    }
    
public:

    static shared EventQueue events;
    static Server srv;

    this()
    {
        super(&run);
    }
    
    void run()
    {
        int status = 0;
        srv = new Server("server\\TerrariaServer.exe -config server\\serverconfig.txt");
        
        char[] buf;
        while (status == 0) {
            if (events.size > 0) {
                status = handle(events.pop());
            }
        }
    }
}

void main() {
    OptimusPrime.events = cast(shared EventQueue) new EventQueue();
    Keemun.events = cast(shared EventQueue) new EventQueue();
    
    //Write a config class
    auto bot = new OptimusPrime();
    bot.nick = cast(char[]) "TRB";
    bot.user = cast(char[]) "TRB";
    bot.realname = cast(char[]) "TRB";
    bot.invisible = true;
    bot.nickserv = true;
    bot.nspass = cast(char[]) "fCr4ftB0t";
    bot.chan = cast(char[]) "#fCraft.terraria";
    bot.start();
    
    auto tea = new Keemun();
    tea.start();
    
    Thread.sleep(dur!("seconds")(10));
    auto p = new Player();
    p.start();
}