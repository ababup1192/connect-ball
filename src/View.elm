module View exposing (view)

import Dict exposing (Dict)
import Messages exposing (..)
import Mouse exposing (Position)
import Models exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Svg exposing (..)
import Svg.Attributes as SvgAttr
import Svg.Events as SvgEvent
import Json.Decode as Decode


-- View


view : Model -> Html Msg
view ({ mode, points, drag } as model) =
    div [ class "main" ]
        [ Html.a [ class "button is-primary is-outlined", onClick Flip ]
            [ Svg.text <| toString mode ]
        , div [ class "canvas" ]
            [ canvas model
            ]
        ]


canvas : Model -> Svg Msg
canvas ({ points, drag } as model) =
    let
        circles =
            List.map
                (\( id, position ) ->
                    let
                        xy =
                            case drag of
                                Just drag ->
                                    if id == drag.id then
                                        getPosition model id
                                    else
                                        position

                                _ ->
                                    position

                        cx =
                            toString <| xy.x - 20

                        cy =
                            toString <| xy.y - 55
                    in
                        circle
                            [ SvgAttr.class "circle"
                            , SvgAttr.cx <| cx
                            , SvgAttr.cy <| cy
                            , SvgAttr.r "10"
                            , SvgAttr.fill "#0B79CE"
                            , onCircleMouseDown id
                            ]
                            []
                )
                (Dict.toList points)
    in
        Svg.svg [ SvgAttr.viewBox "0 0 700 500", onCanvasClick ] circles


px : Int -> String
px number =
    toString number ++ "px"


getPosition : Model -> Int -> Position
getPosition { drag, points } id =
    let
        position =
            case (Dict.get id points) of
                Just pos ->
                    pos

                Nothing ->
                    Debug.crash "id not found"
    in
        case drag of
            Nothing ->
                position

            Just { start, current } ->
                Position
                    (position.x + current.x - start.x)
                    (position.y + current.y - start.y)


onCanvasClick : Svg.Attribute Msg
onCanvasClick =
    SvgEvent.on "click" (Decode.map CanvasClick Mouse.position)


onCircleMouseDown : Int -> Svg.Attribute Msg
onCircleMouseDown id =
    SvgEvent.on "mousedown" (Decode.map (\position -> DragStart position id) Mouse.position)
