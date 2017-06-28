package BT::Strategy;

use Mojo::Base -base;

has params => sub { [] };


sub entry { die '...' }

sub check_position { die '...' }

1;
