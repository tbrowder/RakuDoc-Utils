unit module Rakudoc::Utils::Classes;

class Pg is export {
    has @.lines is rw;
}

class Vbloc is export {
    has $.text is rw;
    has $.list is rw;
    has $.title is rw;
    has $.subtitle is rw;
}
