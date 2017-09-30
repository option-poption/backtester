#!/usr/bin/env perl

use Mojo::Base -strict;

use Data::Dump qw/pp/;

use lib 'lib';
use BT;


my ($config, $debug) = @ARGV;

my $bt = BT::Mainloop->new(
    preset => BT::Config->preset($config || 'sp3'),
);

$bt->run;
pp int($bt->balance);

my $stats = $bt->stats;

if ($debug) {
    pp $stats;
} else {
    my $out = {};
    foreach (qw/dit margin_factor price_factor profit winner/) {
        $out->{$_} = $stats->{$_};
        delete $out->{$_}->{label};

        $out->{$_} = $stats->{$_}->{max} if $_ eq 'margin_factor';
        $out->{$_} = $stats->{$_}->{min} if $_ eq 'price_factor';
    }
    pp $out;
}

pp $bt->exit_reasons;

foreach my $trade (@{$bt->trades}) {
    my $props = $trade->properties;
    if ($debug || $props->{profit} < 0 || $props->{margin_factor} > 2) {
        $props->{entry_date}      .= '';
        $props->{exit_date}       .= '';
        $props->{expiration_date} .= '';
        pp $props;
    }
}
