module Main exposing (..)

import Html exposing (program)
import Models exposing (initialModel, Model)
import Messages exposing (..)
import View exposing (view)
import Update exposing (update)
import Mouse


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    case drag of
        Nothing ->
            Sub.none

        Just _ ->
            Sub.batch
                [ Mouse.moves DragAt
                , Mouse.ups DragEnd
                ]



-- Main


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
