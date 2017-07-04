package BT::Strategy::FlexPos;

use Mojo::Base 'BT::Strategy';

use Data::Dump qw/pp/;

use BT::Position;

has 'dbh';
has 'symbol';
has 'description';

has [qw/ratio dte delta percent width/] => sub { [] };
has [qw/account round_turn stress_test multiple/];

sub entry {
    my ($self, %arg) = @_;

    my $db     = $arg{db}     or die 'DB missing';
    my $at     = $arg{at}     or die 'AT missing';
    my $symbol = $arg{symbol} or die 'SYMBOL missing';

    my $position = BT::Position->new(symbol => $symbol);

    for (my $i = 0; $i < @{$self->ratio}; $i++) {
        my $ratio   = $self->ratio->[$i];
        my $dte     = $self->dte->[$i];
        my $delta   = $self->delta->[$i];
        my $percent = $self->percent->[$i];

        my $expiration = $db->expiration(
            symbol_id => $symbol->id,
            at        => $at,
            dte       => $dte,
        );
        unless ($expiration) {
            warn "Could not get expiration for DTE '$dte'";
            return;
        }

        my $option;
        if ($percent) {
            $option = $db->percent_option(
                symbol_id  => $symbol->id,
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
                symbol_id  => $symbol->id,
                at         => $at,
                expiration => $expiration,
                delta      => $delta,
            );
            unless ($option) {
                warn "Could not get option for DELTA '$delta'";
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
    my $preset     = $arg{preset}     or die 'PRESET missing';
    my $trade      = $arg{trade}      or die 'TRADE missing';
    my $position   = $arg{position}   or die 'POSITION missing';
    my $underlying = $arg{underlying} or die 'UNDERLYING missing';

    # check profit target
    my $entry  = $trade->entry_position->price;
    my $profit = $position->price - $entry;

    my $percent = $preset->target->profit_target / 100;
    my $target  = (-$entry) * $percent;

    if ($profit >= $target) {
        $trade->exit_reason('TAKE_PROFIT');
        $trade->exit_position($position);
        $trade->exit_underlying($underlying);

        return 'EXIT';
    }

    return '';
}

1;
