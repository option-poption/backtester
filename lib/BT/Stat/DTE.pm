package BT::Stat::DTE;

use Mojo::Base 'BT::Stat';

sub name  { 'dte' }
sub label { 'DTE' }
sub calc  { $_[1]->dte }

1;
