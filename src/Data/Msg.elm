module Data.Msg exposing (..)

import Navigation exposing (Location)
import Data.Routing as Routing
import Page.Survey.Types
import Page.Index.Types


type RootMsg
    = DoNothing
    | LocationHasChanged Location
    | ChangeLocation Routing.Route
    | IndexMsg Page.Index.Types.Msg
    | SurveyMsg Page.Survey.Types.Msg
