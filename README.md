[![Actions Status](https://github.com/tbrowder/Rakudoc-Utils/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Rakudoc-Utils/actions) [![Actions Status](https://github.com/tbrowder/Rakudoc-Utils/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Rakudoc-Utils/actions) [![Actions Status](https://github.com/tbrowder/Rakudoc-Utils/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Rakudoc-Utils/actions)

NAME
====

**Rakudoc::Utils** - Provides routines to extract Rakudoc and convert to classes for further word processing.

SYNOPSIS
========

```raku
use Rakudoc::Utils;
#...user code
```

DESCRIPTION
===========

**Rakudoc::Utils** is designed to simplify extracting Rakudoc from a file and converting it to a user-friendly tree structure for further processing.

It is intended primarily to be used in PDF document production, but it could also be useful in other roles.

Note its initial release has only a limited capability in order to support my upcoming distribution **Slidemaker**. To do that, it must handle the following Rakudoc elements:

    Formatting codes: C, L, B, I, U, O, M
    Bare strings/paragraphs

    =Title
    =Subtitle
    =for para
    =item     # not numbered, level 1 only
    =begin/=end code/para/item/comment
    =comment

Classes
=======

The following classes are designed to group data for the user:

### class Pg

    class Pg {
        has Vbloc @.vblocs;
    }

### class Vbloc

    class Vbloc {
        #| should only have one of the following
        #| (any text chunks may be formatted or contain links)
        has $.text; 
        has $.list;
        has $.title;
        has $.subtitle;
    }

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

