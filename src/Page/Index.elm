module Page.Index exposing (..)

import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Http
import RemoteData exposing (WebData, RemoteData(..))
import Task exposing (Task)
import Api
import Data.Survey as Survey exposing (Survey, SurveyId(..))
import Data.Msg exposing (RootMsg(..))
import Data.Routing exposing (Route(..))
import Data.Survey exposing (SurveyId(..))
import Data.Survey as Survey exposing (SurveyId(..))
import Data.Routing as Routing
import Data.Survey exposing (Survey)
import Data.Url exposing (Url)
import Helpers.Update exposing (updateWith)
import Page.Index.Types exposing (Model, Msg(..))
import Page.Common.Styles as Common
import Page.Index.Styles as Index


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
    div
        [ onClick (ChangeLocation (SurveyRoute (SurveyId 1))) ]
        [ text (toString model) ]


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
