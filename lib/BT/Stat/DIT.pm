package BT::Stat::DIT;

use Mojo::Base 'BT::Stat';

sub name { 'DIT' }

sub calc {
    my ($self, $trade) = @_;

    my $entry = $trade->entry_position->first_option->dte;
    my $exit  = $trade->exit_position->first_option->dte;

    return $entry - $exit;
}

1;
