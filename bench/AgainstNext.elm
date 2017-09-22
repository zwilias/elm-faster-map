module Main exposing (main)

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
        (benchmark2 "0.19 foldr" fmap identity input)
        (benchmark2 "new" FM.map identity input)


fmap : (a -> b) -> List a -> List b
fmap f list =
    let
        foldFunc x acc =
            f x :: acc
    in
    ffoldr foldFunc [] list


ffoldr : (a -> b -> b) -> b -> List a -> b
ffoldr fn acc ls =
    ffoldrHelper fn acc 0 ls


ffoldrHelper : (a -> b -> b) -> b -> Int -> List a -> b
ffoldrHelper fn acc ctr ls =
    case ls of
        [] ->
            acc

        a :: r1 ->
            case r1 of
                [] ->
                    fn a acc

                b :: r2 ->
                    case r2 of
                        [] ->
                            fn a (fn b acc)

                        c :: r3 ->
                            case r3 of
                                [] ->
                                    fn a (fn b (fn c acc))

                                d :: r4 ->
                                    let
                                        res =
                                            if ctr > 500 then
                                                List.foldl fn acc <| List.reverse r4
                                            else
                                                ffoldrHelper fn acc (ctr + 1) r4
                                    in
                                    fn a (fn b (fn c (fn d res)))
