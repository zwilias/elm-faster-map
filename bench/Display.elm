port module Display exposing (main)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode


main : Program Decode.Value () msg
main =
    Platform.programWithFlags
        { init = init
        , update = \_ _ -> () ! []
        , subscriptions = always Sub.none
        }


init : Decode.Value -> ( (), Cmd msg )
init flags =
    case Decode.decodeValue decodeBenches flags of
        Err error ->
            error
                |> Json.Encode.string
                |> emit
                |> (,) ()

        Ok benches ->
            let
                benchesByInputSize : List ( Int, List Bench )
                benchesByInputSize =
                    Dict.toList benches

                benchLines : List String
                benchLines =
                    benchesByInputSize
                        |> List.map
                            (\( inputSize, benches ) ->
                                benches
                                    |> List.map
                                        (\{ samples, sampleSize } ->
                                            toFloat ((List.length samples * sampleSize) * inputSize)
                                                / toFloat (List.sum samples)
                                                |> toString
                                        )
                                    |> String.join "\t"
                                    |> (++) "\t"
                                    |> (++) (toString inputSize)
                            )

                allLines =
                    case benchesByInputSize of
                        [] ->
                            benchLines

                        ( _, benches ) :: _ ->
                            benches
                                |> List.map .kind
                                |> String.join "\t"
                                |> (++) "#\t"
                                |> flip (::) benchLines
            in
            allLines
                |> String.join "\n"
                |> Json.Encode.string
                |> emit
                |> (,) ()


port emit : Json.Encode.Value -> Cmd msg


decodeBenches : Decoder (Dict Int (List Bench))
decodeBenches =
    Decode.field "variations" (Decode.list benchEntryDecoder |> Decode.map Dict.fromList)


type alias Bench =
    { kind : String
    , inputSize : Int
    , sampleSize : Int
    , samples : List Int
    }


benchEntryDecoder : Decoder ( Int, List Bench )
benchEntryDecoder =
    Decode.field "variation" Decode.int
        |> Decode.andThen
            (\inputSize ->
                Decode.map2 (::)
                    (Decode.field "baseline" (benchDecoder inputSize))
                    (Decode.field "cases" <| Decode.list (benchDecoder inputSize))
                    |> Decode.map ((,) inputSize)
            )


benchDecoder : Int -> Decoder Bench
benchDecoder inputSize =
    Decode.map4 Bench
        (Decode.field "name" Decode.string)
        (Decode.succeed inputSize)
        (Decode.field "sampleSize" Decode.int)
        (Decode.field "samples" (Decode.list Decode.int))
