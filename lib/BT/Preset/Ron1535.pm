package BT::Preset::Ron1535;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'Ron Bertino\'s 15/35',
        strategy    => 'Ron1535',
        target      => 'Fixed',
        sizing      => 'SingleLot', # SingleLot or IMFactor
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
                description => 'Delta of Short Put',
            },
            {
                name        => 'short_put_size',
                label       => 'SP #',
                default     => 6,
                type        => 'int',
                description => 'Number of Short Put Contracts',
            },
        ],
    };
}

1;
