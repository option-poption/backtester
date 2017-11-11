package BT::Option;

use Mojo::Base -base;

use overload '""' => 'to_string';
use Date::Simple;


has [qw/symbol_id at expiration call_put strike settlement_price delta span_delta implied_volatility futures_contract_month values/];

sub new {
    my ($class, $row) = @_;
    $row->{values} = [
        $row->{value1}, $row->{value2}, $row->{value3}, $row->{value4}, $row->{value5}, $row->{value6}, $row->{value7}, $row->{value8},
        $row->{value9}, $row->{value10}, $row->{value11}, $row->{value12}, $row->{value13}, $row->{value14}, $row->{value15}, $row->{value16},
    ];
    $class->SUPER::new($row);
}

sub dte {
    my ($self) = @_;

    my $at         = Date::Simple->new($self->at);
    my $expiration = Date::Simple->new($self->expiration);

    return $expiration - $at;
}

sub format_strike { sprintf('%.0f', shift->strike) }
sub format_delta  { sprintf('%.2f', shift->span_delta * 100) }
sub format_iv     { sprintf('%.1f', shift->implied_volatility * 100) }
sub format_price  { sprintf('%.2f', shift->settlement_price / 100) } # TODO use symbol->divider

sub to_string {
    my ($self) = @_;

    return sprintf(
        "%s%s %s (%3d) %5s",
        $self->format_strike,
        $self->call_put,
        $self->expiration,
        $self->dte,
        $self->format_price,
    );
}

1;
