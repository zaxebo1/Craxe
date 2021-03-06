# Warning. Just an experiment. Lot of bugs!!!

## Transpiler from haxe to nim (http://nim-lang.org/)

## The main goal for now is:
* High performance.
* Low memory footprint.
* Stable garbage collector, or maybe no GC at all (owned/unowned ref).
* Async IO: Files, TCP, UDP, HTTP, HTTPS, Websockets.

## What it's all good for?

Backend, micro services, iot, calculations, haxe compiler :)

## Why not go, rust, D and other languages?

Because.

## What it can do:

* Classes: 
    - inheritance
    - constructors
    - super call
    - static and instance methods
    - instance fields
* Interfaces
* Typedefs
* Anonymous
* Basic types: 
    - Int
    - Float
    - String
    - Bool
    - Generic Array<T>
    - IntMap, StringMap, ObjectMap
* Enums and ADT
* Abstracts and enum abstracts
* Generics
* GADTs
* Expressions: 
    - for
    - while
    - if
    - switch
* Closures
* Externs
* Basic file reading by File.getContent
* haxe.Json
* Stdin output by trace

## How to use it

* Install lix packet manager https://github.com/lix-pm/lix.client
* Install nim compiler with https://github.com/dom96/choosenim
* Install craxecore library by "nimble install https://github.com/RapidFingers/Craxe?subdir=core"
* Create lix project
* Select haxe 4.0.0-rc3 compiler
* Add craxe library with lix from github https://github.com/RapidFingers/Craxe
* Add build.hxml with following strings:\
-cp src\
--macro craxe.Generator.generate()\
--no-output\
-lib craxe\
-main Main\
-D nim\
-D nim-out=main.nim
* Add some simple code to Main.hx
* Launch "haxe build.hxml"\
It will generate code and will launch the nim compiler\
"nim c -d:release filename.nim"

## Examples

https://github.com/RapidFingers/CraxeExamples

## Roadmap

- [x] Switch expression
- [x] Inheritance
- [x] Interfaces
- [x] BrainF**k benchmark
- [x] Basic externs implementation
- [x] Closures
- [x] Typedefs
- [x] Anonymous
- [x] Abstracts
- [x] Enum abstracts
- [x] Generics
- [x] GADT
- [x] Map/Dictionary
- [x] Method override
- [x] Place all nim code to nimble library
- [x] Extern for CraxeCore's http server
- [x] Benchmark of async http server
- [x] Possibility to add raw nim code
- [x] Dynamic type
- [x] haxe.Json
- [ ] Extern for native nim iterators
- [ ] Mysql database driver
- [ ] Craxe http server benchmark with json and mysql
- [ ] Dynamic method
- [ ] Try/Catch
- [ ] Reflection
- [ ] Auto import nimble libs
- [ ] Craxe console util for setup, create project, etc
- [ ] Type checking (operator is)
- [ ] Async/Await
- [ ] Some kind of std lib
