module Survey exposing (..)

import Url exposing (Url)

import Positive exposing (Positive)
import List.Nonempty exposing (Nonempty)

type alias Summary = {
      name : String
    , url : Url
    , participant : {
          totalCount : Positive Int
        , responseCount : Positive Int
        , responseRate : Positive Float
        }
    }

type alias Theme = {
      name : String
    , question : Nonempty Question
    }

type Rating = Rating Int

type alias Response a = {
      id : Int
    , questionId : Int
    , respondentId : Int
    , response : Maybe a
    }

-- Potential sum-type here.
type QuestionType = RatingQuestion

type alias Question = {
      description : String
    , questionType : QuestionType
    , ratingResponses : List (Response Rating)
    }

type Survey = Survey {
      summary : Summary
    , themes : Nonempty Theme
    }