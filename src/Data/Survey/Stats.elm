module Data.Survey.Stats exposing (..)

import Dict
import Dict.Extra as Dict
import Maybe.Extra as Maybe
import List.Extra as List
import Data.Survey exposing (Response, Rating, ratingToInt)


uniqueRatings : List (Response Rating) -> List (Maybe Rating)
uniqueRatings responses =
    List.uniqueBy .respondentId responses
        |> List.map .response


average : List (Maybe Rating) -> Float
average ratings =
    ratings
        |> Maybe.values
        |> List.map ratingToInt
        |> Dict.frequencies
        |> Dict.toList
        |> List.foldr
            (\( rating, count ) ( totalRating, totalCount ) ->
                ( totalRating + (rating * count)
                , totalCount + count
                )
            )
            ( 0, 0 )
        |> (\( ratings, counts ) ->
                if counts > 0 then
                    (toFloat ratings) / (toFloat counts)
                else
                    0.0
            )
