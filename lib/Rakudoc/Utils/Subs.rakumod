unit module Rakudoc::Utils::Subs;

=begin comment

Given a chunk of text with pod formatting characters, convert them
to atoms with integrated text embellishments for each subchunk.

For example, given this text (note "illegal" spaces after
some formatting codes):

 My U<old B< dog> has I< fleas>>.

convert it to this set of text
chunks:

 My U<old> U<B<dog>> U<has> U<I<fleas>>.

Then parse them into Atoms for further word processing.

=end comment

class Atom {
    has $.text is rw = "";
    has $.B is rw = 0;
    has $.I is rw = 0;
    has $.U is rw = 0;
    has $.O is rw = 0;
    has $.M is rw = 0;
    has $.C is rw = 0;

    # defaults (use core fonts for now)
    has $.font is rw = "";
    has $.size is rw = 14;
} 

sub text2chunks(
    $text,
    :$debug,
    --> List
    ) is export {
    # Use code from David's stuff to consolidate "chunks" into
    # self-contained words (this is cheating a bit because
    # underlining, et alii, will not carry over the word spaces, BUT
    # that can be handled in the parent Para).
    #
    # This sub's output is the input to sub parse-text.
}

sub parse-text(
    $text,
    :$debug,
    ) is export {
    my @w = $text.lines.words;

    my @atoms;
    my $in-b = 0;
    my $in-i = 0;
    my $in-u = 0;
    my $in-o = 0;
    my $in-m = 0;
    my $in-c = 0;

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



