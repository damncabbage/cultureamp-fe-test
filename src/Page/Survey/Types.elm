module Page.Survey.Types exposing (..)

import EveryDict as EDict exposing (EveryDict)
import RemoteData exposing (WebData)
import Data.Survey as Survey exposing (Question, Survey, SurveyId(..))
import Api.Types exposing (SurveyFromApi)


type alias SurveyForUI =
    Survey QuestionForUI


type alias QuestionForUI =
    Question
        { localId : QuestionId
        , hasBeenOpenedBefore : Bool
        , breakdownState : BreakdownState
        }


type BreakdownState
    = IsOpen
    | IsClosed


type QuestionId
    = QuestionId Int


type alias Model =
    EveryDict Survey.SurveyId (WebData SurveyForUI)


type Msg
    = OpenBreakdown SurveyId
    | CloseBreakdown SurveyId
    | LoadStart SurveyId
    | LoadFinish SurveyId (WebData SurveyFromApi)
