package BT::Target::Percent;

use Mojo::Base 'BT::Target';

use BT::Params;

has 'profit_target';

sub params {
    return [
        BT::Params::ProfitTarget,
    ];
}

1;
