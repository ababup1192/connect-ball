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


type alias Line =
    { from : Id, to : Id }



-- Model


type alias Model =
    { points : Dict Id Position
    , mode : Mode
    , drag : Maybe Drag
    , to : Maybe Id
    , nextId : Id
    , lines : List Line
    }


initialModel : Model
initialModel =
    { points = Dict.empty
    , lines = []
    , mode = New
    , to = Nothing
    , drag = Nothing
    , nextId = 1
    }
