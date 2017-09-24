module FoldrTest exposing (..)

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


cases : List ( String, (a -> b -> b) -> b -> List a -> b )
cases =
    [ ( "list 1", FL1.foldr )
    , ( "list 2", FL2.foldr )
    , ( "list 3", FL3.foldr )
    , ( "list 4", FL4.foldr )
    , ( "list 5", FL5.foldr )
    , ( "list 6", FL6.foldr )
    , ( "list 7", FL7.foldr )
    , ( "list 8", FL8.foldr )
    ]


testCase : String -> ((Int -> List Int -> List Int) -> List Int -> List Int -> List Int) -> Test
testCase name foldr =
    fuzz (list int) name <|
        \input ->
            foldr (::) [] input
                |> Expect.equalLists
                    (List.foldr (::) [] input)


testAll : Test
testAll =
    List.map (uncurry testCase) cases
        |> describe "all cases"
