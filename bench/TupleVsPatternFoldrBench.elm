port module Main exposing (main)

import Fast.List5 as FL5
import Json.Encode exposing (Value)
import Series.LowLevel exposing (benchmark3)
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
        [ benchmark3 "tails" FL5.foldr (::) [] input
        , benchmark3 "tuples" foldr (::) [] input
        ]


port emit : Value -> Cmd msg


foldr : (a -> b -> b) -> b -> List a -> b
foldr op acc list =
    chunkAndFoldr op acc list []


chunkAndFoldr : (a -> b -> b) -> b -> List a -> List ( a, a, a, a, a ) -> b
chunkAndFoldr op acc list chunks =
    case list of
        a :: b :: c :: d :: e :: [] ->
            foldChunks op chunks (op a (op b (op c (op d (op e acc)))))

        a :: b :: c :: d :: [] ->
            foldChunks op chunks (op a (op b (op c (op d acc))))

        a :: b :: c :: [] ->
            foldChunks op chunks (op a (op b (op c acc)))

        a :: b :: [] ->
            foldChunks op chunks (op a (op b acc))

        a :: [] ->
            foldChunks op chunks (op a acc)

        [] ->
            foldChunks op chunks acc

        a :: b :: c :: d :: e :: xs ->
            chunkAndFoldr op acc xs (( a, b, c, d, e ) :: chunks)


foldChunks : (a -> b -> b) -> List ( a, a, a, a, a ) -> b -> b
foldChunks op chunks acc =
    case chunks of
        ( a, b, c, d, e ) :: xs ->
            foldChunks op xs (op a (op b (op c (op d (op e acc)))))

        _ ->
            acc
