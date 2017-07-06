package BT::Preset::CreditSpread::Percent;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'sell credit spreads (distance from underlying)',
        strategy    => 'FlexPos',
        target      => 'Percent',
        sizing      => 'IMFactor',
        params      => [
            BT::Params::DTE,
            BT::Params::Percent,
            BT::Params::Width,
        ],
    };
}

sub strategy_params {
    my ($self) = @_;

    my $params = $self->SUPER::strategy_params;

    return {
        ratio   => [-1, 1],
        dte     => [$params->{dte}, $params->{dte}],
        percent => [$params->{percent}],
        width   => [-$params->{width}],
    };
}

1;
