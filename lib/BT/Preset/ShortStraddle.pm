package BT::Preset::ShortStraddle;

use Mojo::Base 'BT::Preset';

use BT::Params;

sub meta {
    return {
        description => 'Short Straddle',
        strategy    => 'ShortStraddle',
        target      => 'Percent',
        sizing      => 'SingleLot', # SingleLot or IMFactor
        params      => [
            BT::Params::DTE('30'),
        ],
    };
}

1;
