module RoutingTests exposing (..)

import Navigation exposing (Location)
import Expect exposing (Expectation)
import Test exposing (..)
import Fuzz exposing (..)
import Data.Routing as Routing exposing (Route(..))
import Data.Survey exposing (SurveyId(..))


locationParsing : Test
locationParsing =
    describe "Routing.parseLocation"
        [ describe "valid paths can be round-tripped"
            [ testLocation Routing.indexPath (Just IndexRoute)
            , fuzz (int |> Fuzz.map abs) "SurveyRoute" <|
                \id ->
                    expectLocation
                        (Routing.surveyPath <| SurveyId id)
                        (Just (SurveyRoute <| SurveyId id))
            ]
        , describe "invalid paths come back as Nothing"
            [ testLocation "/survey/a" Nothing
            , testLocation "/surveys" Nothing
            ]
        ]



-- Helpers


testLocation : String -> Maybe Route -> Test
testLocation path route =
    test path (\() -> expectLocation path route)


expectLocation : String -> Maybe Route -> Expectation
expectLocation path route =
    makePathLocation path
        |> Routing.parseLocation
        |> Expect.equal route


makePathLocation : String -> Location
makePathLocation path =
    { hash = ""
    , href = ""
    , host = "example.com"
    , hostname = ""
    , protocol = "http"
    , origin = ""
    , port_ = ""
    , pathname = path
    , search = ""
    , username = ""
    , password = ""
    }
