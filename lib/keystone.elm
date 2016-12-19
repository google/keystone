port module Keystone exposing (..)

import Html exposing (..)
import Html.Attributes as Att exposing (..)
import Model as Mdl exposing (..)


main : Program Never UiModel Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( UiModel, Cmd Msg )
init =
    ( UiModel, Cmd.none )


{-|
   Send a notification to the user.
-}
port notify : String -> Cmd msg


{-|
   Request a parse of the given string, generally buffer text from Atom.
-}
port parse : (String -> msg) -> Sub msg


subscriptions : UiModel -> Sub Msg
subscriptions model =
    parse Parse


type alias UiModel =
    {}


type Msg
    = Reset
    | Parse String


update : Msg -> UiModel -> ( UiModel, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            ( model, Cmd.none )

        Parse text ->
            ( model, notify text )



-- TODO Implement this


view : UiModel -> Html Msg
view model =
    div [ id "main", class "col-lg-6" ] [ text "Keystone! Yeah!" ]
