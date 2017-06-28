#!/usr/bin/env perl

use Mojo::Base -strict;

use Data::Dump qw/pp/;

use lib 'lib';
use BT::Preset::Falde604020;


my $p = BT::Preset::Falde604020->new(
    dte           => '60+',
    delta_percent => 30,
);

pp $p;
pp $p->all_params;
