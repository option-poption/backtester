package BT::Sizing::RegT::BWB;

use Mojo::Base 'BT::Sizing';

sub size {
    my ($self, %arg) = @_;

    my $symbol   = $arg{symbol}   or die 'SYMBOL missing';
    my $balance  = $arg{balance}  or die 'BALANCE missing';
    my $position = $arg{position} or die 'POSITION missing';

    my @strikes = map { $_->strike } $position->options;

    # full risk for the BWB
    my $risk = 2 * $strikes[1] - $strikes[0] - $strikes[2];
    $risk *= $symbol->multiplier;

    # premium
    my $premium = $position->price * $symbol->factor;

    return int($balance / ($risk + $premium));
}

1;
