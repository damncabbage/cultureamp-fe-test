module Api.Json exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, decode, hardcoded, required, requiredAt)
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Maybe.Extra as Maybe
import Api.Types exposing (SurveyFromApi)
import Api.Url exposing (idFromSurveyUrl)
import Data.Survey as Survey exposing (Question, QuestionResponses(..), Rating, Response, Survey, Summary, Theme, intToRating)
import Data.Url exposing (Url(..))
import Helpers.Json exposing (failDecodeIfNothing)


indexDecoder : Decoder Survey.Index
indexDecoder =
    let
        summaryTupleDecoder =
            summaryDecoder
                |> Decode.andThen
                    (\summary ->
                        summary.url
                            |> idFromSurveyUrl
                            |> failDecodeIfNothing
                            |> Decode.map (\id -> ( id, summary ))
                    )
    in
        Decode.field "survey_results"
            (Decode.list summaryTupleDecoder)


surveyDecoder : Decoder SurveyFromApi
surveyDecoder =
    let
        rootField =
            "survey_result_detail"
    in
        decode Survey
            |> required rootField summaryDecoder
            |> requiredAt [ rootField, "themes" ]
                (nonEmptyListDecoder themeDecoder)


summaryDecoder : Decoder Summary
summaryDecoder =
    decode Summary
        |> required "name" Decode.string
        |> required "url" urlDecoder
        |> required "participant_count" (positiveDecoder Decode.int)
        |> required "submitted_response_count" (positiveDecoder Decode.int)
        |> required "response_rate"
            (positiveDecoder Decode.float
                |> Decode.map (\x -> x * 100.0)
            )


themeDecoder : Decoder (Theme (Question {}))
themeDecoder =
    decode Theme
        |> required "name" Decode.string
        |> required "questions" (nonEmptyListDecoder questionDecoder)


questionDecoder : Decoder (Question {})
questionDecoder =
    let
        makeQuestion desc resps =
            { description = desc
            , responses = resps
            }
    in
        decode makeQuestion
            |> required "description" Decode.string
            |> custom questionResponsesDecoder


questionResponsesDecoder : Decoder QuestionResponses
questionResponsesDecoder =
    let
        validRatingResponses =
            Decode.list ratingResponseDecoder
                |> Decode.map Maybe.values
    in
        Decode.field "question_type" Decode.string
            |> Decode.andThen
                (\questionType ->
                    case questionType of
                        "ratingquestion" ->
                            decode RatingQuestion
                                |> required "survey_responses" validRatingResponses

                        _ ->
                            Decode.fail ("Unknown question type: " ++ questionType)
                )


ratingResponseDecoder : Decoder (Maybe (Response Rating))
ratingResponseDecoder =
    let
        makeResponse id resultResponse =
            resultResponse
                |> Result.toMaybe
                |> Maybe.map (\res -> { respondentId = id, response = res })

        ratingDecoder =
            Decode.string
                |> Decode.andThen
                    (\str ->
                        if str == "" then
                            Decode.succeed (Ok Nothing)
                        else
                            case String.toInt str of
                                Ok num ->
                                    (intToRating num)
                                        |> Maybe.unpack
                                            (\x ->
                                                Debug.log ("Rating outside range: " ++ str) (Err x)
                                            )
                                            (Ok << Just)
                                        |> Decode.succeed

                                Err _ ->
                                    Decode.fail ("Not a number: " ++ str)
                    )
    in
        decode makeResponse
            |> required "respondent_id" Decode.int
            |> required "response_content" ratingDecoder


urlDecoder : Decoder Url
urlDecoder =
    Decode.string
        |> Decode.map Url


positiveDecoder : Decoder number -> Decoder number
positiveDecoder numDecoder =
    numDecoder
        |> Decode.andThen
            (\n ->
                if n >= 0 then
                    Decode.succeed n
                else
                    Decode.fail (toString n ++ " is not a positive number")
            )


nonEmptyListDecoder : Decoder a -> Decoder (Nonempty a)
nonEmptyListDecoder decoder =
    Decode.list decoder
        |> Decode.andThen
            (\list ->
                Nonempty.fromList list
                    |> Maybe.unwrap
                        (Decode.fail "List is unexpectedly empty")
                        (Decode.succeed)
            )
