#! /bin/bash

echo "Running tests..."
elm-test

echo "Starting build..."
elm make lib/keystone.elm --output=build/keystone.js

echo "Done! Reload Atom to see your changes."
