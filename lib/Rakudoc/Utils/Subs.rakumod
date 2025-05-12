unit module Rakudoc::Utils::Subs;

use Pod::TreeWalker;
use Rakudoc::Utils::Listener;
use Pod::Load;
use FontFactory::Type1;

=begin comment

Given a chunk of text with pod formatting characters, convert them
to atoms with integrated text embellishments for each subchunk.

For example, given this text (note "illegal" spaces after
some formatting codes):

   My U<old B< dog> has I< fleas>>.

Step 1. Clean it up to remove illegal spaces yielding:

   My U<old B<dog> has I<fleas>>.

Step 2. Parse the chunks into Atoms for further word processing.

In order to get there, 

   Scan the whole string, noting in/out for each char, assigning
   each to a new Atom. Either in the process, or in another pass,
   merge Atoms with identical attributes except the chars.

=end comment

class Atom {
    has @.attrs is required is rw = []; # the attributes
    has $.text  is required is rw = "";

    has $.B is rw = 0;
    has $.I is rw = 0;
    has $.U is rw = 0; # underline
    has $.O is rw = 0; # strikethrough
    has $.M is rw = 0; # overline
    has $.C is rw = 0;

    # defaults (use core fonts for now)
    has $.font is rw = "";
    has $.size is rw = 14;

    submethod TWEAK {
        # go through the attributes and set the attr values
        for @!attrs {
            when /B/ { $!B = 1 }
            when /I/ { $!I = 1 }
            when /U/ { $!U = 1 }
            when /O/ { $!O = 1 }
            when /M/ { $!M = 1 }
            when /C/ { $!C = 1 }
        }
    }

} 

sub clean-text(
    $text-in,
    :$debug,
    --> Str
    ) is export {
    # This sub's output is the input to sub text2chunks
    # See file t/2*t for the test

    my ($f, $L, $pod-tree, $o, @events);
    $f = "t/data/one-liner.rakudoc";
    $L = Rakudoc::Utils::Listener.new;
    $pod-tree = load-pod $text-in;
    $o = Pod::TreeWalker.new: :listener($L);
    $o.walk-pod: $pod-tree.head;
    @events = $L.events;

    my $text = "";
    for @events -> $e {
        if $e<start>:exists {
            if $e<code-type>:exists {
                my $code = $e<code-type>.trim;
                $text ~= " " if $text;
                $text ~= $code;
                $text ~= '<';
            }
            if $debug { say "start: ", $e.gist; }
        }
        elsif $e<end>:exists {
            if $e<code-type>:exists {
                my $code = $e<code-type>.trim;
                $text .= trim-trailing;
                $text ~= '> ';
            }
            if $debug { say "end: ", $e.gist; }
        }
        elsif $e<text>:exists {
            my $txt = $e<text>.trim;
            my $lchar = $text.comb.tail;
            if not $text {
                $text ~= $txt;
            }
            elsif $lchar eq '<' {
                $text ~= $txt ; # '>';
            }
            elsif $txt ~~ / '.'|'!'|'?' / {
                $text .= trim-trailing;	
                $text ~= $txt;
            }
            elsif $lchar eq ' ' {
                $text ~= $txt;
            }
            else {
                die "FATAL: Unexpected situation";
            }
            if $debug { say "text: ", $txt; }
        }
        else {
            if $debug { say "inside: ", $e.gist; }
        }
    }
    $text;
}

sub text2chunks(
    $text-in,
    :$debug,
    --> Str
    ) is export {
    # Use code from David's stuff to consolidate "chunks" into
    # self-contained words (this is cheating a bit because
    # underlining, et alii, will not carry over the word spaces, BUT
    # that can be handled in the parent Para).
    #
    # This sub's output is the input to sub parse-text.
    my @chars = $text-in.lines.words.comb;

    # trial balloon...
    my @t; # a stack to keep track of X<> in/out
    my @a; # Atoms
    my $nc = @chars.elems;
    while @chars {
        #my $c = @chars.pop;
        my $c = @chars.shift; # start with the oldest
        my $next = @chars.elems ?? @chars.head !! "";
        if $next eq '<' {
            if $c ~~ / (B|I|U|O|M|C|L) / {
                my $k = ~$0 if $0.defined;
                ; # ok, then so what?
                @t.push: $k; 
                #@chars.pop; # get rid of the '<'
                @chars.shift; # get rid of the '<'
            }
            else {
                die "FATAL: Unexpected char '$c'";
            }
        }
        elsif $c eq '>' {
            # end of type
            # check the stack
            @t.pop if @t;
        }
        else {
            # the @t stack contains any attributes
            my $a = Atom.new: :text($c), :attrs(@t);
            @a.push: $a;
        }
    }
    # create a string out of the Atoms
    my $txt;
    for @a -> $a {
        $txt ~= $a.text ~ "";
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
            }
        }
    }
}



