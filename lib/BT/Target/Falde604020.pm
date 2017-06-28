package BT::Target::Falde604020;

use Mojo::Base 'BT::Target';

sub params {
    return [
        {
            name    => 'time_exit',
            label   => 'Time Exit',
            default => 30,
            type    => 'int',
            description => 'Exit if DTE falls below this',
        },
    ];
}

1;

