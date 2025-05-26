use Test;

use Rakudoc::Utils;
use Rakudoc::Utils::Subs;

my $debug = 1;
my ($text-out);

# For example, input may be ' B < I < one > U < two > > ' but the output
# will be 'B<I<one>> B<U<two>>'.

my $txtA = qq:to/HERE/;
\n B < < I < one > U < two > >    >>
HERE
my $txtA-resp = qq:to/HERE/;
B<I<one>> B<U<two>>
HERE
lives-ok {
    $text-out = extract-formatted-text $txtA, :$debug; 
}, "extract-formatted-text";
is $text-out, $txtA-resp.trim, "is txtA";

done-testing;
=finish

my $txt1 = qq:to/HERE/;
B< I< Now> is > the B<time> to see,
 my U<old B< dog> has I< fleas>>, hasn't he?
HERE

my $txt2 = qq:to/HERE/;
Now is the B<time> to see, my U<old B<dog> has I<fleas>>, hasn't he?
HERE

my $txt3 = qq:to/HERE/;
Now is the B<time> to see, my U<old> U<B<dog>> U<has> U<I<fleas>>, hasn't he?
HERE

lives-ok {
#   $text-out = clean-text $txt1;
    $text-out = extract-formatted-text $txt1; 
}, "clean-text";
is $text-out, $txt2.trim, "is txt2";

lives-ok {
    $text-out = extract-formatted-text $txt2; 
}, "text2chunks";
is $text-out, $txt3.trim, "is txt3";

done-testing;
=finish

lives-ok {
    $text-out = parse-text $txt3;
}
is $text-out, $txt4.trim;

done-testing;

