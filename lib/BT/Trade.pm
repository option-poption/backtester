package BT::Trade;

use Mojo::Base -base;

has 'symbol';
has 'round_turn';

has 'entry_position';
has 'entry_balance';
has 'entry_underlying';

has 'size';
has 'initial_margin';

has current_position => sub { shift->entry_position };
has adjustments      => sub { [] };

has 'exit_position';
has 'exit_balance';
has 'exit_underlying';

has 'min_price';
has 'max_price';

has 'min_underlying';
has 'max_underlying';

has 'max_margin_to_nlv';

has profit => sub {
    my ($self) = @_;

    # TODO adjustments

    my $profit = ($self->exit_position->price - $self->entry_position->price) * $self->symbol->factor;
    my $fees   = $self->entry_position->contracts * $self->round_turn;

    return $profit - $fees;
};

has total_profit => sub {
    my ($self) = @_;
    return $self->size * $self->profit;
};

sub is_closed { shift->exit_position }


1;
