# Low Level Engine Architecture


The intention behind the current low-level engine architecture allows for
independence between the the problem construction and the execution engine.
However, some aspects of the execution engine force the higher level
architecture decisions.


## Pragma, Attributes, Links, and Link Attributes

The underlying engine defines [Pragma](Pragma.md) as merely identifiers, added
to [attribute values](Attribute.md).  [Links](Link.md) have special identifiers,
making them nothing more than a value type of Attribute.  Link Attributes, then,
are attributes associated with Links, not Pragma.

The only restriction on this is that the Attributes can only be owned by one
object.

This construction allows us to model the entire system as a set of attribute
values, and the linking of attributes to signals, with some meta-data
liberally applied.


## Schema

*NOTE: this assumes a SQL syntax.  Might look at investigating a NoSQL with this.*

The system has this schema layout:

 * **Attribute**
     * AttributeId
     * Description (source, etc)
     * Value Type (corresponds to a table name)
     * Join Commit Function Id
     * Is Set?
 * **Pragma** contains just an identifier to easily identify existence and
        uniqueness.
     * PragmaId
 * **ContextSpace**
     * ContextSpaceId
     * ParentId
 * **AttributeValue**
     * AttributeValueId
     * PragmaId
     * AttributeId
     * LinkId (null if not a link attribute)
     * SetIndex (for the value set type; will be 0 for all non-set types)
     * Is Set? (copied from the Attribute, which eliminates a join later).
     * FunctionId (null if no computation constructs this attribute)
     * SignalId (the signal that triggers this function to compute, or null
        if no computation constructs this attribute).
 * **ContextSpaceAttributeValue**
     * ContextSpaceAttributeValueId
     * ContextSpaceId
     * AttributeValueId
     * Last calculation time
     * Removed? (is this attribute removed?  used for set index values)
     * MarkedForUpdate?
 * **FuzzyValue**, **NumericValue**, **StringValue**, **AttributeIdValue**,
        **PragmaLinkValue**, **AttributeLinkValue**, **LinkValue**,
        **PragmaHandleValue**, **AttributeHandleValue**, **SetValue**
        All these tables have the
        same form, just different data value for the "value" column.
        ContextSpaceId + PragmaId + AttributeId + LinkId + SetIndex gives a
        unique value ID.  PragmaId + AttributeId + LinkId represents the
        distinct value ID.
     * ContextSpaceAttributeValueId
     * Last value
     * Pending value
 * **v_xValue** (one per type).  A view that joins the xValue table to the
    ContextSpaceAttributeValue table and AttributeValue table.  This should be
    a simple enough view that it allows writes and deletes.
 * **SignalTrigger** Links the updated Value column to the function it triggers.
     * SignalId
     * ArgumentIndex
     * AttributeValueId (value for the argument index to the function)
 * **Function**
     * FunctionId
     * Script source reference
 * **Action** registers actions to signals
     * ActionId
     * SignalId
     * FunctionId

A few of the Value tables require some additional logic to handle:

 * **SetValue** is the value for the set itself, not the individual elements
    (those are in the corresponding value list).  If the generating function
    does not act on each element independently, then the elements do not have
    a function.  TODO This also needs a way to allow signals on the entire
    set (any element changing as well as the number of elements changing).
    Sets will include an additional attribute value ("Set Size") which is what
    listeners on the changing size of the set trigger on, for those that
    only care about mapping individual indicies to others.
 * **LinkValue** - represents the "link" on a pragma.  The value here is the
    actual PragmaId it references and the name of the link.  The LinkId will
    always be null, because that column refers to the link that owns that
    attribute value, and a link cannot have a link.
 * **PragmaHandleValue** - A pragma handle has a value of a LinkValue id
    and a PragmaLinkValue, but the value that is "calculated" is the PragmaId
    that it references.  Dependent calcs will still signal off of this value,
    but the value itself must have signals constructed to update itself - that is,
    all PragmaHandleValues are calculated values.
 * **AttributeHandleValue** - Has a value of a PragmaHandleValue and an
    AttributeIdValue.  Signal handling is similar to the PragmaHandleValue.

Each context space needs to have its own view to represent the correct
inherited attributes.

    TODO show how the view is created.





## Calculation Algorithm

Actions (either external or after a cycle) update non-function values within a
ContextSpace. These updates are put into a pending list for that context space:

    -- updates are slow, rather than insert + delete
    UPDATE v_xValue SET PendingValue = {value}, MarkedForUpdate = 1
        WHERE ContextSpaceId = {contextSpaceId}
          AND PragmaId = {pragmaId}
          AND AttributeId = {attributeId}
          AND LinkId = {linkId}
          AND SetIndex = {setIndex}
          -- Or just ContextSpaceAttributeValueId

On the calculation phase of the cycle, the engine processes the pending values
by first updating the non-functional values to be calculated:

    UPDATE v_xValue SET Value = {Value}, MarkedForUpdate = 0, LastComputeTime = {time}
        WHERE ... -- FIXME

Then, it initializes the list of computed attribute values that have values that
are ready to be computed.  It looks by adding the updated values (MarkedForUpdate = 1) whose dependencies for
calculation are "ready" into the ReadyValue
table:

    TRUNCATE ReadyValue

    INSERT INTO ReadyValue
        (ContextSpaceAttributeValueId)
    ... ??? TODO finish here.  Needs to look at the SignalTrigger table, joined
    with ContextSpaceAttributeValue, for the number of attributes whose values
    are either not functions (thus ready) or


Then updating the current value
with the pending value, and then clearing out the pending value:


    -- TODO handle sets
    UPDATE xValue SET LastValue = PendingValue, MarkedForUpdate = 0,
            LastCalculationTime = {currentTime}
        WHERE MarkedForUpdate = 1

(ReadyValue includes the attribute type to eliminate an extra join against the
attribute table).  Each value in the ReadyValues collection can be calculated
immediately.

    SELECT * FROM ReadyValue

When finished calculating, the calculated value needs to be updated.

    ??? TODO fix

Then all dependencies on this value in the PendingValue
need to be checked to see if they can be moved into the ReadyValue list:

    ??? Look in the SignalTrigger list

    Original implementation:

       for each pending calculated value:
           if the pending calc value is valid, and its last calculated turn
                is < the current turn:
              for each dependency calc (dependencies that can be calculated):
                if dep is valid and its last calc turn < current turn:
                    the pending calculated value still has dependencies that
                    need to be calculated, so keep it in the pending list, and
                    continue to the next pending calculated value.
                    The code actually loops through all those dependencies and
                    ensures that they are in the pending calculation list.
           At this point, there are no dependencies pending, so the pending
           calculated value is removed from the pending calc list and added
           to the ReadyValue list.

    valid: indicates that all the dependent values are valid (meaning that
    the attributes exist).  In the new architecture, that's not possible.


    SELECT PragmaId, AttributeId, LinkId FROM SignalTrigger st
        INNER JOIN AttributeValue av ON st.???
        -- FIXME finish



then the finished calculating value needs to be removed from the ReadyValue
list:

    -- Could just have an auto-incrementing identifier, or some other
    -- single key value to make this easier.
    DELETE FROM ReadyValue
        WHERE ContextSpaceId = {}
          AND PragmaId = {}
          AND AttributeId = {}
          AND LinkId = {}
          AND SetIndex = {}
          -- Or just ContextSpaceAttributeValueId

At this point all the entries in the PendingCalc list potentially have a cycle,
or have dependent calculated values that won't be updated (we can't tell which
yet).  So we need to "break" one cycle to allow calculations to occur.  For
this, we use a heuristic to find the "best" one to break.  It should take into
account the number of dependent calcs that are pending to be calculated, number
of calcs depending on the current value, and number of calcs that the current
value depends upon.


    FIXME this is the original computation.

    var _best = null;
    var _numPendingDependencies = -1;
    var _numDependents = -1;
    var _numDependencies = -1;
    var _numVarDeps = -1;

    for ( var i = 0; i < cvList.length; i++ ) {
        var calcVal = cvList[ i ];

        var pendingDepCount = 0;
        var totalDeps = 0;
        var k = null;
        for ( k in calcVal.dependsOnCalcs ) {
            if ( calcVal.dependsOnCalcs.hasOwnProperty( k ) ) {
                if ( this._pendingCalcs
                    .indexOf( calcVal.dependsOnCalcs[ k ] ) >= 0 ) {
                    pendingDepCount++ ;
                }
                totalDeps++ ;
            }
        }
        for ( k in calcVal.dependsOnValues ) {
            if ( calcVal.dependsOnValues.hasOwnProperty( k ) ) {
                totalDeps++ ;
            }
        }
        var varDeps = totalDeps - pendingDepCount;

        // LOG.trace( "checking for break: [" + calcVal.func.name
        // + "]: pending deps: " + pendingDepCount + ", total deps: "
        // + totalDeps + ", outgoing count: " + calcVal.outgoing.length );


        if ( _best === null
            || pendingDepCount < _numPendingDependencies
            || (pendingDepCount === _numPendingDependencies && varDeps > _numVarDeps)
            || (pendingDepCount === _numPendingDependencies
                && varDeps <= _numVarDeps
                && calcVal.outgoing.length >= _numDependents && totalDeps > _numDependencies) ) {
            _best = calcVal;
            _numDependencies = totalDeps;
            _numPendingDependencies = pendingDepCount;
            _numDependents = calcVal.outgoing.length;
            _numVarDeps = varDeps;
            // LOG.trace( " - is now current best" );
        }
    }

    if ( !_best ) {
        LOG.error( "Nothing in the cv list" );
    }
    if ( _best.value === null || _best.value === undefined ) {
        LOG.verbose( "Setting initial calculated value of "
            + _best.func.name + " to 0" );
        _best.value = 0;
    }
    return _best;

