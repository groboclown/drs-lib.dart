In the [Architecture](Architecture.md) of the simulation engine, there are three
types of Links:

* [Pragma](Pragma.md) contain generic Link IDs mapped to a globally unique
 Pragma ID.  Each connection in the Pragma from the generic ID to the other
 Pragma is called a _Link Mapping_.  Link Mappings in a Pragma may themselves
 have [Attributes](Attribute.md), which are actually stored in the owning Pragma
 as an Attribute, and as such are globally unique IDs binding a generic Link ID
 to the link-specific Attribute ID.
* The generic Link ID in in the [Pragma](Pragma.md), which is called a
 _Link ID_.  This Link ID is a specific [Value Type](Value-Type.md) to which an
 [Attribute](Attribute.md) can be assigned.  By having this generic ID mapping,
 a system can construct a name, such as "inside", that can be used for all
 [Pragma](Pragma.md) to define a concept.
* A Link Handle to a [Pragma](Pragma.md), which corresponds to a
 [Pragma](Pragma.md)'s Link Mapping with a specific generic Link ID.

Similarly, there are Attribute links, which are either the _Attribute ID_ or
the _Attribute Handle_ - the only difference being whether the Attribute ID is
bound to a [Pragma](Pragma.md) or not.

[Attributes](Attribute.md) can have have a [Value Type](Value-Type.md) of
Pragma Link ID, Pragma Handle, Attribute ID, and Attribute Handle.  The Handle
values can only be created through a special [Function](Function.md):

    {Attribute: Attribute ID="a"}------------>{Attribute: Attribute Handle}
                                                                     ^
                                                                     |
    {Attribute: Link ID="l"}-------------->{Attribute: Link Handle}--+
                                              ^
                                              |
    {Pragma "A"}--->{Link Mapping "l"->"B"}---+
                     ^
                     |
    {Pragma "B"}-----+

Here, Pragma "A" has a link mapping with Link ID "l" to Pragma "B".  Pragma "A"
has an attribute of type Pragma Link ID, with a value of Link ID "l".  An
Attribute Function takes the Link ID="l" and uses the bound Pragma "A" to
create a Link Handle, pointing now to Pragma "B".  Pragma "A" also has an
Attribute of type Attribute ID, with a value of Attribute ID "a".  An Attribute
Function takes the Attribute ID="a" and the Link Handle to Pragma "B", which
creates an Attribute Handle to attribute "a" on Pragma "B".

## Signals

The reason for so many layers of indirection to construct these Handles has to
do with each [Value Type](Value-Type.md) having a different meaning to signals
generating a change.  In the above example, if Pragma "A" changes the link
mapping "l" to instead point to Pragma "C", only the Link Handle and Attribute
Handle will signal a change.

