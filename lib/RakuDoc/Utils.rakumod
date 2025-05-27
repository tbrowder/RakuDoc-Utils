unit module RakuDoc::Utils;

use Pod::TreeWalker;
#use Pod::TreeWalker::Listener;
use RakuDoc::Load;

use RakuDoc::Utils::Listener;
use RakuDoc::Utils::Classes;
use RakuDoc::Utils::Vars;

=begin comment

Given a chunk of text with pod formatting characters, convert them
to atoms with integrated text embellishments for each subchunk.

For example, given this text (note "illegal" spaces after
some formatting codes):

   Now is the B<time> to see,
     my U<old B< dog> has I< fleas> >, hasn't he?

Step 1. Clean it up to remove illegal spaces yielding:

   Now is the B<time> to see, my U<old B<dog> has I<fleas>>, hasn't he?

Step 2. Parse the chunks into Atoms for further word processing:

   An Atom is a chunk of text (NOT including newlines or spaces)
   with the same style, font, and font size. Atoms in this example are
   separated by pipes to show no spaces are left:

   |Now|is|the|B<time>|to|see,|my|U<old>|U<B<dog>|U<has>|U<I<fleas>>|,|hasn't|he?|

   Note a collection of Atoms can be treated as various document elements,
   but such things as punctuation and Atom spacing will have to be handled
   accordingly.

=end comment

# Given formatted text, extract it as is.
# the input text must use NO pod except formatting codes.
sub raw(
    Str $text-in,
    :$para-text = True, # ignores the begin/end of pod and para
    :$debug,
    --> Str
    ) is export {
    my ($L, $pod-tree, $o, @events, $code);
    $L = RakuDoc::Utils::Listener.new;
    $pod-tree = load-rakudoc  $text-in;
    $o = Pod::TreeWalker.new: :listener($L);
    $o.walk-pod: $pod-tree.head;
    @events = $L.events;

    my @codes = [];
    my $text = "";
    EVENT: for @events.kv -> $i, $event {
        die "FATAL: a non-has event" unless $event ~~ Hash;
        if 0 and $debug {
            my $keys = $event.keys.join(" ");
            say "DEBUG:keys: $keys";
        }
        if $debug {
            say "event {$i+1}:";
            for $event.kv -> $k, $v {
                say "  key: |$k|";
                say "  value: |$v|";
            }
            next EVENT;
        }

        for $event.kv -> $k, $v {
            when $k eq "code-type" {
                $code = $v;
                $code .= trim;
                @codes.push: $code;
            }
            when $k eq "start" {
                ; # if $e<code-type>:exists {
            }
            when $k eq "end" {
                # end of the CURRENT code type
                @codes.pop if @codes;
            }
            when $k eq "text" {
                # add it to $text
                $text ~= $v;
            }
            when $k eq "formatting-code" {
                ; # action?
            }
            when $k eq "meta" {
                ; # action?
            }
            when $k eq "type" {
                ; # action?
            }
            when $k eq "name" {
                ; # action?
            }
            default {
                # what else could it be?
                say "WARNING: Unexpected event key: '$k'";
                say "         value: '$v'";
            }
        }
    }
    $text;
}

sub extract-formatted-text( 
    Str $text-in,
    :$debug,
    --> Str
    ) is export {

    # This sub's output is the input to sub text2chunks
    # See files xt/0*t and xt/2*t for its tests

    my ($f, $L, $pod-tree, $o, @events);
    $f = "t/data/one-liner.rakudoc";
    $L = RakuDoc::Utils::Listener.new;
    $pod-tree = load-rakudoc  $text-in;
    #$o = Pod::TreeWalker.new: :listener($L);
    $o = RakuDoc::Utils::TreeWalker.new: :listener($L);
    $o.walk-pod: $pod-tree.head;
    @events = $L.events;

    # Ideally, this sub should extract the formatted text in the
    # incoming text and reformat it into text words that
    # are either individually formatted with one or more
    # bounding styles or they are completely unformatted text.
    # The incoming text may have format codes that encompass
    # more than one word, but the output words are completely
    # independent of any other words.

    # For example, input may be ' B < I < one > U < two > > ' but the output
    # will be 'B<I<one>> B<U<two>>'.

    # possible steps to do that:
    #   first, warn of unbalanced <> pairs and have user add \ before odd <>
    #     (if that can be done, otherwise disallow unbalanced <>
    #   ' B < I < one > U < two > > '
    #   'B < I < one > U < two > >' # trimmed and newlines removed
    #   'B < I < one > U < two >>'  # spaces between > > removed
    #   'B< I< one > U< two >>'     # spaces between style X < removed
    #   'B<I<one > U<two >>'        # spaces after < removed
    #   'B<I<one> U<two>>'          # spaces before > removed

    # BUT FOR NOW WE INSIST ON PROPER GROUPING
    my Style @styles = [];
    my @chunks = [];
    my $chunk  = "";

    # watch for the following situations that take careful handling:
    #  + extra trailing '>'
    #  + extra leading '<' (note Rakudoc allows Unicode char '<<'
    #      << instead of one <)
    #     that pair consists of Unicode chars \x00ab and \x00bb
    my $text = "";
    for @events -> $e {
        if $e<start>:exists {
            if $e<code-type>:exists {
                #===================================
                # start of a chunk of formatted text
                #===================================
                my $code = $e<code-type>.trim;
                unless %formatting-codes{$code}:exists {
                    die "FATAL: Unknown formatting code '$code'";
                }
                unless %formatting-codes{$code} {
                    die qq:to/HERE/;
                    Unhandled formatting code '$code'.
                    Ignoring it, but file an issue if you need it handled.
                    HERE
                }

                my $style = Style.new: :style($code);

                # possibilies:
                #   + if no @styles

                # if the last two chars in $text were a code-type and a '<',
                # add no space
                my @c = $text.comb;
                my $last = @c.elems ?? @c.pop !! "";
                if $last eq '<' {
                    $text ~= $code;
                    $text ~= '<';
                }
                elsif $last ne "" {
                    $text ~= " ";
                }
                else {
                    $text ~= $code;
                    $text ~= '<';
                }
            }
            if $debug { say "start: ", $e.gist; }
        }
        elsif $e<end>:exists {
            if $e<code-type>:exists {
                #===================================
                # end of a chunk of formatted text
                #===================================
                my $code = $e<code-type>.trim;

                # test certainties
                unless @styles.elems {
                    say "ERROR: unexpected empty \@styles";
                }
                unless $chunk.chars {
                    say "ERROR: unexpected empty \$chunk";
                }

                $text .= trim-trailing;
                $text ~= '>';
#               my $style = @styles.pop;
            }
            if $debug { say "end: ", $e.gist; }
        }
        elsif $e<text>:exists {
            # if it's formatted text, there should be at least one
            # @styles element
            my $txt = $e<text>.trim;

            =begin comment
            my $lchar = $text.comb.tail;
            if not $text {
                $text ~= $txt;
            }
            elsif $lchar eq '<' {
                $text ~= $txt; # '>';
            }
            elsif $txt ~~ / '.'|'!'|'?' / {
                $text .= trim-trailing;
                $text ~= $txt;
            }
            elsif $lchar eq ' ' {
                $text ~= $txt;
            }
            else {
                die "FATAL: Unexpected situation. Please file an issue";
            }
            =end comment

            if $debug { say "text: ", $txt; }
        }
        else {
            # what else could it be?
            if 1 or $debug { say "DEBUG: inside: '{$e.gist}'"; }
        }
    }

#   $text ~~ s:g/'>' \h+ '>'/'>>'/;

    # at this point the text should satisfy the following:
    # 1.  no space between a style char and its following '<'
    #       (called a "style pair"): B<

    # 2.  no bare char before a style pair as in: 'bB<' [maybe later]
    # 3.  one or more chars before a style closer: x>
    #       (not to be confused by a bare '>')
    # 4.  one or more chars after a style pair: B<x
    # 5.  zero or more < or > not as styles

    # for $text.words -> $w {
    #     my @c  = $w.comb; #     my $ne = @c.elems;
    # }

    $text;
}

sub text2chunks(
    $text-in,
    :$debug,
    --> Str
    ) is export {
    # Consolodating "chunks" into
    # self-contained words (this is cheating a bit because
    # underlining, et alii, will not carry over the word spaces, BUT
    # that can be handled in the parent Para).
    #
    # This sub's output is the input to sub parse-text.
    my @w = $text-in.lines.words; # .comb.reverse; # use a stack: pop/push

    # trial balloon...
    my @t;     # a push/pop stack to keep track of styles X<> in/out
    my @chunk; # a push/pop stack for building with multiple styles
    my @a;     # the final Atom list

    for @w -> $w {
        my $is-styled = 0;
        # A word is either styled or not. it is NOT styled if there
        # is no style in the stack and none at the beginning of the word.

        my @c = $w.comb;
        my $this = @c.shift; # start with the oldest (leftmost)
        my $next = @c.head // "";

        # is this a styled word? it can have more than one style!
        if $next eq '<' {
            if $this ~~ / (B|I|U|O|M|C|L) / {
                my $k = ~$0 if $0.defined;
                ; # ok, so what?
                @t.push: $k;
                @c.shift; # get rid of the '<'
                $is-styled = 1;
                next;
            }
            else {
                die "FATAL: Unexpected char '$this'";
            }
        }

        # check the end for one or more '>'
        my @enders = @c.reverse;



        if $this eq '>' {
            # end of style type
            # check the stack
            @t.pop if @t.elems;
        }

        if @t.elems {
            # the @t stack contains any attributes

        }
        else {
            # the @t stack contains any attributes
            my $a = Atom.new: :text($this), :attrs(@t);
            @a.push: $a;
        }
    }

    # create a string out of the Atoms
    my $txt;
    for @a -> $a {
        $txt ~= $a.print;
    }
    $txt;
}

sub parse-text(
    $text,
    :$debug,
    --> List # of Atoms
    ) is export {
    my @w = $text.lines.words;

    my @atoms;
    my $in-b = 0;
    my $in-i = 0;
    my $in-u = 0;
    my $in-o = 0;
    my $in-m = 0;
    my $in-c = 0;
    my $in-l = 0;

    # start with a new, empty Atom
    my $a = Atom.new;

    for @w -> $w {
        my @c = $w.comb;
        for @c.kv -> $i, $c {
            when $c eq '<' {
                when @c[$i-1] eq 'B' { ++$in-b; }
                when @c[$i-1] eq 'I' { ++$in-i; }
                when @c[$i-1] eq 'U' { ++$in-u; }
                when @c[$i-1] eq 'O' { ++$in-o; }
                when @c[$i-1] eq 'M' { ++$in-m; }
                when @c[$i-1] eq 'C' { ++$in-c; }
                when @c[$i-1] eq 'L' { ++$in-l; }
            }
            when $c eq '>' {
                when @c[$i-1] eq 'B' { --$in-b; }
                when @c[$i-1] eq 'I' { --$in-i; }
                when @c[$i-1] eq 'U' { --$in-u; }
                when @c[$i-1] eq 'O' { --$in-o; }
                when @c[$i-1] eq 'M' { --$in-m; }
                when @c[$i-1] eq 'C' { --$in-c; }
                when @c[$i-1] eq 'L' { --$in-l; }
            }
        }
    }
}
