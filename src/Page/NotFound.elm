module Page.NotFound exposing (..)

import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Data.Msg exposing (RootMsg(..))
import Data.Routing exposing (Route(..))


view : Html RootMsg
view =
    div
        [ onClick (ChangeLocation IndexRoute) ]
        [ text "nah" ]
