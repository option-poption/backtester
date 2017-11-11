#!/usr/bin/env perl

use Mojo::Base -strict;

use feature qw/say/;

use Data::Dump qw/pp/;
use Date::Simple;
use Mojo::File;
use Mojo::JSON;

use lib 'lib';
use BT;

$ENV{OP_BT_ZERO_OK} = 1;

my $CONFIG = Mojo::JSON::decode_json(Mojo::File->new('config-factory.json')->slurp);

my $config = $CONFIG->{shift @ARGV || 'bsh'};
my $scale  = 6 / $config->{short_size};

foreach my $override (@ARGV) {
    my ($key, $value) = split(/=/, $override);
    $config->{$key} = $value;
}

# scale up - to same number of shorts (to make them comparable)
$config->{short_size} *= $scale;
$config->{long_size} *= $scale;

my $balance = 100_000;
my $half_turn = 2.06;

my $symbol = BT::Symbol->new(id => 1);
my $db     = BT::DB->new(symbol => $symbol);

$db->memoize_option;

my @positions = ();
my $total_pos = BT::Position->new(symbol => $symbol);

my $dates    = $db->valid_dates;
my $today    = Date::Simple->new('2015-01-01');
my $end_date = Date::Simple->new('2015-09-01');

my $limit = undef;
my $min_max = {
    min_price => 0,
    max_price => 0,
    max_margin => 0,
};
while ($today <= $end_date) {
    # check for valid day
    next unless $dates->{$today->format};

    # check for expiration
    my $expired = $total_pos->expire($today->format);
    if (defined $expired) {
        foreach my $pos (@positions) {
            $pos->expire($today->format);
        }

        @positions = grep { @{$_->legs} } @positions;
    }

    # refresh quotes
    $total_pos = $db->position_at($total_pos, $today);
    foreach my $pos (@positions) {
        $pos = $db->position_at($pos, $today);
    }

    # check for (early) profit targets
    # TODO

    # limit order for long puts?
    if ($limit) {
        my $option = $db->strike_option(
            at         => $today,
            expiration => $limit->{expiration},
            call_put   => 'P',
            strike     => $limit->{strike},
        );
        next unless $option;

        if ($option->settlement_price <= $limit->{price}) {
            # buy long puts
            $positions[-1]->add($limit->{size}, $option);
            $total_pos->add($limit->{size}, $option);

            $balance -= $limit->{size} * ($limit->{price} * $symbol->factor + $half_turn);

            # sell new shorts
            $limit = undef;
        }
    }

    # sell short puts?
    unless ($limit) {
        # check net short puts?
        my $puts = 0;
        foreach my $leg (@{$total_pos->legs}) {
            $puts += $leg->[0];
        }

        my $dte = $config->{initial_dte};
        $dte = $config->{dte} if $puts >= $config->{short_size};
        my $expiration = $db->expiration(
            at  => $today,
            dte => $dte,
        );
        next unless $expiration;

        my $option = $db->price_option(
            at         => $today,
            expiration => $expiration,
            call_put   => 'P',
            price      => $config->{short_price},
            multiple   => $config->{multiple},
        );
        next unless $option;

        # sell short puts
        my $size = 1;

        my $position = BT::Position->new(symbol => $symbol);
        $position->add(-$config->{short_size} * $size, $option);
        push @positions, $position;
        $total_pos->add(-$config->{short_size} * $size, $option);

        $balance += $config->{short_size} * $size *
            ($option->settlement_price * $symbol->factor - $half_turn);

        # set limit order to buy puts
        my $strike = $option->strike - $config->{long_distance};
        my $price = $option->settlement_price * $config->{short_size} / $config->{long_size};
        # TODO round
        $limit = {
            size       => $config->{long_size} * $size,
            expiration => $expiration,
            strike     => $strike,
            price      => $price,
        };
    }
} continue {
    if ($dates->{$today->format}) {
        my $date   = $today->format;
        my $price  = $total_pos->price;
        my $margin = $total_pos->margin;

        printf(
            "%s | P:%6.2f | M:%5.0f | B:%6.0f | U:%4.0f \n",
            $today,
            $price,
            $margin,
            $balance,
            $db->underlying(at => $today, position => $total_pos),
        );

        # check for new extreme values
        if ($price > $min_max->{max_price}) {
            $min_max->{max_price} = $price;
            $min_max->{max_price_date} = $date;
        }
        if ($price < $min_max->{min_price}) {
            $min_max->{min_price} = $price;
            $min_max->{min_price_date} = $date;
        }
        if ($margin > $min_max->{max_margin}) {
            $min_max->{max_margin} = $margin;
            $min_max->{max_margin_date} = $date;
        }
    }

    if ($today->format eq '2015-08-24') {
        say $total_pos;
        #say $_ foreach (@positions);
    }

    $today = $today->next;
}

pp $config;
pp $min_max;
