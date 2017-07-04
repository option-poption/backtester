package BT::Stat;

use Mojo::Base -base;


has data => sub { [] };
has [qw/min max avg median count/];


sub add {
    my ($self, $trade) = @_;

    push @{$self->data}, $self->calc($trade);
}

sub finish {
    my ($self) = @_;

    my @data  = sort { $a <=> $b } @{$self->data};
    my $count = scalar @data;
    my $sum   = 0;
    $sum += $_ foreach (@data);

    $self->min($data[0]);
    $self->max($data[-1]);
    $self->avg($sum/$count);
    $self->count($count);

    # median - https://stackoverflow.com/questions/11955728/how-to-calculate-the-median-of-an-array
    my $middle = int($count / 2);
    if ($count % 2) {
        $self->median($data[$middle]);
    } else {
        $self->median(
            ($data[$middle] + $data[$middle - 1]) / 2
        );
    }
}

1;
