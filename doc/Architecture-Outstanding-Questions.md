The following details are still being worked out.


## Commit Conflicts

The "commit join" function for Attributes has a solid plan. The function
accepts 3 arguments: attribute handle, the original value, and a lazy list
containing the child context values as they are computed. However, there's a
hard problem around handling conflicts in removed / added / etc Links. Newly
created Pragma are handled gracefully because they are assigned a globally
unique ID. Deleted Pragma can cause a conflict, though. Unfortunately, a delete
is hard to manage because sets cannot contain null values.

What if we think of Links as just another Attribute? It will have a special
nomenclature for describing the name so that they don't conflict with any
Attribute ID. In this case, a commit join function can be given to a link
(remember - adding and removing links is the exact same thing as changing a
link).

The "commit join" function may need some fine tuning. There could be cases
(TODO discover some so that they can be analyzed) where a function may need
external data to make a correct decision. For now, though, I have a strong
suspicion that it can be alleviated through well defined actions.

- - -

## Action Scope

The range of values available to an Action during its execution is currently not
well defined. The running concept is "everything", but it usually should require
inputs, or at the very least an event source. Some signals may pertain to
multiple Pragma, so encompassing these differences in needs is tricky.

If these are more limited than "everything", than true parallel computations
can be made more feasible, because only the affected state need be sent to other
computing memory, changing subtly the mechanics of the "weak copy". This model
doesn't provide for Locality, which introduces this issue.


- - -

## Sets and Functions

If a Set contains any values that change, or if the number of elements in the
Set changes, then the Set generates a change signal.

However, there is a limited use case where some [Functions](Function.md) operate
on a per-item basis in the Set, and does not use multiple items together (i.e.
mapping a Link ID to a Link Handle).  In this really special case, the item in
the Set can signal directly to the corresponding item in the output Set, so that
the Function need not run against all the items in the set again.  Likewise, an
added item into the set would have the Function run just for that one item, and
a removed item would have the corresponding element removed from the output set.

This would require a really special functionality in the engine, essentially it
would create a wrapper function around a simple user-defined function.  The
Function could take only one Set argument and multiple value arguments - a
change in the value would require rerunning the Function against all the
elements in the Set.

Another method would be to have a distinct set of function patterns which can
be implemented.  One such pattern is a per-item functionality, with constraints
that no data is shared between the computation of the individual elements.  This
is what's currently documented and planned.

- - -

