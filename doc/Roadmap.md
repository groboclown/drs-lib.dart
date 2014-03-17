# Where We're Headed

## Phase 1 (In Progress)

1. Complete version 1 of the engine [[Architecture]].  This can still have open questions for the more advanced areas, but the primary concepts should be completely documented in this wiki.
2. Create an initial version of the simulation engine that does not include signaling actions.  This means that it only needs to deal with signaling between Functions, and dealing with Actions queued from outside behaviors.
3. Create a rudimentary UI for viewing the Pragma, Attributes and Links for the simulation.  Also, allow for stepping through the individual calls to Functions during execution.  This implies that the engine needs to allow for creating hooks into the stepping process which can potentially block the execution.
4. Create a simple simulation environment to run in the engine.


**Current Status:**

1. The current architecture documentation is spread throughout a blog, hand-written notes, ~~the git-submitted docs~~ (those are now integrated over), and this wiki.  Currently migrating it into this document.  As questions arise, they will be entered into the [[Architecture Outstanding Questions]] page, rather than trying to immediately solve them.
2. An early version of the engine, using an out-dated architecture, was originally written in JavaScript.  This is slowly being converted over to Dart to make sure that it does what we want.
3. The early version of the engine had one of these, but it wasn't very good.  It didn't allow for stepping.
4. The early version also had an environment.  This will need to be reworked.


## Phase 2 (Planning)

1. Create an import/export language to make the creation and backups of the simulation environments easy.
2. Extrapolate patterns of function assembly, and turn these into representations in the import language.  Export probably won't export into these patterns without lots of stored meta-data.


## Phase 3 (Planning)

1. Add action binding and signaling to the engine and the export/import file format.
2. Add user defined actions.


## Phase 4 (Planning)

1. Construct a higher-level language based on the patterns for defining functions + value bindings, and actions.