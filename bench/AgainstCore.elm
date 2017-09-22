module AgainstCore exposing (main)

import Benchmark as B exposing (Benchmark, benchmark2)
import Benchmark.Runner as B exposing (BenchmarkProgram)
import FastMap as FM


main : BenchmarkProgram
main =
    [ 0, 2, 32, 64, 128, 256, 512, 1024, 2048 ]
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
        (benchmark2 "core" List.map identity input)
        (benchmark2 "new" FM.map identity input)
