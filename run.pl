#!/usr/bin/env perl

use Mojo::Base -strict;

use Data::Dump qw/pp/;
use Module::Find qw/useall/;

use lib 'lib';
use BT::Mainloop;
use BT::Symbol;
useall 'BT::Preset';
useall 'BT::Stat';


my $symbol = BT::Symbol->new(
    id => 1,
);

my $params = {
    dte           => '90+',
    delta         => '3+',
    profit_target => 50,
    multiple      => 25,
};

my $preset = BT::Preset::ShortPut::Delta->new(
    params => $params,
);

my $bt = BT::Mainloop->new(
    symbol => $symbol,
    params => $preset->_params('general'),
    preset => $preset,
);

$bt->run;
pp $bt->trades->[-1]->exit_balance;

my @stats = $bt->stats;
foreach my $stat (@stats) {
    printf(
        "%s: min=%d, max=%d, avg=%d, med=%d\n",
        $stat->name,
        $stat->min,
        $stat->max,
        $stat->avg,
        $stat->median,
    );
}
pp $bt->trades->[-1]->properties;
