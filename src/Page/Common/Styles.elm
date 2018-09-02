module Page.Common.Styles exposing (..)

import CssModules exposing (css)


{ class, classList, toString } =
    css "./Page/Common.css"
        { link = ""
        , contentColumn = ""
        , paddedContentColumn = ""
        , navLink = ""
        , navContainer = ""
        , horizontalBar = ""
        , bannerHeading = ""
        , loadingBox = ""
        , errorBox = ""
        , spinner = ""
        , trafficRed = ""
        , trafficYellow = ""
        , trafficGreen = ""
        }
