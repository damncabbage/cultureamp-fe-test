module SurveyStatsTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Data.Survey as Survey exposing (Rating(..), Response, SurveyId(..))
import Data.Survey.Stats as Survey


uniqueRatings : Test
uniqueRatings =
    let
        data =
            [ { respondentId = 1, response = Just (Rating 1) }
            , { respondentId = 2, response = Just (Rating 3) }
            , { respondentId = 3, response = Just (Rating 5) }
            , { respondentId = 4, response = Nothing }
            , { respondentId = 5, response = Just (Rating 5) }
            ]
    in
        describe "uniqueRatings"
            [ test "empty" <|
                \() ->
                    Survey.uniqueRatings []
                        |> Expect.equal []
            , test "with no duplicates" <|
                \() ->
                    Survey.uniqueRatings data
                        |> Expect.equal (List.map .response data)
            , test "with duplicates" <|
                \() ->
                    Survey.uniqueRatings (List.concat [ data, data ])
                        |> Expect.equal (List.map .response data)
            ]


average : Test
average =
    let
        data =
            [ Just (Rating 1)
            , Just (Rating 3)
            , Just (Rating 5)
            , Nothing
            , Just (Rating 5)
            ]
    in
        describe "average"
            [ test "empty" <|
                \() ->
                    Survey.average []
                        |> Expect.equal 0.0
            , test "ignores Nothing in calculation" <|
                \() ->
                    Survey.average data
                        |> Expect.equal 3.5
            ]
