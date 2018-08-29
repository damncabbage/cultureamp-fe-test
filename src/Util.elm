module Util exposing (..)


hole : Never
hole =
    Debug.crash "hole"


hole1 : a -> Never
hole1 =
    Debug.crash "hole1"


hole2 : Never -> Never -> Never
hole2 =
    Debug.crash "hole2"


hole3 : Never -> Never -> Never -> Never
hole3 =
    Debug.crash "hole3"
