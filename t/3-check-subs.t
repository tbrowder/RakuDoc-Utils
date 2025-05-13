use Test;

use Rakudoc::Utils;
use Rakudoc::Utils::Subs;

my $txt1 = qq:to/HERE/;
Now is the B<time> to see,
 my U<old B< dog> has I< fleas>>, hasn't he?
HERE

my $txt2 = qq:to/HERE/;
Now is the B<time> to see, my U<old B<dog> has I<fleas>>, hasn't he?
HERE

my $txt3 = qq:to/HERE/;
Now is the B<time> to see, my U<old> U<B<dog>> U<has> U<I<fleas>>, hasn't he?
HERE

my (@list, $text-out);

lives-ok {
    $text-out = clean-text $txt1;
}, "clean-text";
is $text-out, $txt2.trim, "is txt2";

lives-ok {
    $text-out = text2chunks $txt2;
}, "text2chunks";
is $text-out, $txt3.trim, "is txt3";

done-testing;
=finish

lives-ok {
    $text-out = parse-text $txt3;
}
is $text-out, $txt4.trim;

done-testing;

