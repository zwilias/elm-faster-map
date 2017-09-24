port module Main exposing (main)

import Benchmark.LowLevel as B exposing (benchmark3)
import Benchmark.Runner.Node as Runner exposing (BenchmarkProgram)
import Fast.List1 as FL1
import Fast.List2 as FL2
import Fast.List3 as FL3
import Fast.List4 as FL4
import Fast.List5 as FL5
import Fast.List6 as FL6
import Fast.List7 as FL7
import Fast.List8 as FL8
import Json.Encode exposing (Value)


main : BenchmarkProgram
main =
    Runner.series
        "foldr all the things"
        toString
        doCompare
        (List.map (\exp -> 2 ^ exp) (List.range 0 20))
        |> Runner.run emit


doCompare : Int -> Runner.Benchmark
doCompare size =
    let
        input =
            List.range 0 size
    in
    Runner.compare
        [ benchmark3 "1 deep" FL1.foldr (::) [] input
        , benchmark3 "2 deep" FL2.foldr (::) [] input
        , benchmark3 "3 deep" FL3.foldr (::) [] input
        , benchmark3 "4 deep" FL4.foldr (::) [] input
        , benchmark3 "5 deep" FL5.foldr (::) [] input
        , benchmark3 "6 deep" FL6.foldr (::) [] input
        , benchmark3 "7 deep" FL7.foldr (::) [] input
        , benchmark3 "8 deep" FL8.foldr (::) [] input
        ]


port emit : Value -> Cmd msg
