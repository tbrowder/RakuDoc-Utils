use Test;

use Rakudoc::Utils;
use Rakudoc::Utils::Subs;

my $text-in = qq:to/HERE/;
Now is the B<time>.
 My U<old B< dog> has I< fleas>>.
HERE

my (@list, $text-out);
lives-ok {
    $text-out = text2chunks $text-in;
}
