module Main exposing (..)

import Html exposing (div, text)
import Styles exposing (class)

type alias Flags =
    { apiBaseUrl : String
    }

type alias Model =
    {}

init : Flags -> (Model, Cmd msg)
init flags =
    ({}, Cmd.none)

view : Model -> Html.Html a
view model =
    div
        [ class .papayawhip ]
        [ text "Loading..." ]

main : Program Flags Model a
main =
    Html.programWithFlags
        { init = init
        , update = \msg model -> (model, Cmd.none)
        , subscriptions = \model -> Sub.none
        , view = view
        }
