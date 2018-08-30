module Main exposing (..)

import Html exposing (Html, div, text)
import Navigation exposing (Location, newUrl)


-- Internal imports

import Data.Msg exposing (RootMsg(..))
import Data.Routing as Routing exposing (Route(..), routeToPath)
import Data.Url exposing (Url(..))
import Helpers.Update exposing (updateWith)
import Page.Index
import Page.Index.Types
import Page.Survey
import Page.Survey.Types
import Page.NotFound
import Styles exposing (class)


type alias Flags =
    { apiBaseUrl : String
    }


type alias Model =
    { route : Maybe Routing.Route
    , apiBaseUrl : Url
    , pageIndex : Page.Index.Types.Model
    , pageSurvey : Page.Survey.Types.Model
    }


view : Model -> Html RootMsg
view { route, pageIndex, pageSurvey } =
    case route of
        Just IndexRoute ->
            Page.Index.view IndexMsg pageIndex

        Just (SurveyRoute id) ->
            Page.Survey.view id SurveyMsg pageSurvey

        Nothing ->
            Page.NotFound.view


init : Flags -> Location -> ( Model, Cmd RootMsg )
init flags location =
    { route = Nothing
    , apiBaseUrl = Url flags.apiBaseUrl
    , pageIndex = Page.Index.initModel
    , pageSurvey = Page.Survey.initModel
    }
        |> setRoute (Routing.parseLocation location)


update : RootMsg -> Model -> ( Model, Cmd RootMsg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )

        LocationHasChanged location ->
            setRoute (Routing.parseLocation location) model

        ChangeLocation route ->
            ( model
            , newUrl (Routing.routeToPath route)
            )

        IndexMsg subMsg ->
            Page.Index.update model.apiBaseUrl subMsg IndexMsg
                |> updateWith
                    (\si -> { model | pageIndex = si })
                    identity

        SurveyMsg subMsg ->
            Page.Survey.update model.apiBaseUrl subMsg SurveyMsg model.pageSurvey
                |> updateWith
                    (\sm -> { model | pageSurvey = sm })
                    identity


setRoute : Maybe Route -> Model -> ( Model, Cmd RootMsg )
setRoute maybeRoute model =
    let
        newModel =
            { model | route = maybeRoute }
    in
        case maybeRoute of
            Just (SurveyRoute id) ->
                updateWith
                    (\ps -> { newModel | pageSurvey = ps })
                    SurveyMsg
                    (Page.Survey.initLoad model.pageSurvey model.apiBaseUrl id)

            Just IndexRoute ->
                updateWith
                    (\ps -> { newModel | pageIndex = ps })
                    IndexMsg
                    (Page.Index.initLoad model.apiBaseUrl)

            -- TODO: Just, Nothing
            _ ->
                ( newModel
                , Cmd.none
                )


main : Program Flags Model RootMsg
main =
    Navigation.programWithFlags LocationHasChanged
        { init = init
        , update = update
        , subscriptions = \model -> Sub.none
        , view = view
        }
