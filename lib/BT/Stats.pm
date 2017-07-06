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
    profit => {
        label => 'Profit',
        calc  => sub { shift->profit },
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
);

sub stats { \%STAT }

1;
