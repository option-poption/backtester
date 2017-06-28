package BT::Preset::ShortPut::Percent;

use Mojo::Base 'BT::Preset';

use BT::Params;


sub meta {
    return {
        description => 'sell far OTM puts (distance from underlying)',
        strategy    => 'FlexPos',
        target      => 'Percent',
        sizing      => 'IMFactor',
        params      => [
            BT::Params::DTE,
            BT::Params::Percent,
        ],
    };
}

sub strategy_params {
    my ($self) = @_;

    my $params = $self->SUPER::strategy_params;

    return {
        ratio   => [-1],
        dte     => [$params->{dte}],
        percent => [$params->{percent}],
    };
}

1;
