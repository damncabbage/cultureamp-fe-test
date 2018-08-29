module Api.Types exposing (..)

import Data.Survey exposing (Question, Survey)


type alias SurveyFromApi =
    Survey (Question {})
