use Caelum::Player;
use Terminal::Table;

multi sub MAIN(
    Int :$players where * >= 2 = 2, #= Number of players (default: 2)
) is export {
    say "Caelum - text based Cee-lo game";
    say "-------------------------------\n";

    my Player @players;

    for ^$players {
        push @players, Player.new(name => prompt("[Player $_] Name: ").trim);
    }

    my Int $round = 1;
    my Int $pot = 0;

    loop {
        print "\n";
        say "[Round $round]";
        say "- " x 40;

        my Int $bet;
        for @players -> $player {
            $bet += prompt "[{$player.name}] Enter bet amount: ";
        }
        $bet = $bet div @players.elems;
        say "\n==> Bet amount: $bet";

        player: for @players -> $player {
            print "\n";
            say "[{$player.name}]";
            say ". " x 20;

            # Reset points.
            $player.points = 0;

            unless $player.wallet >= $bet {
                say "==> Cannot place bet. All amount goes to pot.";
                $pot += $player.wallet;
                $player.wallet = 0;

                next player;
            }

            $player.bet($bet);
            $pot += $bet;

            say "==> Placing bet. Updated wallet: {$player.wallet}.";

            roll: loop {
                print "++> Rolling dices.. ";

                my Int @dices;
                push @dices, (1 .. 6).pick(1)[0] for ^3;

                say @dices;

                given set(@dices).elems {
                    when 3 {
                        given @dices.sort {
                            when * ~~ (4, 5, 6) { $player.points = Inf; }
                            when * ~~ (1, 2, 3) { $player.points = -Inf; }
                        }
                    }
                    when 2 {
                        $player.points = @dices.Bag.list.grep(
                            *.value == 1
                        )>>.key[0];
                    }
                    when 1 { $player.points = @dices[0] * 100; }
                }

                if $player.points == 0 {
                    say "--> Invalid Roll.";
                    next roll;
                } else {
                    last roll;
                }
            }
        }

        with @players.sort(*.points).reverse[0] -> $player {
            say "{$player.name} wins $pot!";
            $player.wallet += $pot;
        }
        $pot = 0;

        # Print scorecard.
        my @scorecard = <Player Points Wallet>,;
        for @players -> $player {
            push @scorecard, [$player.name, $player.points.Str, $player.wallet.Str];
        }
        print-table(@scorecard, style => "single");

        $round++;
    }
}

multi sub MAIN(
    Bool :$version #= print version
) is export { say "Caelum v" ~ $?DISTRIBUTION.meta<version>; }
