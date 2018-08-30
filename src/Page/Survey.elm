module Page.Survey exposing (..)

import EveryDict as EDict exposing (EveryDict)
import Html exposing (Html, Attribute, a, div, h1, header, nav, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import List.Nonempty as Nonempty
import RemoteData exposing (WebData, RemoteData(..))
import Task exposing (Task)
import Api
import Api.Types exposing (SurveyFromApi)
import Data.Url exposing (Url)
import Data.Msg exposing (RootMsg(..))
import Data.Survey as Survey exposing (Survey, SurveyId(..), Theme, surveyIdToString)
import Data.Routing as Route exposing (Route(..))
import Helpers.Update exposing (updateWith)
import Helpers.Html exposing (changeLocationLink)
import Page.Survey.Types exposing (Model, Msg(..), QuestionForUI, QuestionId(..), SurveyForUI, BreakdownState(..))
import Styles exposing (class)

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
                    , questionType = q.questionType
                    , responses = q.responses
                    , localId = QuestionId (idx + 1) -- 1, 2, ...
                    , hasBeenOpenedBefore = False
                    , breakdownState = IsClosed
                    }
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


content : Attribute a
content =
    class .contentColumn


view : SurveyId -> (Msg -> RootMsg) -> Model -> Html RootMsg
view id uplift model =
    div []
        [ nav
            [ content ]
            [ changeLocationLink IndexRoute
                    [ class .backLink ]
                    [ text "⬅ Back to Surveys" ]
            ]
        , EDict.get id model
            |> Maybe.map
                (viewSurvey id >> Html.map uplift)
            |> Maybe.withDefault (text "Doesn't exist") -- TODO: Errors
        ]

viewSurvey : SurveyId -> WebData SurveyForUI -> Html a
viewSurvey id loadingState =
    case loadingState of
        NotAsked ->
            text "loading..."

        Loading ->
            text "loading..."

        Failure e ->
            text ("Failed! " ++ (toString e))

        Success a ->
            viewLoadedSurvey id a

viewLoadedSurvey : SurveyId -> SurveyForUI -> Html a
viewLoadedSurvey id survey =
    div
        [ content ]
        [ header
            [ content ]
            [ h1 [ ] [ text survey.summary.name ]
            ]
        , div [] (Nonempty.toList survey.themes |> List.map (viewTheme id))
        ]
{-
    div
        []
        [ text ("ID: " ++ (surveyIdToString id) ++ ", ")
        -}


viewTheme : SurveyId -> Theme QuestionForUI -> Html a
viewTheme id theme =
    div [] []


viewQuestion : QuestionForUI -> Html a
viewQuestion q =
    div
        []
        [ text (toString q) ]


update : Url -> Msg -> (Msg -> RootMsg) -> Model -> ( Model, Cmd RootMsg )
update baseUrl msg uplift model =
    case msg of
        UpdateSurveyModel id survey ->
            ( model
                |> EDict.insert id (Success survey)
            , Cmd.none
            )

        LoadStart id ->
            initLoad model baseUrl id
                |> updateWith identity uplift

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



{-
   traverseHtml :
       (List (Html b) -> Html b) ->
       (List a -> b) ->
       (Int -> a -> List (Html a)) ->
       List a ->
       Html b
   traverseHtml element aListToB idxAToHBList aList =
      buildHtmlList identity idxAToHBList aList
      |> List.map (Html.map aListToB)
      |> element

   buildHtmlList :
       (a -> b) ->
       (Int -> a -> List (Html b)) ->
       List a ->
       List (Html (List b))
   buildHtmlList aToB idxAToHBList aList =
      let
          bList = List.map aToB aList
      in
          List.indexedMap (\i a ->
                  idxAToHBList i a
                      |> List.map (Html.map (\b -> Maybe.withDefault bList Nothing))
              ) aList
              |> List.concat

     --in join $ flip mapWithIndex as $ \i a ->
     --  map (map (\b -> fromMaybe bs $ Array.updateAt i b bs)) <<< abh i $ a
-}
