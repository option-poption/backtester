package BT::Option;

use Mojo::Base -base;

use Date::Simple;


has [qw/symbol_id at expiration call_put strike settlement_price delta span_delta implied_volatility futures_contract_month/];
has [qw/value1 value2 value3 value4 value5 value6 value7 value8 value9 value10 value11 value12 value13 value14 value15 value16/];

sub values {
    my ($self) = @_;

    return [
        $self->value1, $self->value2, $self->value3, $self->value4, $self->value5, $self->value6, $self->value7, $self->value8,
        $self->value9, $self->value10, $self->value11, $self->value12, $self->value13, $self->value14, $self->value15, $self->value16,
    ];
}

sub dte {
    my ($self) = @_;

    my $at         = Date::Simple->new($self->at);
    my $expiration = Date::Simple->new($self->expiration);

    return $expiration - $at;
}

1;
