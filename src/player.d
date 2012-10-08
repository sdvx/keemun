import std.socket;
import std.socketstream;
import std.stdio;
import std.conv;
import core.thread;
import message;
import event;
import bot;

class Player : Thread
{
private:

    char[] server;
    ushort port;
    TcpSocket sock;
    SocketStream stream;
    Messenger m;
    ubyte slot;
    ubyte[] winfo;
    
public:
    
    static shared EventQueue events;

    this()
    {
        super(&run);
    }
    
    void connect(immutable char[] s, ushort p = 7777)
    {
        server = cast(char[]) s;
        port = p;
        m = new Messenger();
        sock = new TcpSocket(new InternetAddress(server, port));
        stream = new SocketStream(sock);
        
        ubyte[256] buf;
        
        //Login sequence for Terraria
        send(m.CONNECT);
        
        //Wait for connection approval
        //## Need to add a timeout
        while (true) {
            if (stream.read(buf[0..6]) > 0)
                break;
        }
        
        if (buf[4] == 0x25) {
            //Password required
        }
        
        //Connection denied
        if (buf[4] != 0x03) {
            sock.close();
            return;
        }
        
        //Connection approved, store player slot 
        slot = buf[5];
        m.init(slot);
        
        writefln("Connection approved, slot: %d", slot);
        
        //Send appearance
        send(m.APPEARANCE);
        
        //Send life, mana, and buffs
        send(m.LIFE);
        send(m.MANA);
        send(m.BUFFS);
        
        //Send inventory data
        ubyte[] inv = m.INVENTORY.dup;
        for (ubyte i = 0x00; i < 0x3C; i++) {
            inv[6] = i;
            send(inv);
        }
        
        //Request world information
        send(m.RWORLDINFO);
        
        //Retrieve world information
        //## Add timeout
        while (true) {
            if (stream.read(buf[0..1]) > 0) {
                //Error
                if (buf[0] == 0x02) {
                    sock.close();
                    return;
                }
                
                //Success
                if (buf[0] == 0x07) {
                    stream.read(buf);
                    break;
                }
            }
        }
        
        //Store world info
        winfo = buf.dup;
        
        //Request initial tile data
        send(m.RTILEDATA ~ winfo[15..23]);
        
        //Wait for spawn request
        //## Add timeout
        while (true) {
            if (stream.read(buf[0..1]) > 0) {
                if (buf[0] == 0x31)
                    break;
            }
        }
        
        //Spawn player in world
        send(m.SPAWN ~ winfo[15..23]);
    }
    
    void send(ubyte[] data)
    {
        sock.send(data);
    }
    
    void msg(char[] data)
    {
        ubyte[] c = cast(ubyte[]) [
            data.length + 0x05, 0x00, 0x00, 0x00,
            0x19,
            slot,
            0xFF, 0xFF, 0xFF
        ] ~ cast(ubyte[]) data;
        writeln(c);
        send(c);
    }
    
    void harp(float f)
    {
        ubyte[] note = (cast(ubyte*)&f)[0..4];
        writeln(note);
        send(cast(ubyte[]) [
            0x06, 0x00, 0x00, 0x00,
            slot
        ] ~ note);
    }
    
    void parse(ubyte[] d)
    {
        char[] s = cast(char[]) (text(d[0]) ~ " : " ~ to!(char[])(d[1..$]));
        OptimusPrime.events.add(EventType.SAY, cast(immutable char[]) s);
    }
    
    void run()
    {
        int status = 0;
        connect("127.0.0.1");
        
        ubyte[64] buf;
        while (status == 0) {
            if (stream.read(buf) > 0) {
                if (buf[5] == 0x19) {
                    parse(buf[6..$]);
                }
            }
        }
    }

}
/*
void main()
{
    auto p = new Player(cast(char[]) "127.0.0.1", 7777);
    p.connect();
}*/