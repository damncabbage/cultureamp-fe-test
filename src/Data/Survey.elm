module Data.Survey exposing (..)

import List.Nonempty exposing (Nonempty)
import Data.Url exposing (Url)


type alias Index =
    List Summary


type alias Summary =
    { name : String
    , url : Url
    , participantTotalCount : Int
    , participantResponseCount : Int
    , participantResponseRate : Float
    }


type alias Survey question =
    { summary : Summary
    , themes : Nonempty (Theme question)
    }


type alias Theme question =
    { name : String
    , questions : Nonempty question
    }


type SurveyId
    = SurveyId Int


surveyIdToString : SurveyId -> String
surveyIdToString (SurveyId id) =
    toString id


type Rating
    = Rating Int


type alias Response a =
    { respondentId : Int
    , response : Maybe a
    }


type QuestionType
    = RatingQuestion


{-| This is an extensible type representing a survey question; it's extensible because
we could plug the gap with {} (eg. Question {}) to represent the bare information coming
back from the API, or we could provide something like Question { infoIsOpen : Bool }, where
additional information is used for the UI state, without needing to make a completely
separate type for it; Page.Survey.Types.QuestionForUI is an example of this for-UI
extended type.
-}
type alias Question a =
    { a
        | description : String
        , questionType : QuestionType
        , responses : List (Response Rating)
    }
