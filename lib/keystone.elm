port module Keystone exposing (..)

import Html exposing (..)
import Html.Attributes as Att exposing (..)
-- import Html.Events exposing (onClick, onInput, onCheck)
-- import String


main : Program Never Model Msg
main =
  program
   { init = init
   , view = view
   , update = update
   , subscriptions = subscriptions}

init : (Model, Cmd Msg)
init =
   (Model, Cmd.none)

port notify : String -> Cmd msg

-- Request a parse of the full input text
port parse : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
  parse Parse


type alias Model = { }


type Msg = Reset
  | Parse String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Reset -> (model, Cmd.none)
    Parse text -> (model, notify text) -- TODO Implement this


view : Model -> Html Msg
view model =
    div [ id "main", class "col-lg-6" ] [ text "Keystone! Yeah!" ]
