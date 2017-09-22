module AgainstSelf exposing (main)

import Benchmark as B exposing (Benchmark, benchmark2)
import Benchmark.Runner as B exposing (BenchmarkProgram)
import FastMap as FM


main : BenchmarkProgram
main =
    [ 0, 1, 10, 100, 10000, 100000 ]
        |> List.map doCompare
        |> B.describe "maps"
        |> B.program


doCompare : Int -> Benchmark
doCompare size =
    let
        input =
            List.range 0 size
    in
    B.compare ("size: " ++ toString size)
        (benchmark2 "current (5)" FM.map identity input)
        (benchmark2 "exp (4)" fmap identity input)


fmap : (a -> b) -> List a -> List b
fmap op list =
    ffmapHelper op list []


ffmapHelper : (a -> b) -> List a -> List (List a) -> List b
ffmapHelper op list chunks =
    case list of
        a :: b :: c :: d :: [] ->
            mapChunks op chunks [ op a, op b, op c, op d ]

        a :: b :: c :: [] ->
            mapChunks op chunks [ op a, op b, op c ]

        a :: b :: [] ->
            mapChunks op chunks [ op a, op b ]

        a :: [] ->
            mapChunks op chunks [ op a ]

        [] ->
            mapChunks op chunks []

        _ :: _ :: _ :: _ :: xs ->
            ffmapHelper op xs (list :: chunks)


mapChunks : (a -> b) -> List (List a) -> List b -> List b
mapChunks op chunks acc =
    case chunks of
        [ a, b, c, d ] :: xs ->
            mapChunks op xs (op a :: op b :: op c :: op d :: acc)

        _ ->
            acc
