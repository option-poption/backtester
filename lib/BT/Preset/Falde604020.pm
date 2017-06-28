package BT::Preset::Falde604020;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'Andrew Falde\'s 60/40/20 BWB',
        strategy    => 'Falde604020',
        target      => 'Falde604020',
        sizing      => 'SingleLot',
        params      => [
            BT::Params::DTE('60+'),
            {
                name        => 'delta_percent',
                label       => 'Delta%',
                default     => 30,
                type        => 'float',
                description => 'Exit position, if middle Delta exceeds +/- ... %',
            },
        ],
    };
}

1;
