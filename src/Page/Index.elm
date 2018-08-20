module Page.Index exposing (..)

import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Data.Root exposing (Msg(..))
import Data.Routing exposing (Route(..))


type alias Model rest =
    { rest
    | todo : ()
    }


view : Data.Root.Model (Model r) -> Html Msg
view model =
    div
        [ onClick (ChangeLocation NotFoundRoute) ]
        [ text (toString model.surveyIndex) ]
