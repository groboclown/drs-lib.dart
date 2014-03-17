Copies children of Pragma when the parent is copied.  This pattern is closely
related to the [Back Link Pattern](Back-Link-Pattern.md).

If one Pragma is copied, and it has direct child Pragma, then the child Pragma
should be copied with it.  However, there is no direct copy signal, so we must
simulate it.

The owning Pragma defines an attribute on the link to the child, called
"isChild", and assigns it to 0.5.  It also binds an Action on that attribute.
When the attribute is first added to the child, the value is 0.5, so the Action
sets it to 1.0 and quits.  When the owning Pragma is copied, that attribute is
copied onto the destination Pragma, which causes the attribute to change (from
null to 1.0), which triggers the Action.  The Action then notices the isChild
== 1.0, so performs a copy of the linked-to child into the new destination
Pragma.

Because of the copy semantics, when the destination Pragma is copied, the
linked-to child will continue to point to the original object's child Pragma.
The bound Action will use this to create a copy of that child Pragma, then
replace the link reference to the new child.

This can be applied to a [[back link|Back Link Pattern]], and is the way a
listener to child copy behavior can be constructed.  Delete and change behavior
is different -- it requires adding a bound Action on a Pragma Handle to the
linked-to child, along with the "isChild" checked state to ensure the
initialization state doesn't trigger a change event.
