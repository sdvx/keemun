import std.stdio;
import std.string;

class world
{
private:
    const int[] map = [9, 4, 3, 7, 1, 1, 1, 4, 1, 1, 2, 4, 
                       11, 1, 1, 2, 1, 4, 1, 1, 3, 4, 1, 7];
    
    static File wld;
    static string path;
    static int ver;
    static char[] title;
    static int[16] idims;
    static double[4] ddims;
    static bool[14] states;
    static byte orbs;
    
public:
    this(string file)
    {
        path = file;
        wld = File(path);
    }
    
    void parseHeader()
    {
        if (!wld.isOpen())
            wld.open(path);
        
        //Buffer for raw reads
        auto buf = new byte[256];
        
        //Map version
        wld.rawRead(buf[0..4]);
        ver = *cast(int*)buf[0..4].ptr;
        
        //Map title length
        wld.rawRead(buf[0..1]);
        int l = cast(int)buf[0];
        
        //Map title (pascal-style string)
        title = new char[l];
        wld.rawRead(buf[0..l]);
        for (int i = 0; i < l; i++)
            title[i] = buf[i];
            
        //Main parsing loop
        int s = 0, n = 0, d = 0;
        for (int i = 0; i < 24; i++) {
            int c = map[i++];
            
            for (int j = 0; j < c; j++) {
                switch (map[i]) {
                    case 1: /*Bool*/
                        wld.rawRead(buf[0..1]);
                        states[s++] = *cast(bool*)buf[0..1].ptr;
                        break;
                    case 2: /*Byte*/
                        wld.rawRead(buf[0..1]);
                        orbs = buf[0];
                        break;
                    case 4: /*Int32*/
                        wld.rawRead(buf[0..4]);
                        
                        idims[n++] = *cast(int*)buf[0..4].ptr;
                        break;
                    case 7: /*Double*/
                        wld.rawRead(buf[0..8]);
                        ddims[d++] = *cast(double*)buf[0..8].ptr;
                        break;
                    default:
                        break;
                }
            }
        }
        
        wld.close();
    }
    
    void printHeader()
    {
        writeln("Version  : ", ver);
        writeln("Title    : ", title);
        writeln("ID       : ", idims[0]);
        writefln("Bounds   : (%d, %d, %d, %d)", idims[1], idims[2], idims[3], idims[4]);
        writeln("Height   : ", idims[5]);
        writeln("Width    : ", idims[6]);
        writeln("Spawn X  : ", idims[7]);
        writeln("Spawn Y  : ", idims[8]);
        writeln("Ground Y : ", ddims[0]);
        writeln("Rock Y   : ", ddims[1]);
        writeln("Time     : ", ddims[2]);
        writeln("Day      : ", states[0]);
        writeln("Moon Ph  : ", idims[9]);
        writeln("BloodMn  : ", states[1]);
        writeln("Dung X   : ", idims[10]);
        writeln("Dung Y   : ", idims[11]);
        writeln("Cthulu   : ", states[2]);
        writeln("EaterOW  : ", states[3]);
        writeln("Skeletrn : ", states[4]);
        writeln("Tinkerer : ", states[5]);
        writeln("Wizard   : ", states[6]);
        writeln("Mechanic : ", states[7]);
        writeln("Invasion : ", states[8]);
        writeln("Clown    : ", states[9]);
        writeln("FrostLgn : ", states[10]);
        writeln("BrokeOrb : ", states[11]);
        writeln("Meteor   : ", states[12]);
        writeln("OrbsBrkn : ", orbs);
        writeln("Altars   : ", idims[12]);
        writeln("HardMode : ", states[13]);
        writeln("Gob Time : ", idims[13]);
        writeln("Gob Size : ", idims[14]);
        writeln("Gob Type : ", idims[15]);
        writeln("Gob X    : ", ddims[3]);
    }
}