module Page.Index.Types exposing (..)

import RemoteData exposing (WebData)
import Data.Survey as Survey exposing (Summary, SurveyId(..))


type alias Model =
    WebData (List Summary)


type Msg
    = LoadStart
    | LoadFinish Model
