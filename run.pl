#!/usr/bin/env perl

use Mojo::Base -strict;

use Data::Dump qw/pp/;

use lib 'lib';
use BT;


my ($config, $debug) = @ARGV;

my $bt = BT::Mainloop->new(
    preset => BT::Config->preset($config),
);

$bt->run;
pp $bt->balance;

pp $bt->stats;

pp $bt->exit_reasons;

if ($debug) {
    foreach my $trade (@{$bt->trades}) {
        my $props = $trade->properties;
        $props->{entry_date}      .= '';
        $props->{exit_date}       .= '';
        $props->{expiration_date} .= '';
        pp $props;
    }
}
