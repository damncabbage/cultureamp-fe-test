module Main exposing (..)

import Html exposing (Html, div, text)
import Navigation exposing (Location, newUrl)
import Dict exposing (Dict)
import RemoteData exposing (WebData)


-- Internal imports

import Data.Root exposing (Flags, Model, Msg(..))
import Data.Routing as Routing exposing (Route(..), routeToPath)
import Page.Index
import Page.Survey
import Page.NotFound
import Styles exposing (class)


view : ProgramModel -> Html Msg
view model =
    let
        subview = case model.route of
            Just IndexRoute ->
                Page.Index.view model
            Just (SurveyRoute id) ->
                Page.Survey.view id model
            Nothing ->
                Page.NotFound.view
    in
        div
            [ class .papayawhip ]
            [ text (toString model.route)
            , subview
            ]

type alias ProgramModel =
    Model (Page.Index.Model (Page.Survey.Model {}))

init : Flags -> Location -> ( ProgramModel, Cmd Msg )
init flags location =
    ( { route = Routing.parseLocation location
      , config = flags
      , surveyIndex = RemoteData.NotAsked
      , surveys = Dict.empty
      , todo = ()
      }
    , Cmd.none
    )

update : Msg -> ProgramModel -> (ProgramModel, Cmd Msg)
update msg model =
    case msg of
        LocationHasChanged location ->
            ( { model | route = Routing.parseLocation location }
            , Cmd.none
            )
        ChangeLocation route ->
            ( model
            , newUrl (Routing.routeToPath route)
            )

main : Program Flags ProgramModel Msg
main =
    Navigation.programWithFlags LocationHasChanged
        { init = init
        , update = update
        , subscriptions = \model -> Sub.none
        , view = view
        }
