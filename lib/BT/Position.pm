package BT::Position;

use Mojo::Base -base;

use overload '""' => 'to_string';

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

    return $price / $self->symbol->divider;
}

sub delta {
    my ($self) = @_;

    my $delta = 0;
    foreach my $leg (@{$self->legs}) {
        $delta += $leg->[0] * $leg->[1]->span_delta;
    }

    return $delta;
}

sub to_string {
    my ($self) = @_;

    my $out = sprintf("Price: %s, Margin: %.0f\n", $self->price, $self->margin);
    foreach my $leg (@{$self->legs}) {
        $out .= sprintf("%3d %s\n", $leg->[0], $leg->[1]);
    }

    return $out;
}

1;
