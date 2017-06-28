package BT::Sizing::IMFactor;

use Mojo::Base 'BT::Sizing';

has 'im_factor';

sub params {
    return [
        {
            name        => 'im_factor',
            label       => 'IM x',
            default     => 6,
            type        => 'float',
            description => 'Keep ... times Initial Margin in cash',
        },
    ];
}

sub size {
    my ($self, %arg) = @_;

    my $balance  = $arg{balance}  or die 'BALANCE missing';
    my $position = $arg{position} or die 'POSITION missing';
    my $margin   = $arg{margin}   or die 'MARGIN missing';

    return int($balance / $margin / $self->im_factor);
}

1;
