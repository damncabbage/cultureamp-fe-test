module Data.Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


-- Internal imports

import Data.Survey exposing (SurveyId(..))


type Route
    = IndexRoute
    | SurveyRoute SurveyId


parseLocation : Location -> Maybe Route
parseLocation location =
    parsePath routeParser location


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map IndexRoute top
        , map (SurveyRoute << SurveyId) (s "survey" </> int)
        ]


routeToPath : Route -> String
routeToPath route =
    case route of
        IndexRoute ->
            indexPath

        SurveyRoute id ->
            surveyPath id


indexPath : String
indexPath =
    "/"


surveyPath : SurveyId -> String
surveyPath (SurveyId id) =
    "/survey/" ++ (toString id)
