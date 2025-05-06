#!/usr/bin/env raku

use Pod::Load;
use Pod::TreeWalker;
use Rakudoc::Utils;
use Rakudoc::Utils::Listener;


my $f = "t/data/slides.rakudoc";
my $pod-tree = load-pod $f.IO.slurp;
my $L = Rakudoc::Utils::Listener.new;

my $o = Pod::TreeWalker.new: :listener($L);
$o.walk-pod($pod-tree.head);

my %keys;

for $L.events {
    if $_ ~~ Hash {
        say "event is a hash";
        say "event keys:";
        for $_.keys -> $k {
            say "  '$k'";
            %keys{$k} = True;
        }
    }
    else {
        say "event is NOT a hash";
    }
}

say "summary of keys found (keys 'start' and 'end' are not shown):";
#say "  $_" for %keys.keys.sort;
for %keys.keys.sort -> $k {
    next if $k ~~ /start|end/;
    say "  $k";
}


=finish
# this works:
say $o.text-contents-of($pod-tree.head);
