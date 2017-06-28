package BT::Params;

use Mojo::Base -strict;

# strategy

sub DTE {
    return {
        name        => 'dte',
        label       => 'DTE',
        default     => shift || '90+',
        type        => 'int-range',
        description => 'Days till Expiration',
    };
}

sub Delta {
    return {
        name        => 'delta',
        label       => 'Delta',
        default     => shift || 3,
        type        => 'float-range',
        description => 'Select Strike based on Delta',
    };
}

sub Percent {
    return {
        name        => 'percent',
        label       => 'Percent',
        default     => shift || 80,
        type        => 'float',
        description => 'Select Strike based on ... % of Underlying',
    };
}

# target

sub ProfitTarget {
    return {
        name        => 'profit_target',
        label       => 'Target',
        default     => shift || 50,
        type        => 'float',
        description => 'Profit Target in %',
    };
}

# general

sub general_params {
    return [
        {
            name        => 'account',
            label       => 'Account',
            default     => 100_000,
            type        => 'float',
            description => 'Starting account balance',
        },
        {
            name        => 'round_turn',
            label       => 'RT',
            default     => '8.12', # TODO
            type        => 'float',
            description => 'Round Turn (incl. exchange fees)',
        },
        {
            name        => 'multiple',
            label       => 'Multiple',
            default     => '',
            type        => 'float',
            description => 'Restrict Strikes to multiples of ... (e. g. 25)',
        },
        {
            name        => 'stress_test',
            label       => 'Stress Test',
            default     => '',
            type        => 'bool',
            description => 'Start a new trade every day (useful to check max. margin)',
        },
    ];
}

1;

