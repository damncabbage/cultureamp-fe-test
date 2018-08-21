module Page.Survey exposing (..)

import Html exposing (Html, div, text)
import Data.Survey exposing (SurveyId, surveyIdToString)
import Data.Root


type alias Model rest =
    { rest
    | todo : ()
    }


view : SurveyId -> Data.Root.Model (Model r) -> Html a
view id model =
    div [] [
        text ("ID: " ++ (surveyIdToString id))
    ]
