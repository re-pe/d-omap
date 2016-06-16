

```D 
import std.variant;
alias SI = Algebraic!(int, string);
alias SIOMap = OMap!(SI, int);
alias SITuple = Tuple!(SI, "key", int, "value");
alias _ = SITuple;

int[string] emptyArr;
SI[] emptyKeys

SIOMap omap;
    // omap == emptyArr;
    // omap.keys == emptyKeys;

omap = SIOMap( 11, 12 );
    // omap == [ "0": 11, "1": 12 ];
    // omap.keys == [ "0", "1" ];
    // omap.values == [ 11, 12 ];


omap = SIOMap( 
             _( "ab", 41 ),    
             _( "bc", 42 )     
         );
    // omap == [ "ab": 41, "bc": 42 ];  
    // omap.keys == [ "ab", "bc" ];
    // omap.values == [ 41, 42 ];

omap = SIOMap(
             11, 
             _( "ab", 44 )
         );                   
    // omap == [ "0": 11, "ab": 44 ];
    // omap.keys == [ "0", "ab" ];
    // omap.values == [ 11, 44 ];

omap = [];
    // omap == emptyArr;
    // omap.keys == emptyKeys;
    // omap.values == emptyValues;

omap = [ 21 ];
    // omap == [ "0": 21 ];
    // omap.keys ==  [ "0" ];
    // omap.values == [ 21 ];

int[1] arr = 21;             
omap = arr;
    // omap == [ "0": 21 ];
    // omap.keys ==  [ "0" ];
    // omap.values == [ 21 ];

omap = [ "a" : 31 ];
    // omap == [ "a": 31 ];
    // omap.keys == [ "a" ];
    // omap.values == [ 31 ];

omap = [ _( "bc", 51 ) ];
    // omap == [ "bc": 51 ];
    // omap.keys == [ "bc" ];
    // omap.values == [ 51 ];

omap1 = omap;
    // omap1 == [ "bc": 51 ];
    // omap1.keys == [ "bc" ];
    // omap1.values == [ 51 ];

omap1 = omap ~ [ 15 ];
    // omap1 == [ "bc": 51, "1": 15 ];
    // omap1.keys == [ "bc", "1" ];
    // omap1.values == [ 51, 15 ];

omap1 = omap ~ [ "de" : 27 ];
    // omap1 == [ "bc": 51, "de": 27 ];
    // omap1.keys == [ "bc", "de" ];
    // omap1.values == [ 51, 27 ];

omap1 = omap ~ [ _( "ef", 41 ) ];
    // omap1 == [ "bc": 51, "ef": 41 ];
    // omap1.keys == [ "bc", "ef" ];
    // omap1.values == [ 51, 41 ];

omap1 = omap ~ SIOMap( _( "ab", 52 ) );
    // omap1 == [ "bc": 51, "ab": 52 ];
    // omap1.keys == [ "bc", "ab" ];
    // omap1.values == [ 51, 52 ];

omap1 ~= [ 61 ]; 
    // omap1 == [ "bc": 51, "ab": 52, "0": 61 ];
    // sukArr1.keys == [ "bc", "ab", "0" ];
    // omap1.values == [ 51, 52, 61 ];

omap1 ~= [ "ac": 61 ]; 
    // omap1 == [ "bc": 51, "ab": 52, "ac": 61 ];
    // sukArr1.keys == [ "bc", "ab", "ac" ];
    // omap1.values == [ 51, 52, 61 ];

omap1 ~= [ _( "ac", 61 ) ]; 
    // omap1 == [ "bc": 51, "ab": 52, "ac": 61 ];
    // sukArr1.keys == [ "bc", "ab", "ac" ];
    // omap1.values == [ 51, 52, 61 ];

omap = SIOMap(
               12, 
               22, 
               tuple( 0, 32 ),
               _( "bc", 42 )
           );                 
    // omap == [ "0": 32, "1": 22, "bc": 42 ];
    // omap.keys == [ "0", "1", "bc" ];
    // omap1.values == [ 32, 22, 42 ];
                              
omap["bc"] = 111;
    // omap == [ "0": 32, "1": 22, "bc": 111 ];
    // omap.keys == [ "0", "1", "bc" ];
    // omap1.values == [ 32, 22, 111 ];
    // omap["bc"] == 111;
    // omap.keys("bc") == 2;
    // omap.keys[2] == "bc";
    // omap.values[2] == 111;

omap["bc"] = _( "cd", 112 );
    // omap == [ "0": 32, "1": 22, "cd": 112 ];
    // omap.keys == [ "0", "1", "cd" ];
    // omap1.values == [ 32, 22, 112 ];
    // omap["cd"] == 112;
    // omap.keys("cd") == 2;
    // omap.keys[2] == "cd";
    // omap.values[2] == 112;

omap.replace( [ _( "cc", 113 ) ], 2 );
    // omap == [ "0": 32, "1": 22, "cc": 113 ];
    // omap.keys == [ "0", "1", "cc" ];
    // omap1.values == [ 32, 22, 113 ];
    // omap["cc"] == 113;
    // omap.keys("cc") == 2;
    // omap.keys[2] == "cc";
    // omap.values[2] == 113;

omap.insert( [ _( "ab", 21 ) ], "cc" );
    // omap == [ "0": 32, "1": 22, "cc": 113 ];
    // omap.keys == [ "0", "1", "cc" ];
    // omap.values == [ 32, 22, 113 ];
    // omap["cc"] == 113;
    // omap.keys("cc") == 2;
    // omap.keys[2] == "cc";
    // omap.values[2] == 113;

omap.insert( [ _( "de", 71 ) ], 2 );
    // omap == [ "0": 32, "1": 22, "cc": 113, "de": 71 ];
    // omap.keys == [ "0", "1", "de", "cc" ];
    // omap.values == [ 32, 22, 71, 113 ];
    // omap["de"] == 71;
    // omap.keys("de") == 2;
    // omap.keys[2] == "de";
    // omap.values[2] == 71;

omap.move("cc", "1" ) );
    // omap == [ "0": 32, "1": 22, "cc": 113, "de": 71 ];
    // omap.keys == [ "0", "cc", "1", "de" ];
    // omap.values == [ 32, 113, 22, 71 ];
    // omap["cc"] == 113;
    // omap.keys("cc") == 1;
    // omap.keys[1] == "cc";
    // omap.values[1] == 113;

omap.move("de", 2 ) );
    // omap == [ "0": 32, "1": 22, "cc": 113, "de": 71 ];
    // omap.keys == [ "0", "cc", "de", "1" ];
    // omap.values == [ 32, 113, 71, 22 ];
    // omap["de"] == 71;
    // omap.keys("de") == 2;
    // omap.keys[2] == "de";
    // omap.values[2] == 71;

omap.remove("de");
    // omap == [ "0": 32, "1": 22, "cc": 113 ];
    // omap.keys == [ "0", "cc", "1" ];
    // omap.values == [ 32, 113, 22 ];
    // omap["de"] => error!;
    // omap.keys("de") == error!;
    // omap.keys[2] == "1";
    // omap.values[2] == 22;

omap.removekeys(2);
    // omap == [ "0": 32, "cc": 113 ];
    // omap.keys == [ "0", "cc" ];
    // omap.values == [ 32, 113 ];
    // omap["1"] => error!;
    // omap.keys("1") == error!;
    // omap.keys[2] == error!;
    // omap.values[2] == error!;

}
```