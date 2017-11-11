package BT::DB;

use Mojo::Base -base;

use Data::Dump qw/pp/;
use DBI;
use Memoize;

use BT::Option;


has 'symbol';

has dbh => sub {
    DBI->connect(
        'dbi:mysql:span:mysql',
        'admin',
        'admin',
        {RaiseError => 1},
    );
};

sub memoize_option {
    memoize('option');
}

sub valid_dates {
    my ($self) = @_;

    return $self->dbh->selectall_hashref(
        'SELECT * FROM dates WHERE symbol_id=?',
        'at',
        {},
        $self->symbol->id,
    );
}

sub underlying {
    my ($self, %arg) = @_;

    my $at         = $arg{at} or die 'AT missing';
    my $position   = $arg{position};
    my $expiration = $arg{expiration};

    if (!$position && !$expiration) {
        die 'POSITION or EXPIRATION missing';
    }

    my $month;
    if ($position) {
        $month = $position->first_option->futures_contract_month;
    } else {
        # get any option (for futures contract month)
        ($month) = $self->dbh->selectrow_array(
            'SELECT futures_contract_month FROM options WHERE symbol_id = ? AND at = ? AND call_put = ? AND expiration = ? AND settlement_price > 0 LIMIT 1',
            {},
            $self->symbol->id, $at, 'P', $expiration,
        );
    }

    my ($price) = $self->dbh->selectrow_array(
        'SELECT settlement_price FROM futures WHERE symbol_id=? AND at=? AND contract_month=?',
        {},
        $self->symbol->id, $at, $month,
    );
    $price ||= 0;

    return $price / $self->symbol->divider;
}

sub option {
    my ($self, $option, $at) = @_;

    my $sql = 'SELECT * FROM options
    WHERE symbol_id=?
      AND at=?
      AND expiration=?
      AND call_put=?
      AND strike=?';

    my $row = $self->dbh->selectrow_hashref(
        $sql, {},
        $option->symbol_id,
        $at,
        $option->expiration,
        $option->call_put,
        $option->strike,
    );
    unless ($row) {
        warn "Skipping (option): at=$at";
        return;
    }

    # fix settlement price
    if ($row->{settlement_price} == 9_999_999) {
        warn "Settlement Price zero: at=$at" unless $ENV{OP_BT_ZERO_OK};
        $row->{settlement_price} = 0;
    }

    return BT::Option->new($row);
}

sub expiration {
    my ($self, %arg) = @_;

    my $at  = $arg{at}  or die 'AT missing';
    my $dte = $arg{dte} or die 'DTE missing';

    my ($days, $where) = $self->_range(
        range => $dte,
        field => 'expiration',
        type  => 'date',
    );

    my $date = $at + $days;
    my $sql  = 'SELECT DISTINCT(expiration) FROM options
        WHERE symbol_id=? AND at=? ' . $where;
    my ($expiration) = $self->dbh->selectrow_array(
        $sql,
        {},
        $self->symbol->id,
        $at,
        $date->format,
    );

    return $expiration;
}

sub delta_option {
    my ($self, %arg) = @_;

    my $at         = $arg{at}         or die 'AT missing';
    my $expiration = $arg{expiration} or die 'EXPIRATION missing';
    my $delta      = $arg{delta}      or die 'DELTA missing';
    my $call_put   = $arg{call_put} || 'P';
    my $multiple   = $arg{multiple} || 0;

    my ($value, $where) = $self->_range(
        range    => $delta,
        field    => 'span_delta',
        multiple => $multiple,
    );

    my $sql = "SELECT * FROM options WHERE
    symbol_id  = ? AND
    at         = ? AND
    call_put   = ? AND
    expiration = ? AND
    settlement_price > 0 $where";

    my $row = $self->dbh->selectrow_hashref(
        $sql,
        {},
        $self->symbol->id,
        $at,
        $call_put,
        $expiration,
        $value / 100,
    );
    unless ($row) {
        warn "Skipping (delta_option): at=$at, cp=$call_put, exp=$expiration";
        return;
    }

    return BT::Option->new($row);
}

sub percent_option {
    my ($self, %arg) = @_;

    my $at         = $arg{at}         or die 'AT missing';
    my $expiration = $arg{expiration} or die 'EXPIRATION missing';
    my $percent    = $arg{percent}    or die 'PERCENT missing';
    my $call_put   = $arg{call_put} || 'P';
    my $multiple   = $arg{multiple} || 0;

    my $underlying = $self->underlying(
        expiration => $expiration,
        at         => $at,
    );
    unless ($underlying) {
        warn "Skipping (percent_option): at=$at, cp=$call_put, exp=$expiration - no underlying";
        return;
    }

    my $strike = $underlying * ($percent / 100);

    return $self->strike_option(
        at         => $at,
        expiration => $expiration,
        strike     => $strike,
        call_put   => $call_put,
        multiple   => $multiple,
    );
}

sub strike_option {
    my ($self, %arg) = @_;

    my $at         = $arg{at}         or die 'AT missing';
    my $expiration = $arg{expiration} or die 'EXPIRATION missing';
    my $strike     = $arg{strike}     or die 'STRIKE missing';
    my $call_put   = $arg{call_put} || 'P';
    my $multiple   = $arg{multiple} || 0;

    my $sql = "SELECT * FROM options WHERE
        symbol_id  = ? AND
        at         = ? AND
        call_put   = ? AND
        expiration = ? AND
        settlement_price > 0 ";
    my @vars = (
        $self->symbol->id,
        $at,
        $call_put,
        $expiration,
    );

    if ($multiple) {
        $sql .= "AND MOD(strike, ?) = 0 ";
        push @vars, $multiple;
    }

    $sql .= "ORDER BY ABS(strike - ?) ASC LIMIT 1";
    push @vars, $strike;

    my $row = $self->dbh->selectrow_hashref($sql, {}, @vars);
    unless ($row) {
        warn "Skipping (strike_option): at=$at, cp=$call_put, exp=$expiration, strike=$strike";
        return;
    }

    return BT::Option->new($row);
}

sub price_option {
    my ($self, %arg) = @_;

    my $at         = $arg{at}         or die 'AT missing';
    my $expiration = $arg{expiration} or die 'EXPIRATION missing';
    my $price      = $arg{price}      or die 'PRICE missing';
    my $call_put   = $arg{call_put} || 'P';
    my $multiple   = $arg{multiple} || 0;

    my ($value, $where) = $self->_range(
        range    => $price,
        field    => 'settlement_price',
    );

    my $sql = "SELECT * FROM options WHERE
        symbol_id  = ? AND
        at         = ? AND
        call_put   = ? AND
        expiration = ? AND
        settlement_price > 0 ";
    my @vars = (
        $self->symbol->id,
        $at,
        $call_put,
        $expiration,
    );

    $sql .= $where;
    push @vars, $value * 100; # TODO use symbol->divider

    my $row = $self->dbh->selectrow_hashref($sql, {}, @vars);
    unless ($row) {
        warn "Skipping (price_option): at=$at, cp=$call_put, exp=$expiration";
        return;
    }

    return BT::Option->new($row);
}

sub position_at {
    my ($self, $position, $at) = @_;

    my $new_position = BT::Position->new(
        symbol => $position->symbol,
    );

    foreach my $leg (@{$position->legs}) {
        my ($ratio, $option) = @$leg;
        my $new_option = $self->option($option, $at);
        unless ($new_option) {
            warn "Skipping (position_at): at=$at";
            return;
        }
        $new_position->add($ratio, $new_option);
    }

    return $new_position;
}


sub _range {
    my ($self, %arg) = @_;

    my $range    = $arg{range} or die 'RANGE missing';
    my $field    = $arg{field} or die 'FIELD missing';
    my $multiple = $arg{multiple} || 0;
    my $type     = $arg{type} // '';

    unless ($range =~ /^([0-9.]+)([-+!]?)$/) {
        die "RANGE '$range' has unknown format";
    }

    my $value = $1;
    my $mode  = $2;

    my $sql = '';
    if ($mode eq '+') {
        $sql = "AND $field >= ?";
        $sql .= " AND MOD(strike, $multiple) = 0" if $multiple;
        $sql .= " ORDER BY $field ASC";
    } elsif ($mode eq '-') {
        $sql = "AND $field <= ?";
        $sql .= " AND MOD(strike, $multiple) = 0" if $multiple;
        $sql .= " ORDER BY $field DESC";
    } elsif ($mode eq '!') {
        $sql = "AND $field = ?";
        $sql .= " AND MOD(strike, $multiple) = 0" if $multiple;
    } else {
        $sql = "AND MOD(strike, $multiple) = 0 " if $multiple;
        if ($type eq 'date') {
            $sql .= "ORDER BY ABS(DATEDIFF($field, ?)) ASC";
        } else {
            $sql .= "ORDER BY ABS($field - ?) ASC";
        }
    }

    return $value, "$sql LIMIT 1";
}

1;
