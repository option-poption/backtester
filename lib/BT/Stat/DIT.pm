package BT::Stat::DIT;

use Mojo::Base 'BT::Stat';

sub name  { 'dit' }
sub label { 'DIT' }
sub calc  { $_[1]->dit }

1;
