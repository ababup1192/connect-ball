module Models exposing (..)

import Dict exposing (Dict(..))
import Mouse exposing (Position)


type alias Id =
    Int


type Mode
    = New
    | Connect


type alias Drag =
    { start : Position
    , current : Position
    , id : Id
    }



-- Model


type alias Model =
    { points : Dict Id Position
    , mode : Mode
    , drag : Maybe Drag
    , nextId : Id
    }


initialModel : Model
initialModel =
    { points = Dict.empty
    , mode = New
    , drag = Nothing
    , nextId = 1
    }
