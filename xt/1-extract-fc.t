use Test;

use RakuDoc::Utils;

my $debug = 0;

sub clean($txt is copy, :$step) {
    # do all steps unless $step is defined, then do just that one

    # count <>
    my ($left, $right) = 0, 0;
    for $txt.comb -> $c {
        if $c eq '<' { ++$left  }
        if $c eq '>' { ++$right }
    }
    say "WARNING: Unbalanced <>: left: $left, right: $right" if $left != $right;

    $txt ~~ s:g/\n/ /; # newlines to spaces 
    $txt ~~ s:g/\h+/ /; # collapse multiple spaces to one
    $txt ~~ s:g/'>' \h+ '>'/>>/; # remove spaces between >>
    $txt ~~ s:g/\h+ '<'/</;      # remove spaces before <
    $txt ~~ s:g/'<' \h+ /</;     # remove spaces after <
    $txt ~~ s:g/\h+ '>'/>/;      # remove spaces before >
    $txt .= trim;
    $txt;
}

    # possible steps to do that:
    #   first, warn of unbalanced <> pairs and have user add \ before odd <>
    #     (if that can be done, otherwise disallow unbalanced <>
    #   ' B < I < one > U < two > > ' 
    #   'B < I < one > U < two > >' # trimmed and newlines removed
    #   'B < I < one > U < two >>'  # spaces between > > removed
    #   'B< I< one > U< two >>'     # spaces before < removed
    #   'B<I<one > U<two >>'        # spaces after < removed
    #   'B<I<one> U<two>>'          # spaces before > removed

# test atrings for phase one parsing
my @tin = [
    " B < I < one > \nU < two > > ",  # simple
    " B < I < one > U < two > > >", # unbalanced <>
];

# expected results
my @texp = [
    "B<I<one> U<two>>",  # simple
    "B<I<one> U<two>>>", # unbalanced <>
];

for @tin.kv -> $i, $txt {
    my $tout = clean $txt;
    is $tout, @texp[$i];
}

done-testing;
