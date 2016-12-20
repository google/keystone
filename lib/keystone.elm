port module Keystone exposing (..)

import Html exposing (..)
import Html.Attributes as Att exposing (..)
import Model as Mdl


type alias UiModel =
    {}


type Msg
    = Reset
    | Parse Bool String


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


type alias Notification =
    { text : String
    , isErr : Bool
    }


{-|
   Send a notification to the user.
-}
port notify : Notification -> Cmd msg


{-|
   Request a parse of the given string, generally buffer text from Atom.
-}
port parse : (( Bool, String ) -> msg) -> Sub msg


subscriptions : UiModel -> Sub Msg
subscriptions model =
    parse (\( isMd, text ) -> Parse isMd text)


update : Msg -> UiModel -> ( UiModel, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            ( model, Cmd.none )

        Parse isMd text ->
            let
                container =
                    if isMd then
                        Mdl.Markdown
                    else
                        Mdl.Raw

                parseResult =
                    case Mdl.parse container text of
                        Ok m ->
                            { isErr = False
                            , text = "Parse result: " ++ toString m
                            }

                        Err e ->
                            { isErr = True
                            , text = e
                            }
            in
                ( model, notify parseResult )



-- TODO Implement this


view : UiModel -> Html Msg
view model =
    div [ id "main", class "col-lg-6" ] [ text "Keystone! Yeah!" ]
