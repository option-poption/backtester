package BT::Target::Falde604020;

use Mojo::Base 'BT::Target';

use BT::Params;

has 'time_exit';

sub params {
    return [
        BT::Params::TimeExit(30),
    ];
}

1;
