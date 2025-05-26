unit module RakuDoc::Utils::Classes;

role Node is export {
    has $.text;
    has @.nodes;
}

class Slice is export {
}

class Atom is export {
    has @.attrs is required is rw = []; # the attributes
    has $.text  is required is rw = "";
    has $.style is rw = "";

    submethod TWEAK {
        $!style = @!attrs.join;
        # the font depends on the style attributes
        
        
    }

    method print {
        my $txt   = "";
        my $front = "";
        my $back  = "";
        for @!attrs.reverse -> $a {
            $front ~= "{$a}<";
        }
        for @!attrs.reverse -> $a {
            $back ~= ">";
        }
        $txt = $front ~ $!text ~ $back;
    }
}

class Style is export {
    has $.style is required = ""; # one of BIUOMLC
    # a style may be followed immediately by another style without any
    # intervening text so .char will be empty
    has $.char is rw = "";
}


class Pg is export {
    has @.lines is rw;
}

class Vbloc is export {
    has $.text is rw;
    has $.list is rw;
    has $.title is rw;
    has $.subtitle is rw;
}
