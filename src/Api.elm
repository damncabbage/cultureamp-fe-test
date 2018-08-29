module Api exposing (getIndex, getSurvey)

import Json.Decode as Decode exposing (Decoder)
import Http
import HttpBuilder as Builder
import Api.Json
import Api.Url exposing (indexUrl, surveyUrl)
import Api.Types exposing (SurveyFromApi)
import Data.Survey exposing (Summary, Survey, SurveyId)
import Data.Url as Url exposing (Url)


getIndex : Url -> Http.Request (List Summary)
getIndex baseUrl =
    get (indexUrl baseUrl) Api.Json.indexDecoder


getSurvey : Url -> SurveyId -> Http.Request SurveyFromApi
getSurvey baseUrl id =
    get (surveyUrl baseUrl id) Api.Json.surveyDecoder


get : Url -> Decoder a -> Http.Request a
get url decoder =
    (Url.toString url)
        |> Builder.get
        |> Builder.withExpect (decoder |> Http.expectJson)
        |> Builder.toRequest
