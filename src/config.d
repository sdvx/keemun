import std.stdio;
import std.string;

class Node
{
public:

    string key;
    string value;

    this(string k, string v)
    {
        key = k;
        value = v;
    }
}

class Config
{
private:

    static File f;
    static Node[] keys;

public:

    static void load()
    {
        f = File("config.txt");

        if (f is null || !f.isOpen())
            return;
            
        string ln;
        while ((ln = f.readln()) > 0) {
            int i;
            if (ln.indexOf("#") != 0 && (i = ln.indexOf(":")) > -1) {
                Node n = new Node(ln[0..i], ln[(i + 1)..$]);
                keys ~= [n];
            }
        }

        f.close();                
    }


    static Node get(string s)
    {
        for (int i = 0; i < keys.length; i++) {
            if (keys[i].key == s)
                return keys[i];

        return null;
    }
}
