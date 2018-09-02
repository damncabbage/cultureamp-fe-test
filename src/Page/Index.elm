module Page.Index exposing (..)

import Html exposing (Html, a, div, dd, dl, dt, h1, h2, h3, header, li, main_, nav, ul, span, text)
import Html.Attributes exposing (href)
import Html.Events.Extra exposing (onClickPreventDefault)
import Http
import RemoteData exposing (WebData, RemoteData(..))
import Round
import Task exposing (Task)
import Api
import Data.Survey as Survey exposing (Survey, SurveyId(..))
import Data.Msg exposing (RootMsg(..))
import Data.Routing as Route exposing (Route(..))
import Data.Survey as Survey exposing (SurveyId(..), Summary)
import Data.Survey exposing (Survey)
import Data.Url exposing (Url)
import Helpers.Update exposing (updateWith)
import Page.Common as Common
import Page.Common.Styles as Common
import Page.Index.Styles as Index exposing (class, classList)
import Page.Index.Types exposing (Model, Msg(..))


initModel : Model
initModel =
    NotAsked


initLoad : Url -> ( Model, Cmd Msg )
initLoad baseUrl =
    ( Loading
    , Api.getIndex baseUrl
        |> Http.toTask
        |> Task.attempt (RemoteData.fromResult >> LoadFinish)
    )


view : (Msg -> RootMsg) -> Model -> Html RootMsg
view lift model =
    let
        subview =
            case model of
                NotAsked ->
                    Common.viewLoading

                Loading ->
                    Common.viewLoading

                Failure e ->
                    Html.map lift viewLoadingError

                Success a ->
                    viewLoadedList a
    in
        div []
            [ div [ Common.class .horizontalBar ]
                [ header
                    [ class .bannerHeadingBlock ]
                    [ h1
                        [ Common.class .bannerHeading ]
                        [ text "Survey Results" ]
                    ]
                ]
            , main_
                [ Common.class .paddedContentColumn ]
                [ subview ]
            ]


viewLoadingError : Html Msg
viewLoadingError =
    div
        [ Common.class .errorBox ]
        [ text "Sorry! There was a problem fetching the survey list for you. Would you like to "
        , a
            [ onClickPreventDefault LoadStart
            , href (Route.routeToPath IndexRoute)
            ]
            [ text "try again?" ]
        ]


viewLoadedList : List ( SurveyId, Summary ) -> Html RootMsg
viewLoadedList list =
    if List.length list == 0 then
        div
            [ Common.class .paddedContentColumn ]
            [ text "There are no surveys to view." ]
    else
        ul [ class .surveyList ]
            (List.map (\( id, s ) -> viewSummary id s) list)


viewSummary : SurveyId -> Summary -> Html RootMsg
viewSummary id summary =
    li
        []
        [ h2
            [ class .surveyHeading ]
            [ Common.changeLocationLink
                (SurveyRoute id)
                [ class .surveyHeadingLink ]
                [ text summary.name ]
            ]
        , dl [ class .surveySummary ]
            [ dt [] [ text "Participants:" ]
            , dd
                []
                [ text (toString summary.participantTotalCount) ]
            , dt [] [ text "Response rate:" ]
            , dd
                [ Common.classify 70 90 summary.participantResponseRate ]
                [ text (Round.round 0 summary.participantResponseRate ++ "%") ]
            ]
        ]


update : (Msg -> RootMsg) -> Url -> Msg -> ( Model, Cmd RootMsg )
update lift baseUrl msg =
    case msg of
        LoadStart ->
            initLoad baseUrl
                |> updateWith identity lift

        LoadFinish data ->
            ( data
            , Cmd.none
            )
