# Bonfire.Data.AccessControl

See also https://bonfirenetworks.org/docs/boundaries/ for more docs (TODO: merge/deduplicate)

Bonfire has a slightly unusual way of dealing with access control.
It's not so different from role-based access control (RBAC), but we do
a few things differently and there are quite a lot of pieces to get
your head around. We'll start gently.

Bonfire has a `Verb` table containing strings like "comment" and
"delete" that represent actions a user might wish to perform. They are
a basic part of the bonfire vocabulary within the codebase.

A `Permission` is a decision about whether the action may be performed
it not. There are 3 decisions we support:

* `true` (permitted)
* `false` (explicitly not permitted, never permit)
* `null`/`nil` (not explicitly permitted)

It may seem odd to have the `null` here. We will come back to this
after we've introduced a few more pieces of the puzzle.

A `Boundary` is simply an unordered list or group of `Permission`s. Each
`Permission` may only occur once. Any `Permission`s that are not specified
are assumed to be `null`. This loosely corresponds to a `role` in RBAC.

A `Grant` links a `subject` (user or circle) to a `Boundary`. It
determines what permissions are considered for a given subject.

A `Acl` is simply an unordered list or group of `Grant`s. Subjects may
appear more than once in a list (with different boundaries) and the
permissions will be merged according to the following truth table:

| input | input | output |
|-------|-------|--------|
| false | false | false  |
| false | true  | false  |
| false | null  | false  |
| true  | false | false  |
| true  | true  | true   |
| true  | null  | true   |
| null  | false | false  |
| null  | true  | true   |
| null  | null  | null   |

Or in words: take the highest value where `false > true > null`.

At the end of this combination process, the user is only permitted if
the result is true. You can see this as requiring an affirmative
answer to permit something, while always allowing you a bigger `no` to
deny when things are combined. Null values are additionally not
required to be present in the database, saving us resources. That is
to say we default to null if there is no relevant record.

Finally, an object is linked to one or more `ACL`s by the `Controlled` multimixin, which pairs an object ID with an ACL ID. Because it is a multimixin, a given object can have multiple ACLs applied. In the case of overlap, permissions are combined in the manner described earlier. 


## Copyright and License

Copyright (c) 2020 James Laver, `bonfire_data_access_control` Contributors

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

