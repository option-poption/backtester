package BT::Strategy::Falde604020;

use Mojo::Base 'BT::Strategy';

use BT::Position;

has 'symbol';

has [qw/dte delta_percent/];

sub entry {
    my ($self, %arg) = @_;

    my $db     = $arg{db}     or die 'DB missing';
    my $at     = $arg{at}     or die 'AT missing';
    my $symbol = $arg{symbol} or die 'SYMBOL missing';

    my $expiration = $db->expiration(
        symbol_id => $symbol->id,
        at        => $at,
        dte       => $self->dte,
    );
    return unless $expiration;

    my $position = BT::Position->new(symbol => $symbol);

    my @delta = (20, 40, 60);
    my @puts = ();
    foreach my $delta (@delta) {
        my $option = $db->delta_option(
            symbol_id  => $symbol->id,
            at         => $at,
            expiration => $expiration,
            delta      => $delta,
        );
        return unless $option;

        push @puts, $option;
    }

    $position->add(1, $puts[0]);
    $position->add(-2, $puts[1]);
    $position->add(1, $puts[2]);

    return $position;    
}

sub check_position {
    my ($self, %arg) = @_;

    my $db         = $arg{db}         or die 'DB missing';
    my $preset     = $arg{preset}     or die 'PRESET missing';
    my $trade      = $arg{trade}      or die 'TRADE missing';
    my $position   = $arg{position}   or die 'POSITION missing';
    my $underlying = $arg{underlying} or die 'UNDERLYING missing';

    if ($position->first_option->dte <= 30) {
        $trade->exit_reason('TIME_EXIT');
        $trade->exit_position($position);
        $trade->exit_underlying($underlying);

        return 'EXIT';
    }

    my $diff = 0.4 * $self->delta_percent / 100;

    my @options = $position->options;
    my $delta   = $options[1]->delta;
    my $reason  = '';
    if ($delta < 0.4 - $diff) {
        $reason = 'DELTA_BELOW';
    } elsif ($delta > 0.4 + $diff) {
        $reason = 'DELTA_ABOVE';
    }
    if ($reason) {
        $trade->exit_reason($reason);
        $trade->exit_position($position);
        $trade->exit_underlying($underlying);

        return 'EXIT';
    }

    return '';
}

1;
