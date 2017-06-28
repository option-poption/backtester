package BT::Symbol;

use Mojo::Base -base;

has id         => 1;
has multiplier => 50;
has divider    => 100;

sub factor { $_[0]->multiplier / $_[0]->divider }

1;
