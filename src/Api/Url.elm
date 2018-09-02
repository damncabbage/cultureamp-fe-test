module Api.Url exposing (indexUrl, surveyUrl, idFromSurveyUrl)

import Navigation exposing (Location)
import Regex exposing (HowMany(..), regex)
import UrlParser exposing (..)
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


idFromSurveyUrl : Url -> Maybe SurveyId
idFromSurveyUrl url =
    (Url.toString url)
        |> Regex.replace (AtMost 1) (regex "\\.json$") (\_ -> "")
        |> makePathLocation
        |> parsePath (map SurveyId (s "survey_results" </> int))
        

makePathLocation : String -> Location
makePathLocation path =
    { hash = ""
    , href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = path
    , search = ""
    , username = ""
    , password = ""
    }
