module Data.Url exposing (..)


type Url
    = Url String


toString : Url -> String
toString (Url string) =
    string
