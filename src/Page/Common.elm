module Page.Common exposing (..)

import Html exposing (Html, Attribute, a, div, text, nav, p)
import Html.Attributes exposing (href)
import Html.Events.Extra exposing (onClickPreventDefault)
import Http
import Data.Routing as Route exposing (Route(..))
import Data.Msg exposing (RootMsg(..))
import Page.Common.Styles exposing (class, classList)


changeLocationLink : Route -> List (Attribute RootMsg) -> List (Html RootMsg) -> Html RootMsg
changeLocationLink route attrs children =
    let
        changeAttrs =
            [ onClickPreventDefault (ChangeLocation route)
            , href (Route.routeToPath route)
            ]
    in
        a (List.concat [ changeAttrs, attrs ]) children


viewBack : Html RootMsg
viewBack =
    nav
        [ classList
            [ ( .paddedContentColumn, True )
            , ( .navContainer, True )
            ]
        ]
        [ changeLocationLink
            IndexRoute
            [ class .navLink ]
            [ text "Back to Surveys" ]
        ]


viewLoading : Html a
viewLoading =
    div
        [ class .loadingBox ]
        [ spinner
        , p [] [ text "Loading..." ]
        ]


viewNotFoundError : Html RootMsg
viewNotFoundError =
    div
        [ class .errorBox ]
        [ text "We couldn't find what you were looking for. Would you like to "
        , changeLocationLink
            IndexRoute
            [ class .link ]
            [ text "head back to the survey list?" ]
        ]


is404 : Http.Error -> Bool
is404 error =
    case error of
        Http.BadStatus { status } ->
            status.code == 404

        _ ->
            False


spinner : Html a
spinner =
    div [ class .spinner ] <|
        List.repeat 12 (div [] [])


classify : comparable -> comparable -> comparable -> Attribute a
classify upperRed upperYellow value =
    class <|
        if value <= upperRed then
            .trafficRed
        else if value <= upperYellow then
            .trafficYellow
        else
            .trafficGreen
