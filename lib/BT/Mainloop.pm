package BT::Mainloop;

use Mojo::Base -base;

use Date::Simple;


has 'preset';

has symbol => sub { BT::Symbol->new(id => 1) };
has db     => sub { BT::DB->new(symbol => shift->symbol) };
has params => sub { shift->preset->_params('general') };

has start_date => sub { Date::Simple->new('2013-01-01') };
has end_date   => sub { Date::Simple->today };

has today       => sub { $_[0]->start_date };
has balance     => sub { $_[0]->params->{account} };
has round_turn  => sub { $_[0]->params->{round_turn} };
has stress_test => sub { $_[0]->params->{stress_test} };

has open     => sub { [] };
has trades   => sub { [] };
has equity   => sub { {} };


sub run {
    my ($self) = @_;

    my $dates = $self->db->valid_dates;

    $self->today->default_format('%Y-%m-%d');

    while ($self->today <= $self->end_date) {
        # check for valid day
        next unless $dates->{$self->today->format};

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
        $self->today($self->today->next);
    }
}

sub stats {
    my ($self) = @_;

    my %data = ();

    foreach my $trade (@{$self->trades}) {
        while (my ($key, $stat) = each %{BT::Stats->stats}) {
            push @{$data{$key}}, $stat->{calc}->($trade);
        }
        while (my ($key, $prop) = each %{BT::Props->props}) {
            $trade->properties->{$key} = BT::Props->calc($key, $trade);
        }
    }

    my %stat = ();
    while (my ($key, $stat) = each %{BT::Stats->stats}) {
        my @data = @{$data{$key}};
        if ($stat->{finish}) {
            @data = $stat->{finish}->(@data);
        }

        @data = sort { $a <=> $b } @data;

        my $count = scalar @data;
        next if $count == 0;

        my $sum   = 0;
        $sum += $_ foreach (@data);

        $stat{$key} = {
            label => $stat->{label},
            min   => $data[0],
            max   => $data[-1],
            avg   => $sum / $count,
            count => $count,
        };

        # median - https://stackoverflow.com/questions/11955728/how-to-calculate-the-median-of-an-array
        my $middle = int($count / 2);
        if ($count % 2) {
            $stat{$key}{median} = $data[$middle];
        } else {
            $stat{$key}{median} = ($data[$middle] + $data[$middle - 1]) / 2;
        }
    }

    return \%stat;
}

sub exit_reasons {
    my ($self) = @_;

    my %reason = ();

    foreach my $trade (@{$self->trades}) {
        $reason{$trade->exit_reason}++;
    }

    return \%reason;
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
        symbol   => $self->symbol,
        balance  => $self->balance,
        position => $position,
        margin   => $margin,
    );

    my $underlying = $self->db->underlying(
        position  => $position,
        at        => $self->today,
    );

    my $amount  = $position->price * $self->symbol->multiplier;
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

    # update min/max price
    my $price = $position->price;
    $trade->min_price($price) if $price < $trade->min_price;
    $trade->max_price($price) if $price > $trade->max_price;

    # update min/max margin
    my $margin = $position->margin;
    $trade->min_margin($margin) if $margin < $trade->min_margin;
    $trade->max_margin($margin) if $margin > $trade->max_margin;

    # update min/max underlying
    my $underlying = $self->db->underlying(
        position => $position,
        at       => $self->today,
    );
    $trade->min_underlying($underlying) if $underlying < $trade->min_underlying;
    $trade->max_underlying($underlying) if $underlying > $trade->max_underlying;

    my $action = $self->preset->check_position(
        db         => $self->db,
        symbol     => $self->symbol,
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

        push @{$self->trades}, $trade;
        return 1;
    }

    return;
}

1;
