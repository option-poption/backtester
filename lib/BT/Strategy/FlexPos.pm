package BT::Strategy::FlexPos;

use Mojo::Base 'BT::Strategy';

use Data::Dump qw/pp/;

use BT::Position;

has 'description';

has [qw/ratio dte delta percent width/] => sub { [] };
has [qw/account round_turn stress_test multiple/];

sub entry {
    my ($self, %arg) = @_;

    my $db     = $arg{db}     or die 'DB missing';
    my $at     = $arg{at}     or die 'AT missing';
    my $symbol = $arg{symbol} or die 'SYMBOL missing';

    my $position = BT::Position->new(symbol => $symbol);

    my $option;
    for (my $i = 0; $i < @{$self->ratio}; $i++) {
        my $ratio   = $self->ratio->[$i];
        my $dte     = $self->dte->[$i];
        my $delta   = $self->delta->[$i];
        my $percent = $self->percent->[$i];
        my $width   = 0;
        $width = $self->width->[$i - 1] if $i > 0;

        my $expiration = $db->expiration(
            at        => $at,
            dte       => $dte,
        );
        unless ($expiration) {
            warn "Could not get expiration for DTE '$dte'";
            return;
        }

        if ($percent) {
            $option = $db->percent_option(
                at         => $at,
                expiration => $expiration,
                percent    => $percent,
            );
            unless ($option) {
                warn "Could not get option for PERCENT '$percent'";
                return;
            }
        } elsif ($delta) {
            $option = $db->delta_option(
                at         => $at,
                expiration => $expiration,
                delta      => $delta,
            );
            unless ($option) {
                warn "Could not get option for DELTA '$delta'";
                return;
            }
        } elsif ($width) {
            my $strike = $option->strike + $width;
            $option = $db->strike_option(
                at         => $at,
                expiration => $expiration,
                strike     => $strike,
            );
            unless ($option) {
                warn "Could not get option for STRIKE '$strike'";
                return;
            }
        } else {
            die 'Neither percent nor delta given';
        }

        $position->add($ratio, $option);
    }

    return $position;
}

sub check_position {
    my ($self, %arg) = @_;

    my $db         = $arg{db}         or die 'DB missing';
    my $symbol     = $arg{symbol}     or die 'SYMBOL missing';
    my $preset     = $arg{preset}     or die 'PRESET missing';
    my $trade      = $arg{trade}      or die 'TRADE missing';
    my $position   = $arg{position}   or die 'POSITION missing';
    my $underlying = $arg{underlying} or die 'UNDERLYING missing';

    # check profit target
    my $entry  = $trade->entry_position->price;
    my $profit = ($position->price - $entry) * $symbol->multiplier;

    my $percent = $preset->target->profit_target / 100;
    my $target  = (-$entry) * $symbol->multiplier * $percent;

    if ($profit >= $target) {
        $trade->exit_reason('TAKE_PROFIT');
        $trade->exit_position($position);
        $trade->exit_underlying($underlying);

        return 'EXIT';
    }

    return '';
}

1;
