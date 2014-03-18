
A Function performs a discrete action over values.


## Form of Functions

The function takes one of these forms:

 * Run a built in function
 * Run a series of "simple" operations over the input data values.
 * Use some "simple" operations from within "built-in" list operations.





### Built In Functions

The built-in functions are there to allow for the generation of new special
values (PragmaHandle, AttributeHandle) while restricting the use of the
generated value (because a function CANNOT generate a value then operate
on that generated value).

The built-in functions are:

 * bind a PragmaHandle to an AttributeId to generate an AttributeHandle
    (`bindAttribute`)
 * bind a PragmaHandle to a LinkId to generate a PragmaHandle
    (`bindPragma`)

These can be combined with the `map` list operation to bind a list of
PragmaHandle to AttributeIds or LinkIds, or a list of AttributeIds or LinkIds
to a PragmaHandle.


    location <= bindPragma(this, "Location"),
    locationName <= bindPragma(location, "name")


### List Operations

For functions that need to operate on a List, some additional tools are
available.

#### foreach

The `foreach` operator runs "simple" operations over each element in the list.
This operator allows for pre- and post-operations, so that algorithms such as
average can work as expected.

    def averageValue : num <= foreach(
        // input variables into this function; the first one is the list that
        // is iterated over
        (List<num> values[val])

        // shared variables across the operations.
        (num count, num sum)

        // pre-loop
        {
          count = 0;
          sum = 0;
        }

        // for each value "val"
        {
          count++;
          sum += val;
        }

        // post-loop; must return a value.
        {
          return (count <= 0 ? 0 : sum / count);
        }
    )


#### map

For operations that perform "simple" operations on each member of the list
independent of each each other, use the `map` operator.  This allows for high
performance computations.  These functions can only work if the output value is
a List.

    def angleCalculations : List<num> <= map(
        // input variables into this function; the first value must be the
        // set that is iterated over.
        (List<num> values[val], num angle)

        // shared variables across the operations.  After the initializer
        // finishes, these values are copied to each call (modifications are
        // not shared).
        (num angle_calc)

        // pre-loop setup
        {
          angle_calc = sin(angle * PI / sqrt(2));
        }

        // per-value loop; must return a value
        {
          return val * angle_calc;
        }
    )

To combine a `map` with a built-in function, specify the function in the
per-value loop:

    def mapToAttributes : List<AttributeHandle> <= map(
        (List<PragmaHandle> handles[handle], AttributeId attr)
        () {}
        bindAttribute(handle, attr)
    )

#### iterate

For operations which perform "simple" operations on each member of the list,
but are dependent upon the previous value, use the "iterate" operator.  While
not as performant as the "map" operator, it does allow for limited
engine optimizations.  These functions can only work if the output value is
a List.

    def sumOfParts : Set <= iterate(
        // input variables into this function
        (List<num> values[val], num startValue, num maximumValue)

        // shared variables across the operations
        (num previous)

        // pre-loop
        {
          previous = startValue;
        }

        // loop; *may* return a value; if it doesn't return a value, then
        // there is no corresponding value in the output list.
        {
          previous += val;
          if (previous > maximumValue) {
            previous = startValue;
          } else {
            return previous;
          }
        }
    )

