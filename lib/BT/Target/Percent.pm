package BT::Target::Percent;

use Mojo::Base 'BT::Target';

use BT::Params;

has [qw/time_exit profit_target/];

sub params {
    return [
        BT::Params::TimeExit(7),
        {
            name        => 'profit_target',
            label       => 'Target %',
            default     => 50,
            type        => 'float',
            description => 'Profit Target in %',
        }
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

    # Profit Target (in percent)
    my $entry  = $trade->entry_position->price;
    my $profit = ($position->price - $entry) * $symbol->multiplier;

    my $percent = $self->profit_target / 100;
    my $target  = (-$entry) * $symbol->multiplier * $percent;

    if ($profit >= $target) {
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
