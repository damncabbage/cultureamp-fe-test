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


type alias Question a =
    { a
        | description : String
        , questionType : QuestionType
        , responses : List (Response Rating)
    }
