module Api.Url exposing (..)

import Data.Url as Url exposing (Url(..))
import Data.Survey exposing (SurveyId(..), Summary, surveyIdToString)


indexUrl : Url -> Url
indexUrl baseUrl =
    (Url.toString baseUrl)
        ++ "/"
        |> Url


surveyUrl : Url -> SurveyId -> Url
surveyUrl baseUrl id =
    (Url.toString baseUrl)
        ++ "/survey_results/"
        ++ (surveyIdToString id)
        |> Url
