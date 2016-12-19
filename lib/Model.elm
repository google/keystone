module Model exposing (..)

import Combine exposing (..)


comment : Parser s String
comment =
    regex "--[^\n]*"


type ModelElement
    = Channel ModelElement ModelElement
    | Component
    | System List ModelElement
