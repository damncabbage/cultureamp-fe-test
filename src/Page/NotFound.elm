module Page.NotFound exposing (..)

import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Data.Root exposing (Msg(..))
import Data.Routing exposing (Route(..))

view : Html Msg
view =
    div
        [ onClick (ChangeLocation IndexRoute) ]
        [ text "nah" ]
