module Page.Index exposing (..)

import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Data.Root exposing (Msg(..))
import Data.Routing exposing (Route(..))
import Data.Survey exposing (SurveyId(..))


type alias Model rest =
    { rest
    | todo : ()
    }


view : Data.Root.Model (Model r) -> Html Msg
view model =
    div
        [ onClick (ChangeLocation (SurveyRoute (SurveyId 1))) ]
        [ text (toString model.surveyIndex) ]
