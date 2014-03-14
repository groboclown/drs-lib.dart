A Template is a [[Pragma]] which the engine uses to populate other [[Pragma]] instances. Any [[Pragma]] can be used as a Template (which is how "strong copies" are made).

Most Templates, however, possess special wiring to allow for signaling [[Actions|Action]] on the destination [[Pragma]] after construction.


## Uses

These are the different use cases I've come up with, in relative priority order:

1. Populate a new Pragma with some data to allow easy "cookie cutter" copies of similar objects. This is modeling the "class" concept.

2. Allow updating existing Pragma objects with new functionality from a new plugin added into the simulation. The plugin would have [[matchers|Matcher Pattern]] to determine which Pragma to update with what values, and it needs to know whether to override the existing value or keep the existing value or use some combination of them.

3. Add new behavior to an existing Pragma based on a state change.  For example, a wooden doll comes to live with a magic spell, causing it to now become an active member of the simulation. The Pragma itself didn't change, and there's no need to go through the hassle of reconnecting all the links.

4. Create a copy of an existing Pragma, so that concepts like, "split a pile of 37,656 leaves into 2 piles" can be trivial to solve.


## Invocation

The invocation to perform the copy takes an optional Pragma that defines the list of attributes to copy by value (creating hard links). This allows for a two-pass copy to perform the necessary actions; the first is copying a "filter" pragma that has a link to the original object, and all the additional function linking via values, and the second is copying the filter pragma onto the destination. The original will need to be a weak "predictive" copy, to make sure it retains the original values. For a full copy to take place would require multiple runs through the computation chain within a single cycle.


## Templates as Classes and Mixins

A Template can be used to have similar functionality to a Class or Mixin concept. The Template provides data fields (default Attributes) and methods (Actions and Functions) for the new instance.

The _convention_ to using Templates which require a programmatic behavior uses an Attribute ("AddedTemplates") - a set of Strings - which contains all the global IDs of the Templates which copied themselves into the [[Pragma]], and they add a bound Action to that Attribute that performs the initialization when it changes value, which will always be triggered after copying in a Template. The initializer should remove itself at the end of the action to ensure another Template copy doesn't trigger it again.


## Plugin vs. Patching

Templates also allow for installing extensions and patches into an existing simulation. A Plugin package refers to a bundle that contains new behaviours or additional interactions to the simulation. A Patch refers to updates to existing interactions and behaviours to remove issues or enhance existing functionality.

