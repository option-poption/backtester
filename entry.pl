#!/usr/bin/env perl

use Mojo::Base -strict;

use Date::Simple qw/date today/;;

use lib 'lib';
use BT;


my ($config) = @ARGV;
$config ||= 'falde';

my $preset = BT::Config->preset($config);

my $start_date = date('2017-01-01');
my $end_date   = today;

my $symbol = BT::Symbol->new(id => 1);
my $db     = BT::DB->new(symbol => $symbol);

my $dates = $db->valid_dates;
my $today = $start_date;
$today->default_format('%Y-%m-%d');
while ($today <= $end_date) {
    # check for valid day
    next unless $dates->{$today->format};

    my $position = $preset->entry(
        db     => $db,
        at     => $today,
        symbol => $symbol,
    );
    next unless $position;

    my $underlying = $db->underlying(
        at       => $today,
        position => $position,
    );

    my @strikes = map { $_->strike } $position->options;
    my $regt_risk = 2 * $strikes[1] - $strikes[0] - $strikes[2];

    printf(
        "%s: %.2f (%d DTE) %.2f %s %d %.2f\n",
        $today,
        $position->price,
        $position->first_option->dte,
        $underlying,
        join('/', @strikes),
        $regt_risk,
        $position->delta * 100,
    );
} continue {
    $today = $today->next;
}
