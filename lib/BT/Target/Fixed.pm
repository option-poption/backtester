package BT::Target::Fixed;

use Mojo::Base 'BT::Target';

use BT::Params;

has [qw/time_exit profit_target/];

sub params {
    return [
        BT::Params::TimeExit(7),
        {
            name        => 'profit_target',
            label       => 'Profit Target',
            default     => 500,
            type        => 'float',
            description => 'Profit Target (in Dollars) per Lot',
        },
    ];
}

sub check_position {
    my ($self, %arg) = @_;

    my $db         = $arg{db}         or die 'DB missing';
    my $symbol     = $arg{symbol}     or die 'SYMBOL missing';
    my $preset     = $arg{preset}     or die 'PRESET missing';
    my $trade      = $arg{trade}      or die 'TRADE missing';
    my $position   = $arg{position}   or die 'POSITION missing';
    my $underlying = $arg{underlying} or die 'UNDERLYING missing';

    # Profit Target
    my $entry  = $trade->entry_position->price;
    my $profit = ($position->price - $entry) * $symbol->multiplier;

    if ($profit >= $self->profit_target) {
        $trade->exit_reason('TAKE_PROFIT');
        $trade->exit_position($position);
        $trade->exit_underlying($underlying);

        return 'EXIT';
    }

    # Time Exit
    if ($self->time_exit && $position->first_option->dte < $self->time_exit) {
        $trade->exit_reason('TIME_EXIT');
        $trade->exit_position($position);
        $trade->exit_underlying($underlying);

        return 'EXIT';
    }

    return '';
}

1;
