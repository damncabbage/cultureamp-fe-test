module Page.NotFound exposing (..)

import Html exposing (Html, div)
import Data.Msg exposing (RootMsg(..))
import Page.Common as Common
import Page.Common.Styles as Common


view : Html RootMsg
view =
    div []
        [ div
            [ Common.class .horizontalBar ]
            [ Common.viewBack ]
        , Common.viewNotFoundError
        ]
