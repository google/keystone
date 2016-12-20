module Tests exposing (all)

import Test exposing (..)
import Expect
import Model exposing (..)
import Combine exposing (..)
import String


all : Test
all =
    describe "keystone" [ parsing ]


isErr : Result s t -> Bool
isErr r =
    case r of
        Ok _ ->
            False

        Err _ ->
            True


doParse : Parser BlockName t -> String -> Result String t
doParse p i =
    case runParser p "<test>" i of
        Ok ( _, stream, result ) ->
            Ok result

        Err ( _, stream, errors ) ->
            let
                location =
                    (currentLocation stream)
            in
                Err
                    ((String.join ", " errors)
                        ++ " at line "
                        ++ toString location.line
                        ++ ": "
                        ++ location.source
                    )


parsing : Test
parsing =
    describe "parsing"
        [ test "components can be parsed" <|
            \() ->
                Expect.equal (Ok (DComponent "TestComp" []))
                    (doParse
                        component
                        "component TestComp is\nend TestComp;"
                    )
        , test "interfaces can be parsed" <|
            \() ->
                Expect.equal (Ok (DInterface "TestIface"))
                    (doParse
                        interface
                        "interface TestIface is\nend TestIface;"
                    )
        , test "basic systems can be parsed" <|
            \() ->
                Expect.equal (Ok (DSystem "TestSys" []))
                    (doParse
                        system
                        "system TestSys is\n\nend TestSys;"
                    )
        , test "composite systems can be parsed" <|
            \() ->
                Expect.equal
                    (Ok
                        (DSystem "TestSys"
                            [ (SInstance "PartA" "TestComponentA")
                            , (SInstance "PartB" "TestComponentB")
                            , (SConnect "PartA" "PartB" "TestChan")
                            ]
                        )
                    )
                    (doParse
                        system
                        """system TestSys is
                          PartA: TestComponentA;
                          PartB: TestComponentB;
                          connect PartA to PartB via TestChan;
                        end TestSys;"""
                    )
        , test "blocks must start and end with the same name" <|
            \() ->
                (doParse system "system BadSys is\nend SysBad;")
                    |> isErr
                    |> Expect.true "Expected syntax error"
        , test "comments are recognized" <|
            \() ->
                Expect.equal (Ok "endtest")
                    (doParse (comment *> whitespace *> string "endtest")
                        """-- I'm a comment!
                           endtest"""
                    )
        , test "skippables are recognized" <|
            \() ->
                Expect.equal (Ok "endtest")
                    (doParse (skippables *> string "endtest")
                        """-- I'm a comment!


                           endtest"""
                    )
        , test "comments are skipped in blocks" <|
            \() ->
                Expect.equal (Ok (DInterface "TestIface"))
                    (doParse
                        block
                        """

                        -- This is a comment!
                        interface TestIface is

                          -- This is an inline comment!
                        end TestIface;


                        """
                    )
        , test "models can be embedded in Markdown" <|
            \() ->
                Expect.equal (Ok ([ DInterface "TestIface" ]))
                    (doParse
                        markdownModel
                        """
                        # Markdown test
                        This model is embedded in a Markdown file.

                        ```keystone
                        -- This is a comment!
                        interface TestIface is

                          -- This is an inline comment!
                        end TestIface;
                        ```

                        This is the end of the model.
                        """
                    )
        ]
