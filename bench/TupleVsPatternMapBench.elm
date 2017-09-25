port module Main exposing (main)

import Fast.List5 as FL5
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
        [ benchmark2 "tails" FL5.map identity input
        , benchmark2 "tuples" map identity input
        ]


port emit : Value -> Cmd msg


map : (a -> b) -> List a -> List b
map op list =
    chunkAndMap op list []


chunkAndMap : (a -> b) -> List a -> List ( a, a, a, a, a ) -> List b
chunkAndMap op list chunks =
    case list of
        a :: b :: c :: d :: e :: [] ->
            mapChunks op chunks [ op a, op b, op c, op d, op e ]

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

        a :: b :: c :: d :: e :: xs ->
            chunkAndMap op xs (( a, b, c, d, e ) :: chunks)


mapChunks : (a -> b) -> List ( a, a, a, a, a ) -> List b -> List b
mapChunks op chunks acc =
    case chunks of
        ( a, b, c, d, e ) :: xs ->
            mapChunks op xs (op a :: op b :: op c :: op d :: op e :: acc)

        _ ->
            acc
