package BT::Preset::Ron51535;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'Ron Bertino\'s 5/15/35',
        strategy    => 'Ron51535',
        target      => 'Fixed',
        sizing      => 'SingleLot',
        params      => [
            BT::Params::DTE('90+'),
            {
                name        => 'long_call_delta',
                label       => 'Call Delta',
                default     => 35,
                type        => 'float-range',
                description => 'Delta of Long Call',
            },
            {
                name        => 'short_put_delta',
                label       => 'SP Delta',
                default     => 15,
                type        => 'float-range',
                description => 'Delta of Short Put (PCS)',
            },
            {
                name        => 'long_put_delta',
                label       => 'LP Delta',
                default     => 5,
                type        => 'float-range',
                description => 'Delta of Long Put (PCS)',
            },
            {
                name        => 'pcs_size',
                label       => 'PCS #',
                default     => 9,
                type        => 'int',
                description => 'Size of PCS',
            },
        ],
    };
}

1;
