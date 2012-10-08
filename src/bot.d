import std.stdio;
import std.string;
import std.socket;
import std.socketstream;
import std.array;
import std.regex;
import core.time;
import event;

class OptimusPrime : core.thread.Thread
{

private:

    const char[] CTCP = [cast(char) 0x01];
    string server;
    ushort port;
    TcpSocket sock;
    SocketStream stream;

public:

    static shared EventQueue events;
    string nick;
    string altnick;
    string user;
    string realname;
    string nspass;
    string chan;
    bool invisible = false;
    bool nickserv = false;

    this()
    {
        super(&run);
    }

    void init()
    {
        nick = Config.get("nick");
        altnick = Config.get("altnick");
        user = Config.get("user");
        realname = Config.get("realname");
        chan = Config.get("channel");
        nspass = Config.get("ns-pass");

        nickserv = (Config.get("nickserv") == "true");
        invisible = (Config.get("invisible") == "true");
    }

    void connect(string s, ushort p = 6667)
    {
        server = s;
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

    void send(string m)
    {
        sock.send(m ~ "\r\n");
    }

    void msg(string m, string r = "")
    {
        send("PRIVMSG " ~ ((r == "") ? chan : r) ~ " :" ~ m);
    }

    void action(string m, string c = "")
    {
        msg(CTCP ~ "ACTION " ~ m ~ CTCP, c);
    }

    void setnick(string m)
    {
        send("NICK " ~ m);
    }

    void setuser(string u, string r, bool i)
    {
        send("USER " ~ u ~ ((i) ? " 8" : " 0") ~ " * :" ~ r);
    } 

    void ns(string m)
    {
        msg(m, "NICKSERV");
    }

    void join(string m)
    {
        send("JOIN :" ~ m);
    }

    bool alive()
    {
        return sock.isAlive();
    }

    void quit()
    {
        send("QUIT :Bye~");
        sock.close();
    }

    string rec()
    {
        if (sock.isAlive()) {
            string m = stream.readLine();
            return m;
        }
        return null;
    }
    
    string[] ops()
    {
        string[] temp;
        
        send("NAMES " ~ chan);
        
        string ret;
        while (true) {
            ret = rec();
            
            if (ret.indexOf("353 " ~ nick) > -1) {
                foreach(m; match(ret, regex(r"@([A-Za-z0-9\[\]{}\\|^`_-]+)", "g")))
                    temp ~= [m.hit[1..$]];
            }
                
            if (ret.indexOf("End of /NAMES list.") != -1)
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
        int status = 0;
        connect("irc.esper.net");
        
        char[] ping;
        while (status == 0) {
            if ((ping = rec())[0..4] == "PING") {
                ping[1] = 'O';
                send(ping);
            }
            
            if (events.size > 0) {
                handle(events.pop());
            }
        }
    }
}

