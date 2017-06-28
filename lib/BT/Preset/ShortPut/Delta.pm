package BT::Preset::ShortPut::Delta;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'sell far OTM puts (strike selection by delta)',
        strategy    => 'FlexPos',
        target      => 'Percent',
        sizing      => 'IMFactor',
        params      => [
            BT::Params::DTE,
            BT::Params::Delta,
        ],
    };
}

sub strategy_params {
    my ($self) = @_;

    my $params = $self->SUPER::strategy_params;

    return {
        ratio => [-1],
        dte   => [$params->{dte}],
        delta => [$params->{delta}],
    };
}

1;
