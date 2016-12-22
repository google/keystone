port module Keystone exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import Model as Mdl
import List exposing (append, take, drop, head, tail, any, length)
import Dict
import Tuple exposing (first)


type alias UiModel =
    { sysModel : Maybe Mdl.Model
    , rowOrder : List String
    }


type Msg
    = Parse Bool String
    | MoveUp String
    | MoveDown String


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
      , rowOrder = []
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


split : List a -> a -> ( List a, List a )
split l a =
    let
        mh =
            head l

        mt =
            tail l
    in
        case mh of
            Nothing ->
                ( [], [] )

            Just h ->
                if h == a then
                    ( [], l )
                else
                    let
                        ( hs, ts ) =
                            split (withDefault [] mt) a
                    in
                        ( h :: hs, ts )


moveUp : List a -> a -> List a
moveUp l e =
    let
        ( before, after ) =
            split l e

        lb =
            length before

        newBefore =
            take (lb - 1) before

        newAfter =
            append (drop (lb - 1) before) (withDefault [] (tail after))
    in
        append newBefore <| e :: newAfter


moveDown : List a -> a -> List a
moveDown l e =
    let
        ( before, after ) =
            split l e
    in
        case after of
            [] ->
                l

            [ e ] ->
                l

            e :: n :: rs ->
                append before (n :: e :: rs)


update : Msg -> UiModel -> ( UiModel, Cmd Msg )
update msg uiModel =
    case msg of
        MoveDown name ->
            ( { uiModel | rowOrder = moveDown uiModel.rowOrder name }, Cmd.none )

        MoveUp name ->
            ( { uiModel | rowOrder = moveUp uiModel.rowOrder name }, Cmd.none )

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

                newOrder =
                    case newModel of
                        Just m ->
                            Dict.keys <| Mdl.connections m

                        Nothing ->
                            []

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
                ( { uiModel
                    | sysModel = newModel
                    , rowOrder = newOrder
                  }
                , notify resultMessage
                )


find : a -> List a -> Bool
find n ns =
    any (\x -> x == n) ns


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


dsmHeaders : Mdl.Model -> List String -> Html msg
dsmHeaders model rowOrder =
    let
        connections =
            Mdl.connections model
    in
        tr [ class "keystone dsm-header" ] <|
            append
                [ th [ colspan 2 ] [ text "Reorder" ]
                , th [] [ text "Name" ]
                , th [] [ text "#" ]
                ]
                (List.map
                    (\n -> th [] [ text <| toString <| rowIdentifier n rowOrder ])
                    rowOrder
                )


dsmRows : Mdl.Model -> List String -> List (Html Msg)
dsmRows model rowOrder =
    let
        connections =
            Mdl.connections model

        revConnections =
            Mdl.reverseConnections model

        getDeps rowName =
            ( rowName
            , withDefault [] <| Dict.get rowName connections
            , withDefault [] <| Dict.get rowName revConnections
            )

        toRow ( rowName, rowDeps, revDeps ) =
            tr [ class "dsm-row" ] <|
                append
                    [ td [ class "dsm-up-button" ]
                        [ button
                            [ class "btn icon icon-chevron-up"
                            , onClick <| MoveUp rowName
                            ]
                            []
                        ]
                    , td [ class "dsm-up-button" ]
                        [ button
                            [ class "btn icon icon-chevron-down"
                            , onClick <| MoveDown rowName
                            ]
                            []
                        ]
                    , td [ class "dsm-row-label" ] [ text rowName ]
                    , td [ class "dsm-row-number" ]
                        [ text <| toString <| rowIdentifier rowName rowOrder
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
                                    [ text "D" ]
                            else if find n revDeps then
                                td
                                    [ class "dsm-provides-link"
                                    , title <| rowName ++ " is depended on by " ++ n
                                    ]
                                    [ text "P" ]
                            else if n == rowName then
                                td [ class "dsm-self-link" ] [ text "X" ]
                            else
                                td [] []
                        )
                        rowOrder
    in
        List.map toRow <| List.map getDeps rowOrder


generateDsm : Maybe Mdl.Model -> List String -> Html Msg
generateDsm m rowOrder =
    case m of
        Just model ->
            div []
                [ table [ id "keystone-dsm", class "keystone dsm" ]
                    (dsmHeaders model rowOrder :: dsmRows model rowOrder)
                ]

        Nothing ->
            ul [ class "background-message centered" ]
                [ li [] [ text "No model to render" ] ]


view : UiModel -> Html Msg
view model =
    div [ id "keystone-main" ]
        [ h1 [] [ text "Keystone: DSM View" ]
        , text """This view displays connections between model elements.
           An 'D' denotes a dependency, where the component in the row depends
           on the component in the column. A 'P' indicates a provides
           relationship, where the component in the row fulfills a dependency of
          the row in the column."""
        , generateDsm model.sysModel model.rowOrder
        ]
