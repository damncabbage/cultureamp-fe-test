module Page.Survey.Types exposing (..)

import EveryDict as EDict exposing (EveryDict)
import RemoteData exposing (WebData)
import Data.Survey as Survey exposing (Question, Survey, SurveyId(..))
import Api.Types exposing (SurveyFromApi)


type BreakdownState
    = IsOpen
    | IsClosed


type alias SurveyForUI =
    Survey
        (Question
            { localId : Int
            , hasBeenOpenedBefore : Bool
            , breakdownState : BreakdownState
            }
        )


type alias Model =
    EveryDict Survey.SurveyId (WebData SurveyForUI)


type Msg
    = OpenBreakdown SurveyId
    | CloseBreakdown SurveyId
    | LoadStart SurveyId
    | LoadFinish SurveyId (WebData SurveyFromApi)
