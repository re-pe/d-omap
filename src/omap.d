/**
 * OMap
 *
 * Ordered Map by Rėdas Peškaitis.
 *
 * It works like associative array with natural order by keys of string type. 
 *
 * Repository: https://github.com/re-pe/d-omap
 *  
 */
 
module omap;
 
import std.array;
import std.algorithm;
import std.conv;
import std.exception : enforce;
import std.range;
import std.regex;
import std.traits;
import std.typecons;
//import std.stdio;
public import natsort;

struct OMap(Tval) {
    //import std.algorithm;
    //import std.typecons;

    alias This  = typeof(this); 
    alias Tkey  = string;
    alias Tmap  = Tval[Tkey];
    alias Ttup  = Tuple!(Tkey, "key", Tval, "value");
    alias Tfil  = string[string];
    alias _map this;

    private        Tmap       _map;
    private static Tfil       _filters;

    
    private auto _keys(){
        return natSort(_map.keys);
    }
    
    private auto _keyMap(){
        uint[Tkey] keyMap;
        foreach(i, _key; _keys) keyMap[_key] = i;
        return keyMap;
    }

    private auto _values(){
        auto values = new Tval[_map.length];
        foreach(i, _key; _keys) values[i] = _map[_key];
        return values;
    }
    
    private auto _tuples(){
        auto tuples = new Ttup[_map.length];
        foreach(i, _key; _keys) tuples[i] = Ttup(_key, _map[_key]);
        return tuples;
    } 
    
    static this(){
        filters!int(`^[0-9]+$`);
        filters(`#`, `^#[0-9]+$`);
    }
    
    this(This arg) {
        _append(arg);
    } 
    this(T)(T arg) if (isArray!T || isAssociativeArray!T){
        _append(arg);
    } 

    this(T... )(T args){
        if (args.length > 1) {
            auto tupArr = _args2Tuples(args);
            if (tupArr.length > 0){
               _append(tupArr);
            }
        }
    }

    void clear() {
        _clear;
    }
    
    private void _clear() {
        _map    = null;
    }
    
    ref auto keys() {
        return _keys;
    }

    auto keys(T)(){
        return keys!(T.stringof);
    }
    
    auto keys(string name)(){
        Tkey[] keys;
        if (_keys.length > 0) foreach (i, key; _keys) {
            if (!matchFirst(key, regex(_filters[name])).empty){
                keys ~= key;
            } 
        }
        return keys;
    }
    
    auto keys(Tkey key){
        return *enforce!Exception(key in _keyMap, `Element with key "` ~ key ~ `" does not exist in keys map!`);
    }

    auto keyMap() {
        return _keyMap;
    }

    auto values() {
        return _values;
    }
    
    auto tuples() {
        return _tuples;
    }
    
    auto tuples(Tkey key) {
        auto value = *enforce!Exception(key in _map, key ~ " is out of range.");
        return Ttup(key, value);
    }

    void opAssign(T)(T arg) if(!isStaticArray!T) {
        clear();
        _append(arg);
    }

    void opAssign(T)(ref T arg) if(isStaticArray!T) {
        clear();
        _appendRef(arg);
    }
    
    auto opBinary(string op, T)(T arg) if(!isStaticArray!T){
        auto result = This(null);
        if (op == "~"){
            result = This(this);
            result._append(arg);
        }
        return result;
    }

    auto opBinary(string op, T)(ref T arg) if(isStaticArray!T){
        auto result = This(null);
        if (op == "~"){
            result = This(this);
            result._appendRef(arg);
        }
        return result;
    }

    void opOpAssign(string op, T)(T arg) if(!isStaticArray!T) {
        if(op == "~"){
            _append(arg);
        }
    }

    void opOpAssign(string op, T)(ref T arg) if(isStaticArray!T) {
        if(op == "~"){
            _appendRef(arg);
        }
    }

    auto ref opIndex(){
        return _map;
    }

    auto ref opIndex(T : Tkey)(T key){
        enforce!Exception(key in _map, "Key " ~ key ~ " out off range!!!");
        return _map[key];
    }

/+     void opIndexAssign(T)(T value) {
        this.clear();
        _append(value);
    }+/


    void opIndexAssign(V, K : Tkey)(V value, K key) {
        _replace(key, value);
    }
    
    void replace(V)(int index, V value) {
        import std.math; int _index;
        enforce!Exception( abs(index) < _map.length, "Key " ~ to!string(index) ~ " out off range!!!");
        (index < 0) ? ( _index = _map.length + index ) : _index = index;
        _replace(_keys[_index], value);
    }

    
    private void _replace(K : Tkey, V)(K key, V value) @system {
        Tkey _key;
        enforce!Exception(key in _map, "Member with key " ~ key ~ " does not exist!!!");
        static if (isAssignable!(Ttup, V)){
            _key = to!Tkey(value[0]);
            if ( _key != key){
                if (_key in _map && _keyMap[_key] != _keyMap[key]) assert(false, "New key is different from current key, but exists in _keys!");
                _map.remove(key);
            }
            _map[_key] = to!Tval(value[1]);
        } else static if(is(V : Tval[Key], Key) && is(Key: Tkey)){
            enforce!Exception(value.length == 1, "Cannot assign array witch has more than one key-value pair.");
            _replace(key, Ttup(value.keys[0], value.values[0]));
        } else static if(is(V : Tval[Key], Key) && is(Key: uint)){
            enforce!Exception(value.length == 1, "Cannot assign array witch has more than one key-value pair.");
            _replace(key, Ttup(to!Tkey(value.keys[0]), value.values[0]));
        } else static if(is(V : Tval[])){
            enforce!Exception(value.length == 1, "Cannot assign array witch has more than one value.");
            _map[key] = to!Tval(value[0]);
        } else static if(is(V : Tval)){
            _map[key] = to!Tval(value);
        } else {
            assert(false, text(`Unable to assign type "`, V.stringof, `" to member of OMap with type "`, Tval.stringof, `"`));
        }
    } 


    void opIndexOpAssign(string op, T)(T arg, int index) if(!isStaticArray!T) {
        if(op == "."){
            _append(arg);
        }
    }

    void opIndexOpAssign(string op, T)(ref T arg, int index) if(isStaticArray!T) {
        if(op == "."){
            _appendRef(arg);
        }
    }

    /+ void insert(int index, T...)(T values){
        if(index < 0) return;
        if(index >= _values.length) {
            _append(values);
        } else {
            auto head = _keys[0..index];
            auto tail = _keys[index..$];
            auto next = _next(head);
        }
    }
    void insert(Tkey name, T...)(T values){
        auto index = index(name);
        
        enforce!Exception(index > -1, `Key "` ~ name ~ `" does not exist!!!`);
        
        auto head = _keys[0..index];
        auto tail = _keys[index..$];
        auto next = _next(head);
        
        Tkey[] keys; Tkey newKey;
        foreach (value; values){
            static if(is(typeof(value) : Tuple!(Key, Val), Key, Val) && is(Val : Tval)){
                static if (is(Key : Tkey)){
                    newKey = arg[0];
                } else static if (is(Key : uint)){
                    newKey = to!Tkey(arg[0]);
                } else {
                    assert(false, text(`Unable to convert key of type "`, Key.stringof, `" to "`~ Tkey.stringof ~ `".`));
                }

                static if(is(Key : Tkey)){
                    newKey = to!Tkey(value[0]); 
                    keys ~= newKey;
                    _tuples[newKey]
                } else static if(is(Key : uint)){
                }
            }
            keys ~= tuple(name, value);
        }
    } +/
    
    private auto _next(){
        uint next, numKey;
        if (_keys.length > 0){ 
            foreach (key; _keys){ 
                if (!matchFirst(key, regex(_filters[`int`])).empty){
                    numKey = to!uint(key);
                    if (numKey >= next) next = numKey + 1; 
                }
            }
        }
        return next;
    }

    private auto _next(ref Tkey[] keys){
        uint next, numKey;
        if (keys.length > 0) foreach (key; keys) {
            if (!matchFirst(key, regex(_filters[`int`])).empty){
                numKey = to!uint(key);
                if (numKey >= next) next = numKey + 1; 
            }
        }
        return next;
    }

    void append(T...)(T args){
        if (args.length > 0){
            auto tupArr = _args2Tuples(args);
            _append(tupArr);
        }
    }
    
    private auto _args2Tuples(T...)(T args){
        Ttup[] tupArr;
        foreach (i, _arg; args) {
            static if(is(typeof(_arg) == Ttup)){
                tupArr ~= _arg;
            } else static if (is(typeof(_arg): Tuple!(Tkey, Tval))) {
                tupArr ~= Ttup(_arg[0], _arg[1]);
            } else static if (is(typeof(_arg): Tuple!(Key, Val), Key, Val) && is(Key: uint) && is(Val: Tval)) {
                tupArr ~= Ttup(to!Tkey(_arg[0]), _arg[1]);
            } else static if(is(typeof(_arg): Tval)){
                tupArr ~= Ttup("", _arg);
            } else static if(isAssociativeArray!(typeof(_arg)) && is(typeof(_arg) : Val[Key], Key, Val) && is(Val : Tval) ) {
                static if (is(Key : Tkey)) {
                    foreach(key; natSort(_arg.keys)) tupArr ~= Ttup(key, to!Tval(_arg[key]));
                } else static if(is(Key : uint)) {
                    foreach(key; sort(_arg.keys)) tupArr ~= Ttup(to!Tkey(key), to!Tval(_arg[key]));
                } else {
                    assert(false, text(`Unable to convert key of type "`, Key.stringof, `" to "`~ Tkey.stringof ~ `".`));
                }
            } else static if(isArray!(typeof(_arg)) && is(typeof(_arg) : Val[], Val)) {
                static if(is(Val : Tuple!(Key, Tval), Key)){
                    static if(is(Key: Tkey)) {
                        foreach(tup; _arg) tupArr ~= tup;
                    } else static if(is(Key: uint)){
                        foreach(tup; _arg) tupArr ~= Ttup(to!Tkey(tup[0]), tup[1]);
                    }
                } else static if(is(Val : Tval)){
                    foreach(val; _arg) tupArr ~= Ttup("", val);
                }
            }
        }
        return tupArr;
    }
    
    private void _append(T)(T arg) {
        uint next = _next; Tkey[] keys; Tkey key; Tval[] values; uint id; Tmap keyVal;  
        static if(is(T == This)){
            _append(arg._map);
        } else static if( isAssociativeArray!T && is(T : Val[Key], Key, Val) && is(Val : Tval) ) {
            static if (is(Key : Tkey)) {
                if ("" in arg) {
                    while (to!Tkey(id) in arg) id++;
                    arg[to!Tkey(id)] = arg[""];
                    arg.remove("");
                }
                keys = natSort(arg.keys);
                foreach(_key; keys) values ~= arg[_key];
                keys = _keys ~ keys;
                values = _values ~ values;
                foreach(ref _key; keys) if (!matchFirst(_key, regex(_filters[`int`])).empty) _key = to!Tkey(id++); 
                _map = assocArray(zip(keys, values)); 
            } else static if(is(Key : uint)) {
                foreach (_key; sort(arg.keys)) keyVal[to!Tkey(_key)] = arg[_key];
                _append(keyVal);
            } else assert(false, text(`Unable to convert key of type "`, Key.stringof, `" to "`~ Tkey.stringof ~ `".`));
        } else static if(isDynamicArray!T){
            static if(
                is(ElementEncodingType!T == Ttup) ||
                is(ElementEncodingType!T : Tuple!(Tkey, Tval))
            ) {
                foreach (i, tup; arg) if (tup[0] != "" && tup[0] != "#") keyVal[tup[0]] = to!Tval(tup[1]);
                foreach (i, tup; arg) if (tup[0] == "" || tup[0] == "#") {
                    while (to!Tkey(id) in keyVal) id++;
                    keyVal[to!Tkey(id)] = to!Tval(tup[1]);
                }
                _append(keyVal);
            } else static if(is(ElementEncodingType!T : Tuple!(Key, Tval), Key) && is(Key : uint)) {
                foreach (i, tup; arg) keyVal[to!Tkey(tup[0])] = to!Tval(tup[1]);
                _append(keyVal);
                
            } else static if(is(ElementEncodingType!T : Tval)){ 
                foreach(i, val; arg) keyVal[to!Tkey(i)] = to!Tval(val);
                _append(keyVal);
            }
        } else static if(
            is(T : Ttup) || 
            is(T : Tuple!(Key, Val), Key, Val) && is(Val : Tval)
        ) {
            _append([arg[0] : arg[1]]);
        } else static if(is(T : Tval)) {
            _append(["0" : arg]);
        } else static if(is(T : typeof(null))) {
        } else {
            assert(false, text(`Unable to convert type "`, T.stringof, `" to `, This.stringof));
        }
   }
    
    private void _appendRef(T)(ref T arg) if(isStaticArray!T) {
        uint next;
        Tmap keyVal; Tkey key; uint id;
        static if(
            is(ElementEncodingType!T == Ttup) ||
            is(ElementEncodingType!T : Tuple!(Tkey, Tval))
        ) {
            foreach (i, tup; arg) if (tup[0] != "" && tup[0] != "#") keyVal[tup[0]] = to!Tval(tup[1]);
            foreach(i, tup; arg) if (tup[0] == "" || tup[0] == "#") {
                while (to!Tkey(id) in keyVal) id++;
                keyVal[to!Tkey(id)] = to!Tval(tup[1]);
            }
            _append(keyVal);
            
        } else static if(is(ElementEncodingType!T : Tuple!(uint, Tval))) {
            foreach (i, tup; arg) keyVal[to!Tkey(tup[0])] = to!Tval(tup[1]);
            _append(keyVal);
            
        } else static if(is(ElementEncodingType!T : Tval)){ 
            foreach(i, val; arg) keyVal[to!Tkey(i)] = to!Tval(val);
            _append(keyVal);
        }
    }

    auto filters(){
        return this._filters;
    }
    
    auto filters(string name){
        return this._filters[name];
    }
    
    static void filters(T)( string pattern ){
        this._filters[T.stringof] = pattern;
    }

    static void filters( string name, string pattern ){
        this._filters[name] = pattern;
    }
}

unittest {
    import std.typecons;
    import std.variant;
    import std.stdio;
    alias Tkey = string;
    alias Tval = int;
    alias Tmap = Tval[Tkey];
    alias Ttup = Tuple!(Tkey, "key", int, "value");
    alias _ = Ttup;
    alias IMap = OMap!(int);
    IMap.filters(`@*`, `^@[a-z][a-z0-9]+$`);

    Tmap emptyTmap;
    Tkey[] emptyKeys;
    Tkey[] emptyIntKeys;
    int[] emptyValues;

    writeln( `auto imap = IMap(null);` );
    auto imap = IMap(null);
    assert( imap.filters == [ `int`: `^[0-9]+$`, `@*`: `^@[a-z][a-z0-9]+$`, `#`: `^#[0-9]+$`] );
    assert( imap == emptyTmap );
    assert( imap.keys == emptyKeys );
    assert( imap.keys!int == emptyIntKeys );
    assert( imap.values == emptyValues );
    writeln();
    
    writeln( `imap = IMap( 11, 12, 13 );` );
    imap = IMap( 11, 12, 13 );
    assert( imap == [ "0": 11, "1": 12, "2": 13 ] );
    assert( imap.keys == [ "0", "1", "2" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 11, 12, 13 ] );
    writeln( );

    writeln( `imap = IMap([ 21, 22, 23 ]);` );
    imap = IMap([ 21, 22, 23 ]);
    assert( imap == [ "0": 21, "1": 22, "2": 23 ] );
    assert( imap.keys == [ "0", "1", "2" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 21, 22, 23 ] );
    writeln( );

    writeln( `imap = IMap([ 0: 31, 1: 32, 100: 33 ]);` );
    imap = IMap([ 0: 31, 1: 32, 100: 33 ]);
    assert( imap == [ "0": 31, "1": 32, "2": 33 ] );
    assert( imap.keys == [ "0", "1", "2" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [  31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap([ 1: 32, 0: 31, 2: 33 ]);` );
    imap = IMap([ 1: 32, 0: 31, 2: 33 ]);
    assert( imap == [ "0": 31, "1": 32, "2": 33 ] );
    assert( imap.keys == [ "0", "1", "2" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [  31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap([ "0": 31, "1": 32, "a": 33 ]);` );
    imap = IMap([ "0": 31, "1": 32, "a": 33 ]);
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [  31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap([ "0": 31, "1": 32, "": 64, "a": 33 ]);` );
    imap = IMap([ "0": 31, "1": 32, "": 64, "a": 33 ]);
    assert( imap == [ "0": 31, "1": 32, "2": 64, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "2", "a" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [  31, 32, 64, 33 ] );
    writeln( );

    writeln( `imap = IMap([ "1": 32, "0": 31, "a": 33 ]);` );
    imap = IMap([ "1": 32, "0": 31, "a": 33 ]);
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap( _(0, 31), _("1", 32), _("a", 33) );` );
    imap = IMap( tuple(0, 31), _("1", 32), _("a", 33) );
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap( _("1", 32), tuple(0, 31), _("a", 33) );` );
    imap = IMap( _("1", 32), tuple(0, 31), _("a", 33) );
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap([ _("0", 31), _("1", 32), _("a", 33) ]);` );
    imap = IMap([ _("0", 31), _("1", 32), _("a", 33) ]);
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [  "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [  31, 32, 33 ] );
    writeln( );

    writeln( `imap = IMap( 11, _("10", 32), _("a", 33), [ 34, 35], [8 : 36, 9 : 37] );` );
    imap = IMap( 11, _("10", 32), _("a", 33), [ 34, 35], [8 : 36, 9 : 37] );
    assert( imap == [ "0": 11, "1": 34, "2": 35, "3": 36, "4": 37, "5": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "2", "3", "4", "5", "a" ] );
    assert( imap.keys!int == [ "0", "1", "2", "3", "4", "5" ] );
    assert( imap.values == [  11, 34, 35, 36, 37, 32, 33 ] );
    writeln( );
    
    writeln( `imap = null;` );
    imap = null;
    assert( imap.filters == [ `int`: `^[0-9]+$`, `#`: `^#[0-9]+$`, `@*`: `^@[a-z][a-z0-9]+$`] );
    assert( imap == emptyTmap );
    assert( imap.keys == emptyKeys );
    assert( imap.keys!int == emptyIntKeys );
    assert( imap.values == emptyValues );
    writeln( );
    
    writeln( `imap = 11;` );
    imap = 11;
    assert( imap == [ "0": 11 ] );
    assert( imap.keys == [ "0" ] );
    assert( imap.keys!int == [ "0" ] );
    assert( imap.values == [ 11 ] );
    writeln( );

    writeln( `imap = [ 21, 22, 23 ];` );
    imap = [ 21, 22, 23 ];
    assert( imap == [ "0": 21, "1": 22, "2": 23 ] );
    assert( imap.keys == [ "0", "1", "2" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 21, 22, 23 ] );                                                                                                             
    writeln( );

    writeln( `imap = [ "0": 31, "1": 32, "a": 33 ];` );
    imap = [ "0": 31, "1": 32, "a": 33 ];
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [  31, 32, 33 ] );
    writeln( );

    writeln( `imap = tuple(0, 31);` );
    imap = tuple(0, 31);
    assert( imap == [ "0": 31 ] );
    assert( imap.keys == [ "0" ] );
    assert( imap.keys!int == [ "0" ] );
    assert( imap.values == [ 31 ] );
    writeln( );

    writeln( `imap = [ _("0", 31), _("1", 32), _("a", 33) ];` );
    imap = [ _("0", 31), _("1", 32), _("a", 33) ];
    assert( imap == [ "0": 31, "1": 32, "a": 33 ] );
    assert( imap.keys == [  "0", "1", "a" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [  31, 32, 33 ] );
    writeln( );

    auto imap1 = IMap(null);
    writeln( `imap1 = [ 100 : 200 ];` );
    imap1 = [ 100 : 200 ];
    assert( imap1.filters == [ `int`: `^[0-9]+$`, `#`: `^#[0-9]+$`, `@*`: `^@[a-z][a-z0-9]+$`] );
    assert( imap1 == [ "0": 200 ] );
    assert( imap1.keys == [ "0" ] );
    assert( imap1.keys!int == [ "0" ] );
    assert( imap1.values == [ 200 ] );
    writeln( );
    
    writeln( `imap = imap1 ~ 11;` );
    imap = imap1 ~ 11;
    assert( imap == [ "0": 200, "1": 11 ] );
    assert( imap.keys == [ "0", "1" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 200, 11 ] );
    writeln( );

    writeln( `imap = imap1 ~ [ 21, 22, 23 ];` );
    imap = imap1 ~ [ 21, 22, 23 ];
    assert( imap == [ "0": 200, "1": 21, "2": 22, "3": 23 ] );
    assert( imap.keys == [ "0", "1", "2", "3" ] );
    assert( imap.keys!int == [ "0", "1", "2", "3" ] );
    assert( imap.values == [ 200, 21, 22, 23 ] );
    writeln( );

    writeln( `imap = imap1 ~ [ "0": 31, "1": 32, "a": 33 ];` );
    imap = imap1 ~ [ "0": 31, "1": 32, "a": 33 ];
    assert( imap == [ "0": 200, "1": 31, "2": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "2", "a" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 200, 31, 32, 33 ] );
    writeln( );

    writeln( `imap = imap1 ~ _(0, 31);` );
    imap = imap1 ~ tuple(0, 31);
    assert( imap == [ "0": 200, "1": 31 ] );
    assert( imap.keys == [ "0", "1" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 200, 31 ] );
    writeln( );

    writeln( `imap = imap1 ~ [ _("0", 31), _("1", 32), _("a", 33) ];` );
    imap = imap1 ~ [ _("0", 31), _("1", 32), _("a", 33) ];
    assert( imap == [ "0": 200, "1": 31, "2": 32, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "2", "a" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 200, 31, 32, 33 ] );
    writeln( );

    writeln( `imap = [ 100 : 200 ];` );
    imap = [ 100 : 200 ];
    assert( imap.filters == [ `int`: `^[0-9]+$`, `#`: `^#[0-9]+$`, `@*`: `^@[a-z][a-z0-9]+$`] );
    assert( imap == [ "0": 200 ] );
    assert( imap.keys == [ "0" ] );
    assert( imap.keys!int == [ "0" ] );
    assert( imap.values == [ 200 ] );
    writeln( );
    
    writeln( `imap ~= 11;` );
    imap ~= 11;
    assert( imap == [ "0": 200, "1": 11 ] );
    assert( imap.keys == [ "0", "1" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 200, 11 ] );
    writeln( );

    writeln( `imap ~= [ 21, 22, 23 ];` );
    imap = [ 100 : 200 ];
    imap ~= [ 21, 22, 23 ];
    assert( imap == [ "0": 200, "1": 21, "2": 22, "3": 23 ] );
    assert( imap.keys == [ "0", "1", "2", "3" ] );
    assert( imap.keys!int == [ "0", "1", "2", "3" ] );
    assert( imap.values == [ 200, 21, 22, 23 ] );
    writeln( );

    writeln( `imap ~= [ "50": 31, "1": 32, "a": 33 ];` );
    imap = [ 100 : 200 ];
    imap ~= [ "50": 31, "1": 32, "a": 33 ];
    assert( imap == [ "0": 200, "1": 32, "2": 31, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "2", "a" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 200, 32, 31, 33 ] );
    writeln( );

    writeln( `imap ~= _(0, 31);` );
    imap = [ 100 : 200 ];
    imap ~= tuple(0, 31);
    assert( imap == [ "0": 200, "1": 31 ] );
    assert( imap.keys == [ "0", "1" ] );
    assert( imap.keys!int == [ "0", "1" ] );
    assert( imap.values == [ 200, 31 ] );
    writeln( );

    writeln( `imap ~= [ _("50", 31), _("1", 32), _("a", 33) ];` );
    imap = [ 100 : 200 ];
    imap ~= [ _("50", 31), _("1", 32), _("a", 33) ];
    assert( imap == [ "0": 200, "1": 32, "2": 31, "a": 33 ] );
    assert( imap.keys == [ "0", "1", "2", "a" ] );
    assert( imap.keys!int == [ "0", "1", "2" ] );
    assert( imap.values == [ 200, 32, 31, 33 ] );
    writeln( );

/+     writeln( "imap.filters == ", imap.filters ); +/

    writeln( "imap[] == ", imap[] );
    assert(imap == [ "0": 200, "1": 32, "2": 31, "a": 33 ] );
    writeln();

    writeln( `imap["a"] = 133;` );
    assert(imap["a"] == 33 );
    imap["a"] = 133;
    assert(imap["a"] == 133);
    assert(imap == [ "0": 200, "1": 32, "2": 31, "a": 133 ] );
    assert(imap.keys == [ "0", "1", "2", "a" ] );
    assert(imap.values == [ 200, 32, 31, 133 ] );
    writeln();

    writeln( `imap["2"] = 131;` );
    assert(imap["2"] == 31);
    imap["2"] = 131;
    assert(imap["2"] == 131);
    assert(imap == [ "0": 200, "1": 32, "2": 131, "a": 133 ] );
    assert(imap.keys == [ "0", "1", "2", "a" ] );
    assert(imap.values == [ 200, 32, 131, 133 ] );
    writeln();
    
    writeln( `imap.values[2] = 132;` );
    assert(imap.values[2] == 131);
    imap.replace(2, 132);
    assert(imap.values[2] == 132);
    assert(imap == [ "0": 200, "1": 32, "2": 132, "a": 133 ] );
    assert(imap.keys == [ "0", "1", "2", "a" ] );
    assert(imap.values == [ 200, 32, 132, 133 ] );
    writeln();

    writeln( `imap.replace(2, _( "abc", 15 ) );` );
    assert(imap.keys == [ "0", "1", "2", "a" ]);
    assert(imap.values == [ 200, 32, 132, 133 ]);
    assert(imap.keys[2] == "2");
    assert(imap.values[2] == 132);
    imap.replace(2, _( "abc", 15 ) );
    assert(imap.keys == [ "0", "1", "a", "abc" ]);
    assert(imap.values == [ 200, 32, 133, 15 ]);
    assert(imap.keys[2] == "a");
    assert(imap.values[2] == 133);
    assert(imap.keys("abc") == 3);
    assert(imap.keys[3] == "abc");
    assert(imap.values[3] == 15);
    assert(imap.tuples[3] == _( "abc", 15 ));
    assert(imap.tuples("abc") == _( "abc", 15 ));
    writeln();

    writeln( `imap.replace(2, [ "ab": 20 ] );` );
    assert(imap.keys == [ "0", "1", "a", "abc" ]);
    assert(imap.values == [ 200, 32, 133, 15 ]);
    assert(imap.keys[2] == "a");
    assert(imap.values[2] == 133);
    imap.replace(2, [ "ab": 20 ]);
    assert(imap.keys == [ "0", "1", "ab", "abc" ]);
    assert(imap.values == [ 200, 32, 20, 15 ]);
    assert(imap.keys[2] == "ab");
    assert(imap.values[2] == 20);
    assert(imap.tuples[2] == _( "ab", 20 ));
    assert(imap.tuples("ab") == _( "ab", 20 ));
    writeln();

    writeln( `imap.replace(2, [ 80 ] );` );
    assert(imap.keys == [ "0", "1", "ab", "abc" ]);
    assert(imap.values == [ 200, 32, 20, 15 ]);
    assert(imap.keys[2] == "ab");
    assert(imap.values[2] == 20);
    imap.replace(2, [ 80 ]);
    assert(imap.keys == [ "0", "1", "ab", "abc" ]);
    assert(imap.values == [ 200, 32, 80, 15 ]);
    assert(imap.keys[2] == "ab");
    assert(imap.values[2] == 80);
    assert(imap.tuples[2] == _( "ab", 80 ));
    assert(imap.tuples("ab") == _( "ab", 80 ));
    writeln();
    
    imap = [ "a": 70, "b": 71 ];

    writeln( `imap.append(1, [2, 3], [ 0: 111 ], _( "ab", 21 ), [ tuple( 300, 301 ) ] );` );
    imap.append(1, [2, 3], [ 0: 111 ], _( "ab", 21 ), [ tuple( 300, 301 ) ] );
    writeln();
    
    imap = [ "100": 70, "ab": 81 ];

    writeln( `imap.append( [ "ab" : 91 ], _( "100", 71 ) );` );
    imap.append( [ "ab" : 91 ], _( "100", 71 ) );
/+    writeln( "imap[] == ", imap[] );
    writeln( "imap.filters == ", imap.filters );
    writeln( "imap.keys == ", imap.keys );
    writeln( "imap.values == ", imap.values ); 
    writeln( "imap.tuples == ", imap.tuples ); +/
    
/+     writeln( `imap.insert(1, _( "ab", 21 ), 15, _( 300, 301 ) );` );
    imap.insert(1, _( "ab", 21 ), 15, _( 300, 301 ));
    writeln( "imap[] == ", imap[] );
    writeln( "imap.keys == ", imap.keys );
    writeln( "imap.values == ", imap.values ); +/    

/+     
    imap.insert( [ _( "ab", 21 ) ], "cc" );
    assert( imap == [ "0": 32, "1": 22, "cc": 113 ] );
    assert( imap.keys == [ "0", "1", "cc" ] );
    assert( imap.values == [ 32, 22, 113 ] );
    assert( imap["cc"] == 113 );
    assert( imap(2) == 113 );
    assert( imap.keys("cc") == 2 );
    assert( imap.keys[2] == "cc" );

    imap.insert( [ _( "de", 71 ) ], 2 );
    assert( imap == [ "0": 32, "1": 22, "cc": 113, "de": 71 ] );
    assert( imap.keys == [ "0", "1", "de", "cc" ] );
    assert( imap.values == [ 32, 22, 71, 113 ] );
    assert( imap["de"] == 71 );
    assert( imap(2) == 71 );
    assert( imap.keys("de") == 2 );
    assert( imap.keys[2] == "de" );

    imap.move("cc", "1" );
    assert( imap == [ "0": 32, "1": 22, "cc": 113, "de": 71 ] );
    assert( imap.keys == [ "0", "cc", "1", "de" ] );
    assert( imap.values == [ 32, 113, 22, 71 ] );
    assert( imap["cc"] == 113 );
    assert( imap.keys("cc") == 1 );
    assert( imap.keys[1] == "cc" );
    assert( imap.values[1] == 113 );
    assert( imap["cc"] == 113 );

    imap.move("de", 2 );
    assert( imap == [ "0": 32, "1": 22, "cc": 113, "de": 71 ] );
    assert( imap.keys == [ "0", "cc", "de", "1" ] );
    assert( imap.values == [ 32, 113, 71, 22 ] );
    assert( imap["de"] == 71 );
    assert( imap.keys("de") == 2 );
    assert( imap.keys[2] == "de" );
    assert( imap.values[2] == 71 );
    assert( imap["de"] == 71 );

    imap.remove("de");
    assert( imap == [ "0": 32, "1": 22, "cc": 113 ] );
    assert( imap.keys == [ "0", "cc", "1" ] );
    assert( imap.values == [ 32, 113, 22 ] );
    //assert( imap["de"] == error! );
    //assert( imap.keys("de") == error! );
    assert( imap.keys[2] == "1" );
    assert( imap.values[2] == 22 );
    //assert( imap["de"] == error! );

    imap.removekeys(2);
    assert( imap == [ "0": 32, "cc": 113 ] );
    assert( imap.keys == [ "0", "cc" ] );
    assert( imap.values == [ 32, 113 ] );
    //assert( imap["1"] => error! );
    //assert( imap.keys("1") == error! );
    //assert( imap.keys[2] == error! );
    //assert( imap.values[2] == error! );
    //assert( imap["1"] => error! ); +/

}

