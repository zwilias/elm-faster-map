port module Main exposing (main)

import Fast.List1 as FL1
import Fast.List2 as FL2
import Fast.List3 as FL3
import Fast.List4 as FL4
import Fast.List5 as FL5
import Fast.List6 as FL6
import Fast.List7 as FL7
import Fast.List8 as FL8
import Json.Encode exposing (Value)
import Series.LowLevel exposing (benchmark2)
import Series.Runner as Runner
import Series.Runner.Node as Runner exposing (SeriesProgram)


main : SeriesProgram Int
main =
    Runner.series
        "map all the things"
        doCompare
        (List.map (\exp -> 2 ^ exp) (List.range 0 20))
        |> Runner.program emit Json.Encode.int


doCompare : Int -> Runner.Comparison
doCompare size =
    let
        input =
            List.range 0 size
    in
    Runner.compare
        [ benchmark2 "1 deep" FL1.map identity input
        , benchmark2 "2 deep" FL2.map identity input
        , benchmark2 "3 deep" FL3.map identity input
        , benchmark2 "4 deep" FL4.map identity input
        , benchmark2 "5 deep" FL5.map identity input
        , benchmark2 "6 deep" FL6.map identity input
        , benchmark2 "7 deep" FL7.map identity input
        , benchmark2 "8 deep" FL8.map identity input
        ]


port emit : Value -> Cmd msg
