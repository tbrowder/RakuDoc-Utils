use Test;

my $str = q:to/HERE/;
=begin pod

B < I < one two > U < three > > >

=end pod
HERE

my $tdir;
mkdir "/tmp/mine";
my $fil = "/tmp/mine/pod";
spurt $fil.IO, $str;

lives-ok {
    #run "raku", "--doc", $fil;
    run "raku", "-c", $fil;
}

done-testing;
