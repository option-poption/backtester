package BT::Strategy::Ron51535;

use Mojo::Base 'BT::Strategy';

use Data::Dump qw/pp/;

has [qw/dte long_call_delta short_put_delta long_put_delta pcs_size/];

sub entry {
    my ($self, %arg) = @_;

    my $db     = $arg{db}     or die 'DB missing';
    my $at     = $arg{at}     or die 'AT missing';
    my $symbol = $arg{symbol} or die 'SYMBOL missing';

    my $expiration = $db->expiration(
        at  => $at,
        dte => $self->dte,
    );
    return unless $expiration;

    my $position = BT::Position->new(symbol => $symbol);

    # 1 Long Call
    my $call = $db->delta_option(
        at         => $at,
        expiration => $expiration,
        delta      => $self->long_call_delta,
        call_put   => 'C',
    );
    return unless $call;

    $position->add(1, $call);

    # 2 Long Puts (same strike)
    my $put = $db->strike_option(
        at         => $at,
        expiration => $expiration,
        strike     => $call->strike,
        call_put   => 'P',
    );
    return unless $put;

    $position->add(2, $put);

    # Put Credit Spread
    my $short_put = $db->delta_option(
        at         => $at,
        expiration => $expiration,
        delta      => $self->short_put_delta,
        call_put   => 'P',
    );
    return unless $short_put;

    my $long_put = $db->delta_option(
        at         => $at,
        expiration => $expiration,
        delta      => $self->long_put_delta,
        call_put   => 'P',
    );
    return unless $short_put;

    $position->add(- $self->pcs_size, $short_put);
    $position->add(+ $self->pcs_size, $long_put);

    return $position;
}

sub check_position {
    my ($self, %arg) = @_;

    $arg{preset}->target->check_position(%arg);
}

1;
