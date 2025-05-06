#!/usr/bin/env raku

use Pod::Load;
use Pod::TreeWalker;
use Slidemaker;
use Slidemaker::Listener;


my $f = "resources/real-pod-example.rakudoc";
my $pod-tree = load-pod $f.IO.slurp;
my $L = Slidemaker::Listener.new;

my $o = Pod::TreeWalker.new: :listener($L);
$o.walk-pod($pod-tree.head);
#$o.walk-pod(@($pod-tree));
#say "event: {$_.raku}" for $L.events;
say "event: {$_.gist}" for $L.events;
for $L.events {
    if $_ ~~ Hash {
        say "event is a hash";
    }
    else {
        say "event is NOT a hash";
    }
}


=finish
# this works:
say $o.text-contents-of($pod-tree.head);
