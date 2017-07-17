package BT::Preset::RatioSpread::Delta;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'sell ratio spreads (strike selection by delta)',
        strategy    => 'FlexPos',
        target      => 'Percent',
        sizing      => 'IMFactor',
        params      => [
            BT::Params::DTE,
            BT::Params::Delta(6),
            {
                name        => 'delta2',
                label       => 'Delta 2',
                default     => 1.5,
                type        => 'float-range',
                description => 'Select second Strike based on Delta',
            },
            {
                name        => 'spread',
                label       => 'Spread Type',
                default     => '1x2',
                type        => 'select',
                values      => ['1x2', '1x3', '2x3'],
                description => 'Select Spread Type (Ratio)',
            },
        ],
    }
}

sub strategy_params {
    my ($self) = @_;

    my $params = $self->SUPER::strategy_params;

    my $ratio = [-1, 2];
    if ($params->{spread} eq '1x3') {
        $ratio = [-1, 3];
    } elsif ($params->{spread} eq '2x3') {
        $ratio = [-2, 3];
    }

    return {
        ratio => $ratio,
        dte   => [$params->{dte}, $params->{dte}],
        delta => [$params->{delta}, $params->{delta2}],
    }
}

1;
