{-
   Copyright 2016 Google Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-}


port module Main exposing (..)

import Test.Runner.Node exposing (run, TestProgram)
import Tests
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit Tests.all


port emit : ( String, Value ) -> Cmd msg
