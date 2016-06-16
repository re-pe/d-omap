unittest {

    import std.stdio;
    import std.regex;
    import std.format;
    import std.algorithm;
    import std.conv;
    import std.typecons;
    import std.variant;
    import std.array;
    import std.range;

    alias Tkey = Algebraic!(string, int);
    alias Tval = int;
    alias Ttup = Tuple!(Tkey, "key", Tval, "value");
    alias _ = Ttup;
    
    auto arr = [
        _( Tkey("a"  ), 0), 
        _( Tkey(""   ), 1), 
        _( Tkey(100  ), 2), 
        _( Tkey(""   ), 3), 
        _( Tkey(0    ), 4), 
        _( Tkey("#2.0" ), 5), 
        _( Tkey("#2.09" ), 6), 
        _( Tkey("b"  ), 7), 
        _( Tkey("#0.11"), 8),
        _( Tkey(10   ), 9)
    ];
    
    int id; Tval[Tkey] keyVal;
    Tkey key; Tkey[] keys; Tval[] values;

//    foreach (i, el; arr) writeln();
    //writeln("arr => ", arr);
    foreach (i, _val; arr) if (_val.key != ""){
        keyVal[_val.key] = _val.value;
        writeln("_key => ", _val.key, ", _val => ", _val.value);
    }

    writeln("keyVal => ", keyVal);
        
    foreach(i, _val; arr) if (_val.key == "") {
        do {
            key = id++;
        } while (key in keyVal);
        keyVal[key] = _val.value;
        writeln("_key => ", key, "_val => ", _val.value);
    }
    
    writeln("keyVal => ", keyVal);
    
    bool natOrder(Tkey a, Tkey b){
        string convert(Captures!(string) matches){
            return format("%21.10s", matches[1]);
        }
        //auto pattern = regex("#?([0-9]+)");
        auto pattern = regex("([0-9]+)");
        auto first = replaceAll!(convert)(to!string(a), pattern);
        auto second = replaceAll!(convert)(to!string(b), pattern);
        writeln("first => ", first, ", second => ", second);
        return first < second;
    }
    
    auto natSort(Tkey[] keys){
        sort!natOrder(keys);
        return keys;
    }
    
    keys = natSort(keyVal.keys);
    foreach (_key; keys) values ~= keyVal[_key];
    auto typeOfInt = typeid(int); int i;
    foreach (ref _key; keys) if (_key.type == typeOfInt) _key = i++;
    
    keyVal = assocArray(zip(keys, values));
    
    
    foreach (j, _key; keys) writeln(j, ".", _key, " => ", keyVal[_key]);

    writeln();
    writeln("arr => ", arr);
    writeln("keyVal => ", keyVal);
    writeln("keys => ", keys);
    writeln("values => ", values);
}
