module Page.Survey.Styles exposing (..)

import CssModules exposing (css)


{ class, classList, toString } =
    css "./Page/Survey.css"
        { themeHeading = ""
        , stickyBar = ""
        , questionsList = ""
        , questionDescription = ""
        }
