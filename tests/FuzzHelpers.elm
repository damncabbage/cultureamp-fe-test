module FuzzHelpers exposing (..)

import Fuzz exposing (Fuzzer)


positive : Fuzzer number -> Fuzzer number
positive genNum =
    genNum
        |> Fuzz.map abs
