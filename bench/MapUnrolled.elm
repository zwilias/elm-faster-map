port module Main exposing (main)

import Fast.List5 as FL5
import Fast.Unrolled5 as Unrolled5
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
        [ benchmark2 "5 flat" FL5.map identity input
        , benchmark2 "5 unrolled" Unrolled5.map identity input
        ]


port emit : Value -> Cmd msg
