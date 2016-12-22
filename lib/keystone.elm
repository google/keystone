port module Keystone exposing (..)

import Html exposing (..)
import Html.Attributes as Att exposing (..)
import Model as Mdl
import List
import Dict
import Tuple exposing (first)


type alias UiModel =
    { sysModel : Maybe Mdl.Model }


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
    ( { sysModel = Nothing
      }
    , Cmd.none
    )


type alias Notification =
    { text : String
    , isErr : Bool
    , isSuccess : Bool
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
update msg uiModel =
    case msg of
        Reset ->
            ( uiModel, Cmd.none )

        Parse isMd text ->
            let
                container =
                    if isMd then
                        Mdl.Markdown
                    else
                        Mdl.Raw

                parseResult =
                    Mdl.parse container text

                newModel =
                    case parseResult of
                        Ok m ->
                            Just m

                        Err e ->
                            Nothing

                resultMessage =
                    case parseResult of
                        Ok m ->
                            { isErr = False
                            , isSuccess = True
                            , text = "Parse successful"
                            }

                        Err e ->
                            { isErr = True
                            , isSuccess = False
                            , text = e
                            }
            in
                ( { uiModel | sysModel = newModel }, notify resultMessage )


find : a -> List a -> Bool
find n ns =
    List.any (\x -> x == n) ns


rowIdentifier : String -> List String -> Int
rowIdentifier n ns =
    let
        findIndex x ( i, found ) =
            if x /= n && not found then
                ( i + 1, False )
            else
                ( i, True )
    in
        first <| List.foldl findIndex ( 0, False ) ns


dsmHeaders : Mdl.Model -> Html msg
dsmHeaders model =
    let
        connections =
            Mdl.connections model

        names =
            Dict.keys connections
    in
        tr [ class "keystone dsm-header" ] <|
            List.append [ th [] [ text "Name" ], th [] [ text "#" ] ]
                (List.map
                    (\n -> th [] [ text <| toString <| rowIdentifier n names ])
                    names
                )


dsmRows : Mdl.Model -> List (Html Msg)
dsmRows model =
    let
        connections =
            Mdl.connections model

        names =
            Dict.keys connections

        toRow ( rowName, rowDeps ) =
            tr [ class "dsm-row" ] <|
                List.append
                    [ td [ class "dsm-row-label" ] [ text rowName ]
                    , td [ class "dsm-row-number" ]
                        [ text <| toString <| rowIdentifier rowName names
                        ]
                    ]
                <|
                    List.map
                        (\n ->
                            if find n rowDeps then
                                td
                                    [ class "dsm-dep-link"
                                    , title <| rowName ++ " depends on " ++ n
                                    ]
                                    [ text "X" ]
                            else if n == rowName then
                                td [ class "dsm-self-link" ] [ text "X" ]
                            else
                                td [] []
                        )
                        names
    in
        List.map toRow (Dict.toList connections)


generateDsm : Maybe Mdl.Model -> Html Msg
generateDsm m =
    case m of
        Just model ->
            div []
                [ table [ id "keystone-dsm", class "keystone dsm" ]
                    (dsmHeaders model :: dsmRows model)
                ]

        Nothing ->
            ul [ class "background-message centered" ]
                [ li [] [ text "No model to render" ] ]


view : UiModel -> Html Msg
view model =
    div [ id "keystone-main" ]
        [ h1 [] [ text "Keystone: DSM View" ]
        , text """This view displays connections between model elements.
           An 'X' denotes a connection, where the component in the row depends
           on the component in the column."""
        , generateDsm model.sysModel
        ]
