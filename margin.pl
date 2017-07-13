#!/usr/bin/env perl

use Mojo::Base -strict;

use Date::Simple qw/date/;

use lib 'lib';
use BT;


my $dte        = '240+';
my @legs       = ([-2, 1800], [3, 1650]);
my $start_date = date('2015-08-17');
my $end_date   = date('2015-09-01');

my $symbol = BT::Symbol->new(id => 1);
my $db     = BT::DB->new(symbol => $symbol);
my $at     = $start_date;
my $dates  = $db->valid_dates;

my $expiration = $db->expiration(at => $at, dte => $dte);

my $position = BT::Position->new(symbol => $symbol);
foreach my $leg (@legs) {
    $position->add(
        $leg->[0],
        $db->strike_option(
            at         => $at,
            strike     => $leg->[1],
            expiration => $expiration,
        )
    )
}

while ($at <= $end_date) {
    next unless $dates->{$at};
    my $pos = $db->position_at($position, $at);
    next unless $pos;

    printf(
        "%s: Price = %.2f, Margin = %.2f\n",
        $at,
        $pos->price,
        $pos->margin,
    );
} continue {
    $at = $at->next;
}
