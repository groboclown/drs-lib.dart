

If we define global ALL_ATTRIBUTE_ID and ALL_LINK_ID sets, then this is
just a matter of defining two functions:

    func getPragmaLinks(PragmaHandle p, PragmaLinkSet links) : PragmaHandleSet
        yield link in links: p.bindToPragma(link)

    func getExistingPragma(PragmaHandleSet phs) : PragmaHandleSet
        yield handle in phs: handle : where handle.exists

The grab-all would be:

    @allLinks: getPragmaLinks => (self, ALL_LINK_IDS)
    @existingLinks: getExistingPragma => (@allLinks)

If the list of link names changes, the pragma list output potentially changes.
If the link-to object is added or removed, then the output of the
`getExistingPragma` function changes.  If the linked-to object points to
a different value, then the bindTo returns a different value, causing the
getPragmaLinks to return a different list.

