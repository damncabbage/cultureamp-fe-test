module Helpers.Json exposing (..)

import Json.Decode as Decode exposing (Decoder)

failDecodeIfNothing : Maybe a -> Decoder a
failDecodeIfNothing maybe =
    case maybe of
        Nothing ->
            Decode.fail "Expected a value; got Nothing"
        Just x ->
            Decode.succeed x
