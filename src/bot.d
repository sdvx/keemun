import std.stdio;
import std.socket;
import std.socketstream;
import std.array;
import std.regex;
//import core.thread;
import core.time;
import event;

class OptimusPrime : core.thread.Thread
{

private:

    const char[] CTCP = [cast(char) 0x01];
    char[] server;
    ushort port;
    TcpSocket sock;
    SocketStream stream;

public:

    static shared EventQueue events;
    char[] nick;
    char[] altnick;
    char[] user;
    char[] realname;
    char[] nspass;
    char[] chan;
    bool invisible = false;
    bool nickserv = false;

    this()
    {
        super(&run);
    }

    void connect(immutable char[] s, ushort p = 6667)
    {
        server = cast(char[]) s;
        sock = new TcpSocket(new InternetAddress(s, p));
        stream = new SocketStream(sock);

        setnick(nick);
        setuser(user, realname, invisible);

        char[] ping;
        while (true) {
            if ((ping = rec())[0..4] == "PING")
            break;
        }

        ping[1] = 'O';
        send(ping);
        
        if (nickserv)
            ns("IDENTIFY " ~ nspass);

        join(chan);
    }

    void send(char[] m)
    {
        sock.send(m ~ "\r\n");
    }

    void msg(char[] m, char[] r = ['\0'])
    {
        send("PRIVMSG " ~ ((r == ['\0']) ? chan : r) ~ " :" ~ m);
    }

    void action(char[] m, char[] c = ['\0'])
    {
        msg(CTCP ~ "ACTION " ~ m ~ CTCP, c);
    }

    void setnick(char[] m)
    {
        send("NICK " ~ m);
    }

    void setuser(char[] u, char[] r, bool i)
    {
        send("USER " ~ u ~ ((i) ? " 8" : " 0") ~ " * :" ~ r);
    } 

    void ns(char[] m)
    {
        msg(m, cast(char[]) "NICKSERV");
    }

    void join(char[] m)
    {
        send("JOIN :" ~ m);
    }

    bool alive()
    {
        return sock.isAlive();
    }

    void quit()
    {
        send(cast(char[]) "QUIT :Bye~");
        sock.close();
    }

    char[] rec()
    {
        if (sock.isAlive()) {
            char[] m = stream.readLine();
            //writeln(m);
            return m;
        }
        return null;
    }
    
    char[][] ops()
    {
        char[][] temp;
        
        send("NAMES " ~ chan);
        
        char[] ret;
        while (true) {
            ret = rec();
            
            if (std.string.indexOf(ret, "353 " ~ nick) > -1) {
                foreach(m; match(ret, regex(r"@([A-Za-z0-9\[\]{}\\|^`_-]+)", "g")))
                    temp ~= [m.hit[1..$]];
            }
                
            if (std.string.indexOf(ret, "End of /NAMES list.") != -1)
                break;
        };
        return temp;
    }
    
    void handle(Event e)
    {
        if (e !is null) {
            switch (e.type) {
                default:
                    msg(e.data);
                    break;
            }
        }
    }
    
    void run()
    {
        writeln("Bot running");
        int status = 0;
        connect("irc.esper.net");
        
        char[] ping;
        while (status == 0) {
            if ((ping = rec())[0..4] == "PING") {
                ping[1] = 'O';
                send(ping);
            }
            
            if (events.size > 0) {
                writeln("Handling events");
                handle(events.pop());
            }
        }
    }
}
/*
void main()
{
    auto bot = new OptimusPrime();
    bot.nick = "TRB";
    bot.user = "TRB";
    bot.realname = "TRB";
    bot.invisible = true;
    bot.nickserv = true;
    bot.nspass = "fCr4ftB0t";
    bot.chan = "#fCraft";
    
    //core.thread.Thread.sleep(dur!("seconds")(3));
    
    char[] o = cast(char[]) "Channel ops: ";
    char[][] op = bot.ops();
    
    foreach (u; op)
        o ~= (u ~ [',', ' ']);
        
    bot.msg(o[0..$-2]);

    //core.thread.Thread.sleep(dur!("seconds")(3));
    
    bot.quit();
}*/
