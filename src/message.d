enum MessageType : byte
{
    CONNECT = 0x01,
    FATAL = 0x02,
    APPROVED = 0x03,
    APPEARANCE = 0x04,
    INVENTORY = 0x05,
    RWORLDINFO = 0x06,
    WORLDINFO = 0x07,
    RTILEDATA = 0x08,
    TILEDATA = 0x0A,
    RECALCUV = 0x0B,
    SPAWN = 0x0C,
    CONTROL = 0x0D,
    ACTIVITY = 0x0E,
    LIFE = 0x10,
    MODTILE = 0x11,
    SETTIME = 0x12,
    UPDATEITEM = 0x15,
    ITEMOWNER = 0x16,
    CHAT = 0x19,
    DAMAGE = 0x1A,
    PROJECTILE = 0x1B,
    DPROJECTILE = 0x1D,
    TOGGLEPVP = 0x1E,
    HEAL = 0x23,
    RPASSWORD = 0x25,
    PASSWORD = 0x26,
    MANA = 0x2A,
    REPLENISH = 0x2B,
    KILL = 0x2C,
    RSPAWN = 0x31,
    BUFFS = 0x32,
    NPCNAME = 0x38,
    BALANCESTATS = 0x39,
    HARP = 0x3A
}

class Messenger
{
public:
    ubyte[] CONNECT,
            PASSWORD,
            RWORLDINFO,
            RTILEDATA,
            APPEARANCE,
            LIFE,
            MANA,
            BUFFS,
            INVENTORY,
            SPAWN;

    this()
    {
        // $01 - Connection request
        CONNECT = cast(ubyte[]) [
            0x0B, 0x00, 0x00, 0x00,
            MessageType.CONNECT
        ] ~ cast(ubyte[]) "Terraria39";
        
        // $26 - Send password
        PASSWORD = [
            0x01, 0x00, 0x00, 0x00,
            MessageType.PASSWORD
        ];
        
        // $06 - Request world information
        RWORLDINFO = [
            0x01, 0x00, 0x00, 0x00,
            MessageType.RWORLDINFO
        ];
        
        // $08 - Request initial tile data
        RTILEDATA = [
            0x09, 0x00, 0x00, 0x00,
            MessageType.RTILEDATA
        ];
    }
    
    void init(ubyte slot)
    {
        // $04 - Player appearance
        APPEARANCE = cast(ubyte[]) [
            0x1B, 0x00, 0x00, 0x00,
            MessageType.APPEARANCE,
            slot,              /*Player slot*/
            0x05,              /*Hair style*/
            0x00,              /*Gender*/
            0xFF, 0x00, 0xFF,  /*Hair color*/
            0xFF, 0x7D, 0x5A,  /*Skin color*/
            0x69, 0x5A, 0x4B,  /*Eye color*/
            0x96, 0x96, 0xFF,  /*Shirt color*/
            0x96, 0x96, 0xFF,  /*Undershirt color*/
            0x96, 0x96, 0xFF,  /*Pants color*/
            0xFF, 0x00, 0xFF,  /*Shoes color*/
            0x02               /*Difficulty*/
            ] ~ (cast(ubyte[])(['v']));
        
        // $10 - Set player life
        LIFE = [
            0x06, 0x00, 0x00, 0x00,
            MessageType.LIFE,
            slot,       /*Player slot*/
            0x64, 0x00, /*Current health*/
            0x64, 0x00  /*Max health*/
        ];
        
        // $2A - Set player mana
        MANA = [
            0x06, 0x00, 0x00, 0x00,
            MessageType.MANA,
            slot,       /*Player slot*/
            0x00, 0x00, /*Current mana*/
            0x00, 0x00  /*Max mana*/
        ];
        
        // $32 - Set player buffs
        BUFFS = [
            0x0C, 0x00, 0x00, 0x00,
            MessageType.BUFFS,
            slot,                         /*Player slot*/
            0x00, 0x00, 0x00, 0x00, 0x00, /*Player buffs*/
            0x00, 0x00, 0x00, 0x00, 0x00
        ];
        
        // $05 - Set player inventory item
        INVENTORY = [
            0x07, 0x00, 0x00, 0x00,
            MessageType.INVENTORY,
            slot,      /*Player slot*/
            0x00,      /*Inventory slot*/
            0x00,      /*Item stack*/
            0x00,      /*Item prefix ID*/
            0x00, 0x00 /*Item ID*/
        ];
        
        SPAWN = [
            0x0A, 0x00, 0x00, 0x00,
            MessageType.SPAWN,
            slot /*Player slot*/
        ];
    }
}