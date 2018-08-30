module Helpers.Html exposing (..)

import Html exposing (Html, Attribute, a)
import Html.Attributes exposing (href)
import Html.Events.Extra exposing (onClickPreventDefault)
import Data.Routing as Route exposing (Route)
import Data.Msg exposing (RootMsg(..))


changeLocationLink : Route -> List (Attribute RootMsg) -> List (Html RootMsg) -> Html RootMsg
changeLocationLink route attrs children =
    let
        changeAttrs = 
            [ onClickPreventDefault (ChangeLocation route)
            , href (Route.routeToPath route)
            ]
    in
        a (List.concat [changeAttrs, attrs]) children

