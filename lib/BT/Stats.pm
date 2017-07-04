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
);

sub stats { \%STAT }

1;
