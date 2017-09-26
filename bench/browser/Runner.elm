port module Runner exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Http
import Json.Decode
import Json.Encode
import Task


port loadFile : () -> Cmd msg


port receive : (Json.Encode.Value -> msg) -> Sub msg


type alias Model =
    { options : List String
    , running : Maybe String
    , messages : List SubMsg
    }


type Msg
    = Loaded (List String)
    | Load String
    | SubMsg SubMsg


type SubMsg
    = Started String
    | Running String
    | Done Json.Encode.Value
    | Unknown Json.Encode.Value


loadOptions : Cmd Msg
loadOptions =
    Http.getString "benches/all.txt"
        |> Http.toTask
        |> Task.map (String.lines >> List.filter (not << String.isEmpty))
        |> Task.onError (\_ -> Task.succeed [])
        |> Task.perform Loaded


init : ( Model, Cmd Msg )
init =
    ( { options = [], running = Nothing, messages = [] }, loadOptions )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded options ->
            { model | options = options } ! []

        Load option ->
            { model | running = Just option } ! [ loadFile () ]

        SubMsg subMsg ->
            { model | messages = subMsg :: model.messages } ! []


view : Model -> Html Msg
view model =
    case model.running of
        Nothing ->
            renderPicker model.options

        Just choice ->
            Html.div [] [ renderScript choice, renderMessages model.messages ]


renderScript : String -> Html msg
renderScript string =
    Html.node "script" [ Attr.src ("benches/" ++ string) ] []


onChange : (String -> msg) -> Html.Attribute msg
onChange tagger =
    Event.on "change" (Json.Decode.map tagger Event.targetValue)


renderPicker : List String -> Html Msg
renderPicker options =
    let
        makeOption : String -> Html msg
        makeOption option =
            Html.option [ Attr.value option ] [ Html.text option ]
    in
    Html.select [ onChange Load ]
        (Html.option [] []
            :: List.map
                makeOption
                options
        )


renderMessages : List SubMsg -> Html msg
renderMessages messages =
    let
        fromCells : List String -> Html msg
        fromCells =
            List.map
                (Html.text
                    >> List.singleton
                    >> Html.pre []
                    >> List.singleton
                    >> Html.td []
                )
                >> Html.tr []

        makeRow : SubMsg -> Html msg
        makeRow subMsg =
            case subMsg of
                Started msg ->
                    fromCells [ "Started", msg ]

                Running msg ->
                    fromCells [ "Running", msg ]

                Done json ->
                    fromCells
                        [ "Done"
                        , Json.Encode.encode 2 json
                        ]

                Unknown json ->
                    fromCells
                        [ "Unknown.."
                        , Json.Encode.encode 2 json
                        ]
    in
    Html.table [] (List.map makeRow messages)


receiveSubMsg : Json.Encode.Value -> SubMsg
receiveSubMsg encoded =
    let
        type_ : String -> Json.Decode.Decoder a -> Json.Decode.Decoder a
        type_ expected cont =
            Json.Decode.field "type" Json.Decode.string
                |> Json.Decode.andThen
                    (\typeString ->
                        if typeString == expected then
                            cont
                        else
                            Json.Decode.fail "nope"
                    )
    in
    Json.Decode.oneOf
        [ type_ "start" (Json.Decode.field "data" Json.Decode.string |> Json.Decode.map Started)
        , type_ "running" (Json.Decode.field "data" Json.Decode.string |> Json.Decode.map Running)
        , type_ "done" (Json.Decode.field "data" Json.Decode.value |> Json.Decode.map Done)
        ]
        |> flip Json.Decode.decodeValue encoded
        |> Result.withDefault (Unknown encoded)


subscriptions : Model -> Sub Msg
subscriptions model =
    receive receiveSubMsg |> Sub.map SubMsg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
