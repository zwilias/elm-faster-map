module MapTest exposing (..)

import Expect exposing (Expectation)
import Fast.List1 as FL1
import Fast.List2 as FL2
import Fast.List3 as FL3
import Fast.List4 as FL4
import Fast.List5 as FL5
import Fast.List6 as FL6
import Fast.List7 as FL7
import Fast.List8 as FL8
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


mapCases : List ( String, (a -> b) -> List a -> List b )
mapCases =
    [ ( "list 1", FL1.map )
    , ( "list 2", FL2.map )
    , ( "list 3", FL3.map )
    , ( "list 4", FL4.map )
    , ( "list 5", FL5.map )
    , ( "list 6", FL6.map )
    , ( "list 7", FL7.map )
    , ( "list 8", FL8.map )
    ]


testCase : String -> ((number -> number) -> List number -> List number) -> Test
testCase name map =
    fuzz (list int) name <|
        \input ->
            map ((*) 3) input
                |> Expect.equalLists
                    (List.map ((*) 3) input)


testAll : Test
testAll =
    List.map (uncurry testCase) mapCases
        |> describe "all cases"
