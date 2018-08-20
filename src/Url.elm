module Url exposing (..)


type Url
    = Url String


toString : Url -> String
toString (Url s) =
    s
