package BT::Sizing::IMFactor;

use Mojo::Base 'BT::Sizing';

has [qw/im_factor margin_factor/];

sub params {
    return [
        {
            name        => 'im_factor',
            label       => 'IM x',
            default     => 6,
            type        => 'float',
            description => 'Keep ... times Initial Margin in cash',
        },
        {
            name        => 'margin_factor',
            label       => 'Margin Factor',
            default     => 1,
            type        => 'float',
            description => 'Model higher Margin Requirements',
        },
    ];
}

sub size {
    my ($self, %arg) = @_;

    my $balance  = $arg{balance}  or die 'BALANCE missing';
    my $position = $arg{position} or die 'POSITION missing';
    my $margin   = $arg{margin}   or die 'MARGIN missing';

    $margin *= $self->margin_factor;

    return int($balance / $margin / $self->im_factor);
}

1;
