module ApiJsonTests exposing (..)

import Expect exposing (Expectation)
import Json.Encode as Encode
import Json.Decode as Decode
import Test exposing (..)
import Fuzz exposing (..)
import FuzzHelpers exposing (..)
import Api
import Api.Json
import Api.Types as Api exposing (SurveyFromApi)
import Data.Survey as Survey exposing (SurveyId(..), Summary, surveyIdToString)
import Data.Url exposing (Url(..))


-- Notes:
-- This is not a complete test suite; this is intended as illustrative to show
-- how JSON decoders can be round-tripped with fuzz tests to flush out assumptions.


indexParsing : Test
indexParsing =
    describe "Api.Json.indexDecoder"
        [ fuzz genIndex "Survey.Index round-trip" <|
            \index ->
                index
                    |> (Encode.encode 2 << encodeIndex)
                    |> Decode.decodeString Api.Json.indexDecoder
                    |> Expect.equal (Ok index)
        ]



-- Helpers
-- These arguably belong alongside the Api.Json decoders (so they can be
-- more easily kept in sync), but they're purely here to show how fuzzing
-- an API works, so here they'll stay.


encodeIndex : Survey.Index -> Encode.Value
encodeIndex list =
    Encode.object
        [ ( "survey_results"
          , Encode.list
                (List.map (\( _, summ ) -> encodeSummary summ) list)
          )
        ]


encodeSummary : Survey.Summary -> Encode.Value
encodeSummary summary =
    Encode.object
        [ ( "name", Encode.string <| summary.name )
        , ( "url", Encode.string <| Data.Url.toString summary.url )
        , ( "participant_count", Encode.int <| summary.participantTotalCount )
        , ( "submitted_response_count", Encode.int <| summary.participantResponseCount )
        , ( "response_rate", Encode.float <| summary.participantResponseRate / 100.0 )
        ]


genIndex : Fuzzer Survey.Index
genIndex =
    genSurveyId
        |> Fuzz.andThen
            (\id ->
                list (Fuzz.map (\summ -> ( id, summ )) (genSummary id))
            )


genSummary : SurveyId -> Fuzzer Survey.Summary
genSummary id =
    Fuzz.map Survey.Summary string
        |> Fuzz.andMap
            (Fuzz.constant
                (Url ("/survey_results/" ++ (surveyIdToString id)))
            )
        |> Fuzz.andMap (positive int)
        |> Fuzz.andMap (positive int)
        |> Fuzz.andMap (floatRange 0.0 100.0)


genSurveyId : Fuzzer SurveyId
genSurveyId =
    positive int
        |> Fuzz.map SurveyId
