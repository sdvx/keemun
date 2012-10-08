class Event
{
public:

    EventType type;
    char[] data;
    Event next;
    
    this (EventType t, char[] d = [])
    {
        type = t;
        data = d;
        next = null;
    }
}

enum EventType
{
    CMD,
    SAY,
    SAVE,
    EXIT
}

shared class EventQueue
{
public:
    int size;
    Event first;
    Event last;
    
    this()
    {
        size = 0;
        first = null;
        last = null;
    }
    
    void add(EventType t, immutable char[] d = "")
    {
        shared Event e = cast(shared Event) new Event(t, cast(char[]) d);
        
        if (size == 0)
            first = e;
            
        if (last !is null)
            last.next = e;
            
        last = e;
        size++;
    }
    
    Event pop()
    {
        if (size == 0)
            return null;
            
        shared Event temp = first;
        first = first.next;
        size--;
        
        return cast(Event) temp;
    }
}