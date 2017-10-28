module Messages exposing (..)

import Mouse exposing (Position)
import Models exposing (Id, Mode)


-- Message


type Msg
    = Flip
    | CanvasClick Mouse.Position
    | DragStart Position Id
    | DragAt Position
    | DragEnd Position
    | ConnectOn Id
    | ConnectOff
