package BT::Preset::CreditSpread::Delta;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'sell credit spreads (strike selection by delta)',
        strategy    => 'FlexPos',
        target      => 'Percent',
        sizing      => 'IMFactor',
        params      => [
            BT::Params::DTE,
            BT::Params::Delta,
            BT::Params::Width,
        ],
    };
}

sub strategy_params {
    my ($self) = @_;

    my $params = $self->SUPER::strategy_params;

    return {
        ratio => [-1, 1],
        dte   => [$params->{dte}, $params->{dte}],
        delta => [$params->{delta}],
        width => [-$params->{width}],
    };
}

1;
