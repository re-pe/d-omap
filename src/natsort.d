module natsort;

enum int width = 101;
enum int precision = 50;

bool natOrder(string a, string b){
    //import std.stdio;
    //writeln("(a; b) => (", a, "; ", b, ")");
    import std.regex;
    auto convert(Captures!(string) matches){
        //writeln("matches => ", matches);
        import std.format;
        import std.conv;
        auto formatStr = format("%%%d.%df", width, precision); 
        return format(formatStr, to!double(matches[1]));
    }
    auto pattern = regex("([0-9]+(?:[.][0-9]+)?)");
    auto first = replaceAll!(convert)(a, pattern);
    auto second = replaceAll!(convert)(b, pattern);
    //writeln(`"`, first, `" < "`, second, `" == `, first < second);
    return first < second;
}

auto natSort(string[] arr){
    import std.algorithm;
    sort!natOrder(arr);
    return arr; 
}

unittest {
    import std.stdio;
    import std.algorithm;

    //a < a0 < a1 < a1a < a1b < a2 < a10 < a20
    //writeln("must be => a < a0 < a1 < a1a < a1b < a2 < a10 < a20");
    auto arr = [
        "a20",
        "a10",
        "a2",
        "a1b",
        "a1a",
        "a1",
        "a0",
        "a"
    ];
    
    //writeln("arr => ", arr);
    //writeln("sort!natOrder(arr) => ", sort!natOrder(arr));
    //writeln();

    sort!natOrder(arr);
    assert(arr == ["a", "a0", "a1", "a1a", "a1b", "a2", "a10", "a20"]);
    
    //x2-g8 < x2-y7 < x2-y08 < x8-y8
    //writeln("must be => x2-g8 < x2-y7 < x2-y08 < x8-y8");
   
    arr = [
        "x8-y8",
        "x2-y08",
        "x2-y7",
        "x2-g8"
    ];
    
    //writeln("arr => ", arr);
    //writeln("sort!natOrder(arr) => ", sort!natOrder(arr));
    //writeln();

    sort!natOrder(arr);
    assert(arr == ["x2-g8", "x2-y7", "x2-y08", "x8-y8"]);

    //1.001 < 1.002 < 1.010 < 1.02 < 1.1 < 1.3
    //writeln("must be => 1.001 < 1.002 < 1.010 < 1.02 < 1.1 < 1.3");
   
    arr = [
        "1.3",
        "1.1",
        "1.02",
        "1.010",
        "1.002",
        "1.001"
    ];
    
    //writeln("arr => ", arr);
    //writeln("sort!natOrder(arr) => ", sort!natOrder(arr));
    //writeln();
    
    sort!natOrder(arr);
    assert(arr == ["1.001", "1.002", "1.010", "1.02", "1.1", "1.3"]);
    
    //a.1 < a.001 < a.02 < a.002 < a.3 < a.010
    //writeln("must be => a.1 < a.001 < a.02 < a.002 < a.3 < a.010");
   
    arr = [
        "a.010",
        "a.3",
        "a.02",
        "a.002",
        "a.1",
        "a.001"
    ];
    
    //writeln("arr => ", arr);
    //writeln("sort!natOrder(arr) => ", sort!natOrder(arr));
    //writeln();
    
    sort!natOrder(arr);
    assert(arr == ["a.1", "a.001", "a.02", "a.002", "a.3", "a.010"]);

    //img1.png < img2.png < img10.png < img12.png 
    //writeln("must be => img1.png < img2.png < img10.png < img12.png");
   
    arr = [
        "img12.png", 
        "img10.png", 
        "img2.png", 
        "img1.png"
    ];
    
    //writeln("arr => ", arr);
    //writeln("sort!natOrder(arr) => ", sort!natOrder(arr));
    //writeln();
    
    sort!natOrder(arr);
    assert(arr == ["img1.png", "img2.png", "img10.png", "img12.png"]);
    
    arr = [
        "img12.png", 
        "img10.png", 
        "img2.png", 
        "img1.png"
    ];

    auto arr1 = natSort(arr);
    assert(arr1 == ["img1.png", "img2.png", "img10.png", "img12.png"]);
    
}

