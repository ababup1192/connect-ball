module Messages exposing (..)

import Mouse exposing (Position)
import Models


-- Message


type Msg
    = Flip
    | CanvasClick Mouse.Position
    | DragStart Position Models.Id
    | DragAt Position
    | DragEnd Position
