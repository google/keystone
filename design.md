# Keystone - Design Overview

This document describes the overall design of Keystone, and is intended as a
guide for contributors.

## Models

Keystone's core use case is the construction of models describing a software
architecture. Models are constructed using a domain specific language which
Keystone reads to generate visualizations and run simulations.

### Model Language

Models are represented as text in the modeling DSL. The language supports
designing with **components**, **systems**, and **channels**.

+ A **component** is an atomic black box, and forms the fundamental unit of
behavior.

+ A **system** is an aggregation of components and other systems which
together can be treated as a unit.

+ **Channels** connect components together, enabling them to pass messages.

### Internal Representation

When a user wishes to visualize the model or run a simulation, the model
description is parsed into an internal representation.

**TODO: Describe the model representation**

## Visualization & Rendering

Parsed models can be rendered into a variety of formats to visually analyze
their properties. Currently, these formats are on the road map:

+ Design Structure Matrix (DSM) - Displays connections between components and
systems to reveal dependencies and enable modularization.

+ Sequence Diagram - Displays the chain of events performed in a simulation
scenario.

## Simulations

**TODO: Describe how simulations work**

+ Scenario description
  + Set up
  + Behavior description
  + Sensors
+ Result output

## Atom Integration

Keystone is integrated into the Atom editor. Atom provides an HTML-based
rendering engine for Keystone which is used for output display, as well as a
robust text editor and Javascript engine which are used for input and
processing, respectively.

**TODO: Describe how Keystone is embedded in Atom**
