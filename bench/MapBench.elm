port module Main exposing (main)

import Benchmark.LowLevel as B exposing (benchmark2)
import Benchmark.Runner.Node as Runner exposing (BenchmarkProgram)
import Fast.List as FastList
import Json.Encode exposing (Value)


main : BenchmarkProgram
main =
    Runner.series
        "Trying to find a faster map"
        (\s -> toString s)
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
        [ benchmark2 "core" List.map identity input
        , benchmark2 "next" fmap identity input
        , benchmark2 "experiment" FastList.map identity input
        ]


port emit : Value -> Cmd msg


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
