module ApiUrlTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Data.Url as Url exposing (Url(..))
import Data.Survey as Survey exposing (SurveyId(..))
import Api.Url as Api


idFromSurveyUrl : Test
idFromSurveyUrl =
    let
        data = 
            [ ( "/survey_results/1", Just (SurveyId 1) )
            , ( "/survey_results/1.json", Just (SurveyId 1) )
            , ( "/survey_results/234.json", Just (SurveyId 234) )
            , ( "survey_results/1.json", Just (SurveyId 1) )
            , ( "/survey_results/1.jsonb", Nothing )
            , ( "/survey_results/a.json", Nothing )
            ]
    in
        test "idFromSurveyUrl" <|
            \() ->
                data
                    |> List.map
                        (\( url, _ ) ->
                            Api.idFromSurveyUrl (Url url)
                        )
                    |> Expect.equal
                        (List.map (\( _, r) -> r) data)
