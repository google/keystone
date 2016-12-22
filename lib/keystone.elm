port module Keystone exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, colspan, title)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import Model as Mdl
import Dict
import Set
import List exposing (append, take, drop, head, tail, any, length)
import Tuple exposing (first)
import Svg exposing (svg, rect, line, circle, g, Svg)
import Svg.Attributes as SAtts
    exposing
        ( x
        , y
        , x1
        , x2
        , y1
        , y2
        , r
        , cx
        , cy
        , viewBox
        , width
        , height
        , preserveAspectRatio
        , transform
        )


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
                            , text = "Keystone model loaded successfully"
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


generateDsm : Mdl.Model -> List String -> Html Msg
generateDsm model rowOrder =
    div []
        [ table [ id "keystone-dsm", class "keystone dsm" ]
            (dsmHeaders model rowOrder :: dsmRows model rowOrder)
        ]


type HiveAxis
    = Source
    | Hub
    | Sink


hiveTransform : HiveAxis -> String
hiveTransform a =
    case a of
        Source ->
            "rotate(-120)"

        Sink ->
            "rotate(120)"

        Hub ->
            "rotate(0)"


hiveAxes : Svg Msg
hiveAxes =
    g []
        [ line [ x1 "0", y1 "0", x2 "0", y2 "-100", transform <| hiveTransform Hub ] []
        , line [ x1 "0", y1 "0", x2 "0", y2 "-100", transform <| hiveTransform Sink ] []
        , line [ x1 "0", y1 "0", x2 "0", y2 "-100", transform <| hiveTransform Source ] []
        ]


hiveNodes : Mdl.Model -> Svg Msg
hiveNodes m =
    let
        connections =
            Mdl.connections m

        revConnections =
            Mdl.reverseConnections m

        maxArity name =
            max (length (withDefault [] <| Dict.get name connections))
                (length (withDefault [] <| Dict.get name revConnections))

        getAxis name =
            if Dict.member name connections then
                if Dict.member name revConnections then
                    Hub
                else
                    Source
            else
                Sink

        getClass axis =
            case axis of
                Hub ->
                    "hive-hub"

                Source ->
                    "hive-source"

                Sink ->
                    "hive-sink"

        toNode name =
            circle
                [ cx "0"
                , cy <| toString <| (maxArity name) * -20
                , r "3"
                , transform <| hiveTransform (getAxis name)
                , SAtts.class <| getClass (getAxis name)
                ]
                [ Svg.title [] [ Svg.text name ] ]
    in
        g [] <|
            List.map
                toNode
                (Set.toList
                    (Set.union (Set.fromList (Dict.keys connections))
                        (Set.fromList (Dict.keys revConnections))
                    )
                )


generateHivePlot : Mdl.Model -> Html Msg
generateHivePlot m =
    div [ class "keystone-hive" ]
        [ Svg.svg
            [ viewBox "-120 -120 240 240"
            , preserveAspectRatio "xMinYMin meet"
            ]
            [ hiveAxes
            , hiveNodes m
            ]
        ]


view : UiModel -> Html Msg
view model =
    case model.sysModel of
        Just m ->
            div [ id "keystone-main" ]
                [ h1 [] [ text "Keystone" ]
                , h2 [] [ text "Design Structure Matrix" ]
                , text """This view displays connections between model elements.
               An 'D' denotes a dependency, where the component in the row depends
               on the component in the column. A 'P' indicates a provides
               relationship, where the component in the row fulfills a dependency of
              the row in the column."""
                , generateDsm m model.rowOrder
                , h2 [] [ text "Hive Plot" ]
                , text """A Hive Plot shows network connectivity properties more
                consistently than standard network graphs. Nodes in the graph
                are assigned to the three axes based on the arity of their
                inbound and outbound connections."""
                , generateHivePlot m
                ]

        Nothing ->
            ul [ class "background-message centered" ]
                [ li [] [ text "No model to render" ] ]
