class Player is export {
    has Str $.name;
    has $.points is rw;
    has Int $.wallet is rw = 1000;

    # Place a bet.
    method bet(Int $bet) { $!wallet -= $bet; }
}
