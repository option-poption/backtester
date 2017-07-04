#!/usr/bin/env perl

use Mojo::Base -strict;

use Data::Dump qw/pp/;
use Module::Find qw/useall/;

use lib 'lib';
use BT::Mainloop;
use BT::Symbol;
useall 'BT::Preset';


my %CONFIG = (
    sp3 => [
        'ShortPut::Delta',
        {
            dte           => '90+',
            delta         => '3+',
            profit_target => 50,
            multiple      => 25,
        },
    ],
    sp80 => [
        'ShortPut::Percent',
        {
            dte           => '90+',
            percent       => 80,
            profit_target => 50,
            multiple      => 25,
        },
    ],
    falde => [
        'Falde604020',
        {
            dte           => '60+',
            delta_percent => 30,
            round_turn    => 1.23,
        },
    ],
);

my $config = $CONFIG{$ARGV[0] || 'sp3'};
my $class  = 'BT::Preset::' . $config->[0];
my $params = $config->[1];


my $symbol = BT::Symbol->new(
    id => 1,
);

my $preset = $class->new(params => $params);

my $bt = BT::Mainloop->new(
    symbol => $symbol,
    params => $preset->_params('general'),
    preset => $preset,
);

$bt->run;
pp $bt->trades->[-1]->exit_balance;

my $stats = $bt->stats;
pp $stats;
pp $bt->trades->[-1]->properties;
