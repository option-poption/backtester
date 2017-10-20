#!/usr/bin/env perl

use Mojo::Base -strict;

use Date::Simple qw/date/;
use List::Util qw/min/;

use lib 'lib';
use BT;


my @expiration = (
    date('2018-06-15'),
    date('2018-09-21'),
);
my @strikes = (
    1400, 1450, 1500, 1550,
    1600, 1650, 1700, 1750,
    1800, 1850, 1900, 1950,
    2000, 2050, 2100, 2150,
    2200, 2250, 2300, 2350,
);

my $symbol = BT::Symbol->new(id => 1);
my $db     = BT::DB->new(symbol => $symbol);
my $dates  = $db->valid_dates;

my $at = (sort keys %$dates)[-1];
print "$at\n";

# Header
print '    ';
foreach my $expiration (@expiration) {
    print ' | ' . $expiration->format;
}
print "\n";

foreach my $strike (@strikes) {
    print $strike;
    foreach my $expiration (@expiration) {
        my $option = $db->strike_option(
            at         => $at,
            expiration => $expiration,
            strike     => $strike,
            call_put   => 'P',
        );

        printf(' | %5.2f - %5.2f', $option->settlement_price / $symbol->divider, margin($option));
    }
    print "\n";
}

sub margin {
    my ($option) = @_;

    return -min(@{$option->values});
}
