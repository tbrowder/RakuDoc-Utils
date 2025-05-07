#!/usr/bin/env raku

use Pod::Load;
use Pod::TreeWalker;
use Rakudoc::Utils;
use Rakudoc::Utils::Listener;
use Rakudoc::Utils::Classes;

my $f1 = "t/data/real-pod-example.rakudoc";
my $f2 = "t/data/formatted-text.rakudoc";
my $f3 = "t/data/list.rakudoc";
my $f4 = "t/data/real-no-format.rakudoc";

#my $pod-tree = load-pod $f1.IO.slurp;
my $pod-tree = load-pod $f4.IO.slurp;

my $L = Rakudoc::Utils::Listener.new;

my $o = Pod::TreeWalker.new: :listener($L);
$o.walk-pod($pod-tree.head);

my $debug = 0;
my %keys;

my $elevel = 0;
for $L.events -> $e {
    unless $e ~~ Hash {
        die "FATAL: Event is NOT a Hash";
    }

    if $e<start>:exists {
        ++$elevel;
        say "| a start event at level $elevel...";
    }
    elsif $e<end>:exists {
        --$elevel;
        say "| an end event at level $elevel...";
    }
    else {
        say "  inside an event at level $elevel...";
    }

    say "event is a hash" if $debug;
    say "event keys:" if $debug;
    my @k = $e.keys.sort;
    for @k -> $k {
        my $v = $e{$k};
        say "  '$k' => '$v" if $debug;
        %keys{$k} = True;
    }
}

say "summary of keys found (keys 'start' and 'end' are not shown):" if $debug;
for %keys.keys.sort -> $k {
    next if $k ~~ /start|end/;
    say "  $k" if $debug;
}

=finish
# this works:
say $o.text-contents-of($pod-tree.head);
