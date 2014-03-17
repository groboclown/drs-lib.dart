A "back link" allows for representing the relationship where one object owns
another, and that owned object knows about its owner.  For example, a Bag has a
list of all its contents, and each content has a reference to which bag it sits
in.

These allow the creation of an undirected connection between Pragma. However,
back links must support the concept of an owning end in order to have a central
place that controls the lifecycle of the bi-directional link.

# Implementation

This uses the "deep copy" pattern to setup a "did it copy" signal on the
linked-to child.  If the owning link represents a collection of children (such
as the bag example above), then the Link ID is added to a an attribute of a set
of link IDs in the owning Pragma.

The bound copy Action A link attribute is added to the child's link that defines
the link as a child (i.e. "isChild" = 1.0).  A bound Action is set to the
"isChild" value - if the isChild value is set to null, then the link was
removed, and so the corresponding owned link should be removed.  If the
"isChild" is 1.0, then the link is now in a copy of the original child, and a
new bound link should be setup, or otherwise correctly dealt with.
