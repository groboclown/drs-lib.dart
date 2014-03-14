A barrier algorithm triggers an action only when _all_ of a group of values has
changed.

In this library, you can construct a barrier function by creating a a new hard
value that is initially assigned to the current value in the group.  A function
is built on top of these two that performs a "is equal" comparison, outputting
a boolean fuzzy value (0 or 1).  Then, a function value is added that has all
the "is equal" comparison outputs as inputs, and outputs the product of all the
inputs.  An action is bound to the function value that resets all the hard
values to the current value.  Additional actions can then be added on the
product function to perform the barrier action.

One-time barriers (such as "all values must be setup before a behavior can
work") add an extra layer with an action setting a value.  This, unfortunately,
adds an extra cycle before the barrier signals a change. A better implementation
will need to be constructed.
