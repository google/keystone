module Keystone exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes as Att exposing (..)
-- import Html.Events exposing (onClick, onInput, onCheck)
-- import String


main : Program Never
main =
  Html.program
   { init = init
   , view = view
   , update = update
   , subscriptions = subscriptions}

init : (Model, Cmd Msg)
init =
   ( Model , Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


type alias Model = { }


type Msg = Reset

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Reset -> (model, Cmd.none)


view : Model -> Html Msg
view model =
    div [ id "main", class "col-lg-6" ] [ text "Keystone! Yeah!" ]
