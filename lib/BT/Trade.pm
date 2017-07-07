package BT::Trade;

use Mojo::Base -base;

has [qw/symbol round_turn/];
has [qw/entry_position entry_balance entry_underlying/];
has [qw/exit_position exit_balance exit_underlying exit_reason/];

has 'size';
has 'initial_margin';

has current_position => sub { shift->entry_position };
has adjustments      => sub { [] };
has properties       => sub { {} };

has min_price => sub { shift->entry_position->price };
has max_price => sub { shift->entry_position->price };

has min_margin => sub { shift->initial_margin };
has max_margin => sub { shift->initial_margin };

has min_underlying => sub { shift->entry_underlying };
has max_underlying => sub { shift->entry_underlying };

has 'max_margin_to_nlv';

has dte => sub { (shift)->entry_position->first_option->dte };
has dit => sub {
    my ($self) = @_;

    return $self->dte - $self->exit_position->first_option->dte;
};

has profit => sub {
    my ($self) = @_;

    # TODO adjustments

    my $profit = ($self->exit_position->price - $self->entry_position->price) * $self->symbol->multiplier;
    my $fees   = $self->entry_position->contracts * $self->round_turn;

    return $profit - $fees;
};

has total_profit => sub {
    my ($self) = @_;
    return $self->size * $self->profit;
};

has daily_profit => sub {
    my ($self) = @_;
    return $self->profit / $self->dit;
};

has margin_factor => sub {
    my ($self) = @_;
    return $self->max_margin / $self->initial_margin;
};

sub is_closed { shift->exit_position }


1;
