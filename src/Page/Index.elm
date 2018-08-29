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
import Helpers exposing (updateWith)
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
view uplift model =
    div
        [ onClick (ChangeLocation (SurveyRoute (SurveyId 1))) ]
        [ text (toString model) ]


update : Url -> Msg -> (Msg -> RootMsg) -> ( Model, Cmd RootMsg )
update baseUrl msg uplift =
    case msg of
        LoadStart ->
            initLoad baseUrl
                |> updateWith identity uplift

        LoadFinish data ->
            ( data
            , Cmd.none
            )
