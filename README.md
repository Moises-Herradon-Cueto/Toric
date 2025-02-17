# Toric varieties in Lean

[![.github/workflows/push_master.yml](https://github.com/YaelDillies/Toric/actions/workflows/push_master.yml/badge.svg)](https://github.com/YaelDillies/Toric/actions/workflows/push_master.yml)
[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/YaelDillies/Toric)

This repository aims at formalising the theory of toric varieties.

## What is formalisation?

The purpose of this repository is to *digitise* some mathematical definitions, theorem statements and theorem proofs. Digitisation, or formalisation, is a process where the source material, typically a mathematical textbook or a PDF file is transformed into definitions in a target system consisting of a computer implementation of a logical theory (such as set theory or type theory).

### The source

The definitions, theorems and proofs in this repository are taken from *Toric varieties* by Cox, Little and Schenck.

### The target

The formal system which we are using as a target is [Lean 4](https://lean-lang.org). Lean is a dependently typed theorem prover and programming language based on the Calculus of Inductive Constructions. It is being developed at the [Lean Focused Research Organization](https://lean-fro.org) by Leonardo de Moura and his team.

Our project is backed by [mathlib](https://leanprover-community.github.io), the major classical maths library written in Lean 4.

## Content

The Lean code is located within the `Toric` folder. Within it, one can find:
* A `Mathlib` subfolder for the **prerequisites** to be upstreamed to mathlib. Lemmas that belong in an existing mathlib file `Mathlib.X` will be located in `Toric.Mathlib.X`. We aim to preserve the property that `Toric.Mathlib.X` only imports `Mathlib.X` and files of the form `Toric.Mathlib.Y` where `Mathlib.X` (transitively) imports `Mathlib.Y`. Prerequisites that do not belong in any existing mathlib file are placed in subtheory folders. See below.

See the [upstreaming dashboard](https://yaeldillies.github.io/Toric/upstreaming) for more information.

## Interacting with the project

### Getting the project

To build the Lean files of this project, you need to have a working version of Lean.
See [the installation instructions](https://leanprover-community.github.io/get_started.html) (under Regular install).
Alternatively, click on the button below to open a Gitpod workspace containing the project.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/YaelDillies/LeanAPAP)

In either case, run `lake exe cache get` and then `lake build` to build the project.

### Contributing

**This project is open to contribution**.
