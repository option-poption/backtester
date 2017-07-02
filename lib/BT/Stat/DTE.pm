package BT::Stat::DTE;

use Mojo::Base 'BT::Stat';

sub name { 'DTE' }

sub calc {
    my ($self, $trade) = @_;

    return $trade->entry_position->first_option->dte;
}

1;
