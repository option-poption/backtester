package BT::Stats;

use Mojo::Base -base;

my %STAT = (
    dte => {
        label => 'DTE',
        calc  => sub { shift->dte },
    },
    dit => {
        label => 'DIT',
        calc  => sub { shift->dit },
    },
    entry_price => {
        label => 'Entry Price',
        calc  => sub { shift->entry_position->price },
    },
    min_price => {
        label => 'Min. Price',
        calc  => sub { shift->min_price },
    },
    max_price => {
        label => 'Max. Price',
        calc  => sub { shift->max_price },
    },
    price_factor => {
        label => 'Price Factor',
        calc  => sub {
            my ($trade) = @_;
            my $entry_price = $trade->entry_position->price;
            $entry_price ? $trade->min_price / $entry_price : undef;
        },
        finish => sub { grep defined, @_ },
    },
    profit => {
        label => 'Profit',
        calc  => sub { shift->profit },
    },
    daily_profit => {
        label => 'Daily Profit',
        calc  => sub { shift->daily_profit },
    },
    winner => {
        label => 'Winner',
        calc  => sub {
            my $profit = shift->profit;
            $profit > 0 ? $profit : undef;
        },
        finish => sub { grep defined, @_ },
    },
    looser => {
        label => 'Looser',
        calc  => sub {
            my $profit = shift->profit;
            $profit <= 0 ? $profit : undef;
        },
        finish => sub { grep defined, @_ },
    },
    initial_margin => {
        label => 'Initial Margin',
        calc  => sub { shift->initial_margin },
    },
    min_margin => {
        label => 'Min. Margin',
        calc  => sub { shift->min_margin },
    },
    max_margin => {
        label => 'Max. Margin',
        calc  => sub { shift->max_margin },
    },
    margin_factor => {
        label => 'Margin Factor',
        calc  => sub { shift->margin_factor },
    },
);

sub stats { \%STAT }

1;
