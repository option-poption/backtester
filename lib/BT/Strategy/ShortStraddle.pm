package BT::Strategy::ShortStraddle;

use Mojo::Base 'BT::Strategy';

use Data::Dump qw/pp/;

has [qw/dte/];

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

    my $call = $db->delta_option(
        at         => $at,
        expiration => $expiration,
        delta      => 50,
        call_put   => 'C',
    );
    return unless $call;

    my $put = $db->delta_option(
        at         => $at,
        expiration => $expiration,
        delta      => 50,
        call_put   => 'P',
    );
    return unless $put;

    my $position = BT::Position->new(symbol => $symbol);
    $position->add(-1, $call);
    $position->add(-1, $put);

    return $position;
}

sub check_position {
    my ($self, %arg) = @_;

    $arg{preset}->target->check_position(%arg);
}

1;
