package BT::Position;

use Mojo::Base -base;


has legs => sub { [] };
has 'symbol';


sub add {
    my ($self, $ratio, $option) = @_;
    push @{$self->legs}, [$ratio, $option];
}

sub options        { map { $_->[1] } @{$_[0]->legs} }
sub first_option   { $_[0]->legs->[0]->[1] }
sub initial_margin { $_[0]->margin * 1.1 }

sub contracts {
    my ($self) = @_;

    my $contracts = 0;
    foreach my $leg (@{$self->legs}) {
        $contracts += abs($leg->[0]);
    }

    return $contracts;
}

sub margin {
    my ($self) = @_;

    my $max_margin = 0;
    foreach my $i (0..15) {
        my $margin = 0;
        foreach my $leg (@{$self->legs}) {
            $margin += $leg->[0] * $leg->[1]->values->[$i]; # ratio * valueX
        }
        $max_margin = $margin if $margin > $max_margin;
    }

    return $max_margin;
}

sub price {
    my ($self) = @_;

    my $price = 0;
    foreach my $leg (@{$self->legs}) {
        $price += $leg->[0] * $leg->[1]->settlement_price;
    }

    return $price;
}


1;

