module Page.Survey exposing (..)

import Html exposing (Html, div, text)
import Data.Survey exposing (SurveyId, surveyIdToString)
import Data.Root


type alias Model rest =
    { rest
    | surveyId : Maybe SurveyId
    }


view : Data.Root.Model (Model r) -> Html a
view model =
    div [] [
        text ("ID: " ++ (
            (Maybe.withDefault "X" 
                (Maybe.map surveyIdToString model.surveyId)
            )
        )
    )
    ]
