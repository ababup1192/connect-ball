module Update exposing (..)

import Models exposing (Model, Mode(..), Drag)
import Messages exposing (..)
import Dict exposing (Dict(..))
import Mouse exposing (Position)


-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ points, mode, drag, nextId } as model) =
    let
        flipMode mode =
            case mode of
                New ->
                    Connect

                Connect ->
                    New
    in
        case msg of
            CanvasClick position ->
                canvasClick_ model position

            Flip ->
                ( { model | mode = flipMode model.mode }, Cmd.none )

            DragStart xy id ->
                ( { model | drag = Just (Drag xy xy id) }, Cmd.none )

            DragAt xy ->
                ( { model | drag = (Maybe.map (\{ start, id } -> Drag start xy id) drag) }, Cmd.none )

            DragEnd _ ->
                ( { model | drag = Nothing, points = getPoints model }, Cmd.none )


canvasClick_ : Model -> Position -> ( Model, Cmd Msg )
canvasClick_ ({ mode, drag, points, nextId } as model) { x, y } =
    case ( drag, mode ) of
        ( Just _, _ ) ->
            ( model, Cmd.none )

        ( Nothing, Connect ) ->
            ( model, Cmd.none )

        ( Nothing, New ) ->
            let
                updatedId =
                    nextId + 1

                newPosition =
                    Position x y
            in
                ( { model | points = Dict.insert nextId newPosition points, nextId = updatedId }
                , Cmd.none
                )


getPoints : Model -> Dict Int Position
getPoints { drag, points } =
    case drag of
        Nothing ->
            points

        Just { start, current, id } ->
            let
                position =
                    case (Dict.get id points) of
                        Just position ->
                            position

                        Nothing ->
                            Debug.crash "id not found"
            in
                Dict.insert
                    id
                    (Position (position.x + current.x - start.x)
                        (position.y + current.y - start.y)
                    )
                    points
