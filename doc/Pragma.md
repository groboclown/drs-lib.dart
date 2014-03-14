Pragma offer a central repository for data values and references to other Pragma, while allowing relative IDs to reference the values and Pragma references.  That's a fancy way of saying that Pragma contain [[Attributes|Attribute]] that have an ID and value, and they contain [[Link Mappings|Link]] to Pragma.  In addition to this, each Pragma has a globally unique identifier. Also, Pragma can have [[Actions|Action]] bound to change signals on Attributes of the Pragma.

The system acts as though Pragma have all [[Attributes]] and [[Links]] defined for them, defaulting to [[null values|Value Type#wiki-null-values]]. This allows references to not-existing or undefined values to work if a future [[Action]] defines them.


## Links

_Main document: [[Link]]._

A Pragma contains a list of generic IDs bound to Pragma global IDs, in the form of a mapping. By having a generic Link ID and a Pragma, a [[Function]] or [[Action]] may retrieve the referenced Pragma.

By having this generic ID mapping, a system can construct a name, such as "inside", that can be used for all Pragma to define a concept.

Links in a Pragma may themselves have Attributes. These are actually stored in the owning Pragma as an Attribute, and as such are globally unique IDs binding a generic Link ID to the link-specific Attribute ID.


## Commit Memory Model

Due to the simulation engine running in discrete cycles, as well as changes to values performed only by Actions, the memory model works by creating a "Weak Copy" of Pragma on which an Action performs changes, and resolves the changes after the [[Actions|Action]] complete their work by committing back to the original Pragma.

Weak Copies of Pragma created for Actions schedule themselves to commit changes to their [[Attributes|Attribute]] back to the original Pragma on a per-[[Attribute]] basis, allowing for heavy parallelization. The commit uses the Join Commit function on the Attribute to determine how to resolve differences if multiple Actions update the same attribute value.

Because an [[Action]] can act upon more than one object, all these changes to Pragma made by the action are stored in a context. A context is a weak copy of the entire parent context, so that it maintains a list of only the values that have changed within the child context.

Signals to Actions bound to Pragma in a context would act upon that weak copy of the Pragma. Pragma Links can reference any Pragma in context, so that "what-if" values can be pulled in. Pragma Links can only reference child contexts, so that a strict tree structure is maintained. This, a context is its own little simulation within a simulation.

With this predictive analysis design, we could potentially shape the commit model to use it. When an Action runs, it runs in its own child context. New Pragma are created in the child context, and alterations are kept inside the child. When the Action finishes, the context is committed back to the parent. This technique allows for the highly parallel execution of Actions.

In the future, the engine might also allow for special handling for serialized actions, in which case a task scheduling scheme can be constructed as well. The string of Actions creates levels of contexts in which parallel Actions create their children, and those are committed into the parallel context before the next serial action happens.

Commits from a context back to the parent occur on an Attribute-by-Attribute basis. Each Attribute has a "commit join" function that accepts 3 arguments: attribute handle, the original value, and a lazy list containing the child context values as they are computed. However, there's a hard problem around handling conflicts in removed / added / etc Links. Newly created Pragma are handled gracefully because they are assigned a globally unique ID. Deleted Pragma can cause a conflict, though. Unfortunately, a delete is hard to manage because sets cannot contain null values (see [[Architecture Outstanding Questions]] for current issues).


## Pragma Creation

An [[Action]] can create a new Pragma that contains only default values for Links and Attributes. The simulation engine creates this Pragma with a globally unique ID, based on a suggested name from the calling [[Action]].

Due to the Commit memory model, the engine can create and make the new Pragma available immediately, because no bound Attributes or Links to it exist. Likewise, within the context of the calling Action, additional Links and Attributes can be added to it immediately.


## Cloning

Creates a full new copy of an existing Pragma. This includes correct duplication of the back links and a unique ID. This allows for cloning existing objects for permanent storage in the system.

The "clone" operation is only allowed inside an Action. The operation takes several arguments to alter the behavior of the clone:

* **as defaults** - a flag that, if set, will not change a value in the destination if it is already non-null.
* **filter** - a set of Attribute IDs and Link IDs, which limits which attributes and links are copied.

Because of the way the commit works for memory integrity, a Strong Copy of a Pragma has no commit phase into the system. The system adds it directly into the system, giving it a globally unique ID (possibly with a suggestion from the user).

See [[Architecture Outstanding Questions]] for issues around notifications that a link was copied, as this is useful for a parent to maintain relationships.
