unit class Rakudoc::Utils;

use Pod::TreeWalker;
use Pod::Load;

use Rakudoc::Utils::Classes;

sub read-pod(
    $rfil, #= a file with rakudoc
    :$debug,
    ) is export {
    unless $rfil.IO.r {
        die "FATAL: Unable to read Input file '$rfil'";
    }
    my $pod = load $rfil;
}

=finish

sub show-help() is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <input file> ofile=/file/path 
    HERE
}

sub run-prog(
    @*ARGS,
    :$debug,
    ) is export {
    my $ifile;
    my $ofile;
    
    for @*ARGS {
        when $_.IO.f {
            if $ifile.IO.r {
                print qq:to/HERE/;
                FATAL: Already have an input file defined: '$ifile'.
                       Exiting...
                HERE
                exit;
            }
            $ifile = $_.IO.r;
        }
        when /^ :i 'ofile=' (\S+) / {
            $ofile = $_.IO.r;
        }
        when /^ :i d / {
            ++$debug;
        }
        default {
            print qq:to/HERE/;
            FATAL: Unknown arg '$_'.
                   Exiting...
            HERE
            exit;
        }
    }
}
