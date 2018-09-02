module Page.Survey exposing (..)

import EveryDict as EDict exposing (EveryDict)
import Html exposing (Html, Attribute, a, div, dd, dl, dt, h1, h2, h3, header, li, main_, nav, ol, section, span, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onClickPreventDefault)
import Http
import List.Nonempty as Nonempty
import Maybe.Extra as Maybe
import RemoteData exposing (WebData, RemoteData(..))
import Round
import Task exposing (Task)
import Api
import Api.Types exposing (SurveyFromApi)
import Data.Url exposing (Url)
import Data.Msg exposing (RootMsg(..))
import Data.Survey as Survey exposing (QuestionResponses(..), Response, Rating, Survey, SurveyId(..), Theme, surveyIdToString)
import Data.Survey.Stats as Survey
import Data.Routing as Route exposing (Route(..))
import Helpers.Update exposing (updateWith)
import Page.Common as Common
import Page.Common.Styles as Common
import Page.Survey.Styles as Survey exposing (class, classList)
import Page.Survey.Types exposing (Model, Msg(..), QuestionForUI, QuestionId(..), SurveyForUI, BreakdownState(..))


{-| Initialise the complete "component" state.
-}
initModel : Model
initModel =
    EDict.empty


{-| Annotate the Survey with information for UI display.
-}
initSurvey : SurveyFromApi -> SurveyForUI
initSurvey survey =
    let
        mapThemes =
            Nonempty.map <|
                \theme ->
                    { theme
                        | questions = mapQuestions theme.questions
                    }

        mapQuestions =
            Nonempty.indexedMap <|
                \idx q ->
                    { description = q.description
                    , responses = q.responses

                    -- Initialise UI-specific annotations:
                    , localId = QuestionId (idx + 1) -- 1, 2, ...
                    , hasBeenOpenedBefore = False
                    , breakdownState = IsClosed
                    }
    in
        { survey | themes = mapThemes survey.themes }


initLoad : Model -> Url -> SurveyId -> ( Model, Cmd Msg )
initLoad model baseUrl id =
    case EDict.get id model of
        Just (Success _) ->
            ( model, Cmd.none )

        _ ->
            ( EDict.insert id Loading model
            , Api.getSurvey baseUrl id
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> LoadFinish id)
            )



view : (Msg -> RootMsg) -> SurveyId -> Model -> Html RootMsg
view lift id model =
    let
        ( header, body ) =
            EDict.get id model
                |> Maybe.map (viewSurvey lift id)
                |> Maybe.withDefault
                    ( [], [Common.viewNotFoundError] )
    in
        div []
            [ div
                [ Common.class .horizontalBar ]
                ( List.concat
                    [ [ Common.viewBack ]
                    , header
                    ]
                )
            , main_ [] body
            ]


viewSurvey : (Msg -> RootMsg) -> SurveyId -> WebData SurveyForUI -> ( List (Html RootMsg), List (Html RootMsg) )
viewSurvey lift id loadingState =
    case loadingState of
        NotAsked ->
            ( [], [Common.viewLoading] )

        Loading ->
            ( [], [Common.viewLoading] )

        Failure e ->
            ( [], [viewError lift id e] )

        Success a ->
            viewLoadedSurvey id a


viewError : (Msg -> RootMsg) -> SurveyId -> Http.Error -> Html RootMsg
viewError lift id error =
    if Common.is404 error then
        Common.viewNotFoundError
    else
        Html.map lift (viewLoadingError id)


viewLoadingError : SurveyId -> Html Msg
viewLoadingError id =
    div
        [ Common.class .errorBox ]
        [ text "Sorry! There was a problem fetching that survey for you. Would you like to "
        , a
            [ onClickPreventDefault (LoadStart id)
            , href (Route.routeToPath (SurveyRoute id))
            ]
            [ text "try again?" ]
        ]


viewLoadedSurvey : SurveyId -> SurveyForUI -> ( List (Html a), List (Html a) )
viewLoadedSurvey id survey =
    ( [ header
        [ Common.class .paddedContentColumn ]
        [ h1
            [ Common.class .bannerHeading ]
            [ text survey.summary.name ]
        ]
      ]
    , Nonempty.toList survey.themes
        |> List.map (viewTheme id)
    )


viewTheme : SurveyId -> Theme QuestionForUI -> Html a
viewTheme id theme =
    section []
        [ div
            [ class .stickyBar ]
            [ div
                [ Common.classList
                    [ (.paddedContentColumn, True)
                    , (.navContainer, True)
                    ]
                ]
                [ h2
                    [ class .themeHeading ]
                    [ text theme.name ]
                ]
            ]
        , ol
            [ class .questionsList ]
            ( Nonempty.toList theme.questions
                |> List.map viewQuestion
            )
        ]


viewQuestion : QuestionForUI -> Html a
viewQuestion { description, responses } =
    li
        []
        [ h3
            [ class .questionDescription ]
            [ text description ]
        , case responses of
            RatingQuestion ratings ->
                viewRatingsSummary ratings
        ]


viewRatingsSummary : List (Response Rating) -> Html a
viewRatingsSummary responses =
    let
        uniqueRatings =
            Survey.uniqueRatings responses
        averageRating =
            Survey.average uniqueRatings
        responseRate =
            List.filter Maybe.isJust uniqueRatings
            |> List.length
            |> (\respCount ->
                    ((toFloat respCount) * 100.0)
                    / (toFloat (List.length uniqueRatings))
                )
    in
        dl [ class .questionSummary ]
            [ dt [] [ text "Average:" ]
            , dd
                [ Common.classify 2 4 averageRating ]
                [ text (Round.round 1 averageRating) ]
            , dt [] [ text "Response rate:" ]
            , dd
                [ Common.classify 70 90 responseRate ]
                [ text (Round.round 0 responseRate ++ "%") ]
            ]


update : (Msg -> RootMsg) -> Url -> Msg -> Model -> ( Model, Cmd RootMsg )
update lift baseUrl msg model =
    case msg of
        -- TODO: See the functions below; this is to assist with
        -- toggling a Question breakdown.
        UpdateSurveyModel id survey ->
            ( model
                |> EDict.insert id (Success survey)
            , Cmd.none
            )

        LoadStart id ->
            initLoad model baseUrl id
                |> updateWith identity lift

        LoadFinish id data ->
            ( model
                |> EDict.insert id (RemoteData.map initSurvey data)
            , Cmd.none
            )



-- Startings of an extension point to allow toggling a Question breakdown to show
-- more detailed stats (eg. numbers for each rating, instead of the just the proportion
-- that's currently present).


questionToggle : QuestionForUI -> Attribute QuestionForUI
questionToggle q =
    onClick
        { q
            | hasBeenOpenedBefore = True
            , breakdownState = toggleBreakdown q.breakdownState
        }


toggleBreakdown : BreakdownState -> BreakdownState
toggleBreakdown state =
    case state of
        IsOpen ->
            IsClosed

        IsClosed ->
            IsOpen
