module Api.Json exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, hardcoded, required, requiredAt)
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Maybe.Extra as Maybe
import Api.Types exposing (SurveyFromApi)
import Data.Survey as Survey exposing (Question, QuestionType(..), Rating(..), Response, Survey, Summary, Theme)
import Data.Url exposing (Url(..))


indexDecoder : Decoder (List Summary)
indexDecoder =
    Decode.field "survey_results" (Decode.list summaryDecoder)


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
    let
        makeSummary name url total responses rate =
            { name = name
            , url = url
            , participant =
                { totalCount = total
                , responseCount = responses
                , responseRate = rate
                }
            }
    in
        decode makeSummary
            |> required "name" Decode.string
            |> required "url" urlDecoder
            |> required "participant_count" (positiveDecoder Decode.int)
            |> required "submitted_response_count" (positiveDecoder Decode.int)
            |> required "response_rate" (positiveDecoder Decode.float)


themeDecoder : Decoder (Theme (Question {}))
themeDecoder =
    decode Theme
        |> required "name" Decode.string
        |> required "questions" (nonEmptyListDecoder questionDecoder)


questionDecoder : Decoder (Question {})
questionDecoder =
    let
        makeQuestion desc qtype resps =
            { description = desc
            , questionType = qtype
            , responses = resps
            }

        structureDecoder qtype responseDecoder =
            decode makeQuestion
                |> required "description" Decode.string
                |> hardcoded qtype
                |> required "survey_responses" (Decode.list responseDecoder)
    in
        Decode.field "question_type" questionTypeDecoder
            |> Decode.andThen
                (\questionType ->
                    case questionType of
                        -- This is an expansion point for further question types.
                        RatingQuestion ->
                            structureDecoder questionType ratingResponseDecoder
                )


questionTypeDecoder : Decoder QuestionType
questionTypeDecoder =
    Decode.string
        |> Decode.andThen
            (\questionType ->
                case questionType of
                    "ratingquestion" ->
                        Decode.succeed RatingQuestion

                    _ ->
                        Decode.fail ("Unknown question type: " ++ questionType)
            )


ratingResponseDecoder : Decoder (Response Rating)
ratingResponseDecoder =
    let
        makeResponse respondentId response =
            { respondentId = respondentId
            , response = response
            }

        ratingDecoder =
            Decode.string
                |> Decode.andThen
                    (\str ->
                        if str == "" then
                            Decode.succeed Nothing
                        else
                            case String.toInt str of
                                Ok num ->
                                    if num >= 0 || num <= 5 then
                                        Decode.succeed (Just (Rating num))
                                    else
                                        Decode.fail ("Rating outside range: " ++ str)

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



{-
   exactStringDecoder : Nonempty (String -> Decode a) -> Decode a
   exactStringDecoder nonEmptyMatchers =
       let
           matchers =
               Nonempty.toList nonEmptyMatchers
       Decode.string
           |> Decode.andThen (\str ->
               if (List.any (\x -> x == matcher) matchers) then
                   Decode.succeed str
               else
                   Decode.fail
                       ("String doesn't match any of: " ++ (toString matchers))
                   )
-}
