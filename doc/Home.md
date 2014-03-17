# Discrete Reactive Simulation Library for Dart

An engine and support tools for constructing a dynamic, discrete time simulation
using a [Fuzzy Cognitive Map](http://en.wikipedia.org/wiki/Fuzzy_cognitive_map)
with borrowed elements from the [Actor Model](http://en.wikipedia.org/wiki/Actor_model).

This simulation engine aims to provide a framework to constructing emergent
behavior for virtual worlds, but the engine itself isn't limited to those
applications.


## Getting Started

Because the project is still pre-Alpha, there's no working code yet.  You can
read up on the [Architecture](Architecture.md) to see the gritty details.


## Further Reading

[The roadmap](Roadmap.md) will tell you where the project is at, and where it
aims to be.

[The simulation architecture](Architecture.md) has the deep details for how the
low-level engine works.

The section on [Patterns](Patterns.md) details higher level structures built on
top of the [Architecture](Architecture.md).


## Pluggable and Upgradable

The model used by the simulation engine natively supports adding "plug-in"
behavior and upgrading with fixes to existing simulations.


## The Engine In Action

[The engine works](Engine-Algorithm.md) in cycles, each cycle representing one
discrete time interval.  Each cycle performs the following operations:

1. All pending [Actions](Action.md) execute.  These may update
 [values](Attribute.md), create and delete [Pragmas](Pragma.md), and update
 [Links](Link.md) between [Pragmas](Pragma.md).
2. These updates signal [Functions as Values](Function.md) to run, and signal
 [Actions](Action.md) bound to altered values to queue for execution in the next
 cycle.

These basic steps allow for very complicated behaviors to build upon each other.

