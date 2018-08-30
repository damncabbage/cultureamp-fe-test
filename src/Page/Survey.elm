module Page.Survey exposing (..)

import EveryDict as EDict exposing (EveryDict)
import Html exposing (Html, div, text)
import Http
import List.Nonempty as Nonempty
import RemoteData exposing (WebData, RemoteData(..))
import Task exposing (Task)
import Api
import Api.Types exposing (SurveyFromApi)
import Data.Url exposing (Url)
import Data.Msg exposing (RootMsg)
import Data.Survey as Survey exposing (Survey, SurveyId(..), Theme, surveyIdToString)
import Helpers exposing (updateWith)
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
            Nonempty.map
                (\theme ->
                    { theme
                        | questions = mapQuestions theme.questions
                    }
                )

        mapQuestions =
            Nonempty.indexedMap
                (\idx q ->
                    { description = q.description
                    , questionType = q.questionType
                    , responses = q.responses
                    , localId = QuestionId (idx + 1) -- 1, 2, ...
                    , hasBeenOpenedBefore = False
                    , breakdownState = IsClosed
                    }
                )
    in
        { survey | themes = mapThemes survey.themes }


initLoad : Model -> Url -> SurveyId -> ( Model, Cmd Msg )
initLoad model baseUrl id =
    if EDict.member id model then
        ( model, Cmd.none )
    else
        ( EDict.insert id Loading model
        , Api.getSurvey baseUrl id
            |> Http.toTask
            |> Task.attempt (RemoteData.fromResult >> LoadFinish id)
        )


view : SurveyId -> (Msg -> RootMsg) -> Model -> Html RootMsg
view id uplift model =
    div
        []
        [ text ("ID: " ++ (surveyIdToString id) ++ ", ")
        , EDict.get id model
            |> Maybe.map
                (viewSurvey id >> Html.map uplift)
            |> Maybe.withDefault (text "Doesn't exist")
        ]


viewSurvey : SurveyId -> WebData SurveyForUI -> Html Msg
viewSurvey id loadingState =
    case loadingState of
        NotAsked ->
            text "loading..."

        Loading ->
            text "loading..."

        Failure e ->
            text ("Failed! " ++ (toString e))

        Success a ->
            text (toString a)


viewTheme : Theme {} -> Html a
viewTheme q =
    div [] []

viewQuestion : QuestionForUI -> Html QuestionForUI
viewQuestion q =
    div [] []

{-
traverseHtml : String -> List (Attribute b) -> (List a -> b) -> (Int -> a -> List (Html a)) -> List a -> Html b
traverseHtml tagName attrs b2c ahb aa =
    buildHtmlList ab ahb as

buildHtmlList : (a -> b) -> (Int -> a -> List (Html b)) -> List a -> List (Html (List b))
buildHtmlList ab abh aa =
    let
        bs = List.map ab aa
    in
        List.mapWithIndex (\i a ->
                ?.map (List.map (\b -> Maybe.withDefault bs (Array
            ) aa
            |> List.concat

   in join $ flip mapWithIndex as $ \i a ->
map (map (\b -> fromMaybe bs $ Array.updateAt i b bs)) <<< abh i $ a
-}

update : Url -> Msg -> (Msg -> RootMsg) -> Model -> ( Model, Cmd RootMsg )
update baseUrl msg uplift model =
    case msg of
        OpenBreakdown id ->
            ( model, Cmd.none )

        CloseBreakdown id ->
            ( model, Cmd.none )

        LoadStart id ->
            initLoad model baseUrl id
                |> updateWith identity uplift

        LoadFinish id data ->
            ( model
                |> EDict.insert id (RemoteData.map initSurvey data)
            , Cmd.none
            )
