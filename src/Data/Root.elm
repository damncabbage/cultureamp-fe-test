module Data.Root exposing (..)

import Navigation exposing (Location)
import Dict exposing (Dict)
import RemoteData exposing (WebData)
import List.Nonempty exposing (Nonempty)
import Data.Survey as Survey exposing (SurveyId(..))
import Data.Routing as Routing


type alias Flags =
    { apiBaseUrl : String
    }


type alias Model rest =
    { rest
    | route : Routing.Route
    , config : Flags
    , surveyIndex : WebData (List Survey.Summary)
    , surveys : Dict Survey.SurveyId (WebData (Nonempty Survey.Theme))
    }

type Msg
    = LocationHasChanged Location
    | ChangeLocation Routing.Route
