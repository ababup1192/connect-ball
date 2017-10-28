module View exposing (view)

import Dict exposing (Dict)
import Messages exposing (..)
import Mouse exposing (Position)
import Models exposing (Model, Mode)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Svg exposing (Svg)
import Svg.Attributes as SvgAttr
import Svg.Events as SvgEvent
import Json.Decode as Json


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
canvas model =
    Svg.svg [ SvgAttr.viewBox "0 0 700 500", onCanvasClick ] <|
        (drawCircles model)
            ++ (drawDragLines model)
            ++ (drawLines model)


drawLines : Model -> List (Svg Msg)
drawLines { lines, points } =
    List.map
        (\line ->
            let
                mFromPosition =
                    Dict.get line.from points

                mToPosition =
                    Dict.get line.to points
            in
                case ( mFromPosition, mToPosition ) of
                    ( Just fromPosition, Just toPosition ) ->
                        Svg.line
                            [ SvgAttr.strokeWidth "1"
                            , SvgAttr.stroke "black"
                            , SvgAttr.x1 <| toString (fromPosition.x - 20)
                            , SvgAttr.y1 <| toString (fromPosition.y - 55)
                            , SvgAttr.x2 <| toString (toPosition.x - 20)
                            , SvgAttr.y2 <| toString (toPosition.y - 55)
                            ]
                            []

                    ( _, _ ) ->
                        Debug.crash "id not found"
        )
        lines


drawDragLines : Model -> List (Svg Msg)
drawDragLines ({ drag, mode } as model) =
    case ( drag, mode ) of
        ( Just { start, current }, Models.Connect ) ->
            let
                position =
                    dragPosition model

                dx =
                    toString <| position.x - 20

                dy =
                    toString <| position.y - 55
            in
                [ Svg.line
                    [ SvgAttr.strokeWidth "1"
                    , SvgAttr.stroke "black"
                    , SvgAttr.x1 <| toString (start.x - 20)
                    , SvgAttr.y1 <| toString (start.y - 55)
                    , SvgAttr.x2 dx
                    , SvgAttr.y2 dy
                    ]
                    []
                ]

        _ ->
            []


drawCircles : Model -> List (Svg Msg)
drawCircles ({ points, drag, mode } as model) =
    List.map
        (\( id, position ) ->
            let
                xy =
                    case ( drag, mode ) of
                        ( Just drag, Models.New ) ->
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
                Svg.circle
                    [ SvgAttr.class "circle"
                    , SvgAttr.cx <| cx
                    , SvgAttr.cy <| cy
                    , SvgAttr.r "10"
                    , SvgAttr.fill "#0B79CE"
                    , onCircleMouseDown id
                    , onCircleMouseOver id
                    , onCircleMouseOut
                    ]
                    []
        )
        (Dict.toList points)


dragPosition : Model -> Position
dragPosition ({ drag, points } as model) =
    case drag of
        Just { id } ->
            let
                position =
                    case (Dict.get id points) of
                        Just position ->
                            position

                        Nothing ->
                            Debug.crash "id not found"
            in
                getPosition model id

        Nothing ->
            Debug.crash "drag not found"


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
    SvgEvent.on "click" (Json.map CanvasClick Mouse.position)


onCircleMouseDown : Int -> Svg.Attribute Msg
onCircleMouseDown id =
    SvgEvent.on "mousedown" (Json.map (\position -> DragStart position id) Mouse.position)


onCircleMouseOver : Int -> Svg.Attribute Msg
onCircleMouseOver id =
    SvgEvent.on "mouseover"
        (Json.map (\position -> ConnectOn id) Mouse.position)


onCircleMouseOut : Svg.Attribute Msg
onCircleMouseOut =
    SvgEvent.on "mouseout" <| Json.succeed ConnectOff
