module Page.Index.Types exposing (..)

import RemoteData exposing (WebData)
import Data.Survey as Survey exposing (Summary, SurveyId(..))


type alias Model =
    WebData Survey.Index


type Msg
    = LoadStart
    | LoadFinish Model
