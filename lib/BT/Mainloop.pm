package BT::Mainloop;

use Mojo::Base -base;

use Data::Dump qw/pp/;
use DateTime;

use BT::DB;
use BT::Trade;


has db => sub { BT::DB->new };

has [qw/params preset symbol/];

has start_date => sub {
    DateTime->new(
        year  => 2013,
        month => 1,
        day   => 1,
    );
};

has end_date => sub { DateTime->today };

has today       => sub { $_[0]->start_date };
has balance     => sub { $_[0]->params->{account} };
has round_turn  => sub { $_[0]->params->{round_turn} };
has stress_test => sub { $_[0]->params->{stress_test} };

has open     => sub { [] };
has trades   => sub { [] };
has equity   => sub { {} };

sub run {
    my ($self) = @_;

    my $dates = $self->db->valid_dates($self->symbol->id);

    while ($self->today <= $self->end_date) {
        # check for valid day
        next unless $dates->{$self->today->ymd('-')};

        print $self->today->dmy('.') . "\n";

        foreach my $trade (@{$self->open}) {
            $self->update($trade);
        }

        # $self->_update_equity(...);

        # remove closed trades
        $self->open([grep { !$_->is_closed } @{$self->open}]);

        # re-open trade on same day as exit
        if (!@{$self->open} or $self->stress_test) {
            $self->entry;
        }
    }
    continue {
        $self->today($self->today->add(days => 1));
    }
}

sub entry {
    my ($self) = @_;

    my $position = $self->preset->entry(
        db     => $self->db,
        at     => $self->today,
        symbol => $self->symbol,
    );
    return unless $position;

    my $margin = $position->initial_margin;

    my $size = $self->preset->size(
        balance  => $self->balance,
        position => $position,
        margin   => $margin,
    );

    my $underlying = $self->db->underlying(
        $position, $self->today,
    );

    my $amount  = $position->price * $self->symbol->factor;
    my $fees    = $self->round_turn * $position->contracts;
    my $balance = $self->balance + $size * ($amount - $fees);

    my $trade = BT::Trade->new(
        symbol           => $self->symbol,
        round_turn       => $self->round_turn,
        entry_position   => $position,
        entry_balance    => $balance,
        entry_underlying => $underlying,
        size             => $size,
        initial_margin   => $margin,
    );

    push @{$self->open}, $trade;

    return;
}

sub update {
    my ($self, $trade) = @_;

    my $position = $self->db->position_at(
        $trade->current_position,
        $self->today,
    );
    return unless $position;

    # $self->_update_equity(...);

    my $underlying = $self->db->underlying(
        $position, $self->today,
    );

    my $action = $self->preset->check_position(
        db         => $self->db,
        preset     => $self->preset,
        trade      => $trade,
        position   => $position,
        underlying => $underlying,
    );

    if ($action eq 'EXIT') {
        $self->balance(
            $self->balance + $trade->total_profit
        ) unless $self->stress_test;

        $trade->exit_balance($self->balance);

pp $trade;

        push @{$self->trades}, $trade;
        return 1;
    }

    return;
}

1;
