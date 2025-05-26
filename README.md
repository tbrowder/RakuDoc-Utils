[![Actions Status](https://github.com/tbrowder/RakuDoc-Utils/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Utils/actions) [![Actions Status](https://github.com/tbrowder/RakuDoc-Utils/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Utils/actions) [![Actions Status](https://github.com/tbrowder/RakuDoc-Utils/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/RakuDoc-Utils/actions)

NAME
====

**RakuDoc::Utils** - Provides routines to extract RakuDoc and convert to classes for further word processing.

SYNOPSIS
========

```raku
use RakuDoc::Utils;
#...user code
```

DESCRIPTION
===========

**RakuDoc::Utils** is designed to simplify extracting RakuDoc from a file and converting it to a user-friendly tree structure for further processing.

It is intended primarily to be used in PDF document production, but it could also be useful in other roles. Note it currently has limited capability, and the author has implemented features in the order most useful to his other projects.

### Terminology

For typesetting, we need to sometimes handle pieces of text that do not fit our perception of a "word." For example, we sometmes have to hyphenate a word in order to split it if a line of text is too long. In that event, we need a way to handle that programmatically. We shall call such pieces "atoms." An atom may or may not contain spaces, but this module will not normally include spaces in its atoms.

This module provides the following capabilities:

### Extract RakuDoc from a block of text

The text can be in a string or a file. The text can have formatting codes, which may be nested to apply multple styling on an atom of text. Note the text could come from any of the other RakuDoc node types which can be selectively extracted with the aid of module `Pod::TreeWalker`.

The following Formatting codes are currently handled: 

    * B - bold font

    * I - italic (oblique) font

    * U - underline text

    * O - overline text

    * M - strikethrough text

    * C - code (uses a monospaced font)

    * L - link (may have two parts separated with '|')

    * N - note (may be styled)

    * E - Unicode character (may be styled))

    * V - verbatim text

    * X - index entry (may have two parts separated with '|')

Following is an example of an almost-properly formatted block of text and its parsing into a list of individual words with unneeded spaces removed:

Input (with extraneous but allowable spaces):

     B < I < one > > and
        U < I < two > >

Output (with extraneous spaces removed):

    B<I<one>> and U<I<two>>

Any `blank` lines break up the text into lines:

    B<I<one>> 
    and 

    U<I<two>>

becomes:

    B<I<one>> and 
    U<I<two>>

### Parse the text into a list of `Atom` objects

Class Atom encapsulates the format details of the text atoms to pass to a using routine for further processing.

     Atom {
        has @.attrs is required is rw = []; # the attributes
        has $.text  is required is rw = "";
        has $.style is rw = "";

        submethod TWEAK {
            $!style = @!attrs.join;
        }

        method debug-print {
            my $txt   = "";
            my $front = "";
            my $back  = "";
            for @!attrs.reverse -> $a {
                $front ~= "{$a}<";
            }
            for @!attrs.reverse -> $a {
                $back ~= ">";
            }
            $txt = $front ~ $!text ~ $back;
        }
    }

Planned features
----------------

  * Break a RakuDoc document into "slices" for individual, serial node handling. Slices may have child slices to account for nested nodes such as mutilevel lists, paragraphs, and references.

  * Provide higher level RakuDoc node extraction

See also
--------

  * PDF::Lite

  * PDF::Document

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

