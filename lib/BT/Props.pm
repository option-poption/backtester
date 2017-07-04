package BT::Props;

use Mojo::Base -strict;

use Date::Simple qw/date/;

my %PROPERTY = (
    entry_date => {
        label => 'Entry Date',
        short => 'Entry',
        calc  => sub { date(shift->entry_position->first_option->at) },
    },
    exit_date => {
        label => 'Exit Date',
        short => 'Exit',
        calc  => sub { date(shift->exit_position->first_option->at) },
    },
    expiration_date => {
        label => 'Expiration Date',
        short => 'Expiry',
        calc  => sub { date(shift->entry_position->first_option->expiration) },
    },
    entry_underlying => {
        label => 'Entry Price Underlying',
        short => 'EntryU',
        calc  => sub { shift->entry_underlying },
    },
    exit_underlying => {
        label => 'Exit Price Underlying',
        short => 'ExitU',
        calc  => sub { shift->exit_underlying },
    },
    min_underlying => {
        label => 'Min. Price Underlying',
        short => 'minU',
        calc  => sub { shift->min_underlying },
    },
    max_underlying => {
        label => 'Max. Price Underlying',
        short => 'maxU',
        calc  => sub { shift->max_underlying },
    },
    range_underlying => {
        label => 'Price Range Underlying',
        short => 'Range',
        calc  => sub { sprintf('%.0f-%.0f', $_[0]->min_underlying, $_[0]->max_underlying) },
    },
    strike => {
        label => 'Option Strike Price(s)',
        short => 'Strike',
        calc  => _options('format_strike'),
    },
    delta => {
        label => 'Option Delta(s)',
        short => 'Delta',
        calc  => _options('format_delta'),
    },
    iv => {
        label => 'Option IV(s)',
        short => 'IV',
        calc  => _options('format_iv'),
    },
    dte => {
        label => 'DTE - Days Till Expiration (at Entry)',
        short => 'DTE',
        calc  => sub { shift->dte },
    },
    dit => {
        label => 'DIT - Days In Trade',
        short => 'DIT',
        calc  => sub { shift->dit },
    },
    entry_price => {
        label => 'Entry Price',
        short => 'in',
        calc  => sub { shift->entry_position->price },
    },
    exit_price => {
        label => 'Exit Price',
        short => 'out',
        calc  => sub { shift->exit_position->price },
    },
    min_price => {
        label => 'Min. Price',
        short => 'min',
        calc  => sub { shift->min_price },
    },
    max_price => {
        label => 'Max. Price',
        short => 'max',
        calc  => sub { shift->max_price },
    },
    profit => {
        label => 'Profit (per Lot/Contract)',
        short => 'Profit',
        calc  => sub { shift->profit },
    },
    exit_reason => {
        label => 'Exit Reason',
        short => 'Reason',
        calc  => sub { shift->exit_reason },
    },
    daily_profit => {
        label => 'Daily Profit',
        short => 'dPrf',
        calc  => sub { shift->daily_profit },
    },
    initial_margin => {
        label => 'Initial Margin (at Entry)',
        short => 'IM',
        calc  => sub { shift->initial_margin },
    },
    min_margin => {
        label => 'Min. Margin',
        short => 'minM',
        calc  => sub { shift->min_margin },
    },
    max_margin => {
        label => 'Max. Margin',
        short => 'maxM',
        calc  => sub { shift->max_margin },
    },
    margin_factor => {
        label => 'Max. Margin Factor (maxM / IM)',
        short => 'Fact',
        calc  => sub { shift->margin_factor },
    },
    max_margin_to_nlv => {
        label => 'Max. Margin to NLV (Margin Call > 100 %)',
        short => 'M%',
        calc  => sub { shift->max_margin_to_nlv },
    },
    size => {
        label => 'Size - Number of Lots/Contracts',
        short => '#',
        calc  => sub { shift->size },
    },
    exit_balance => {
        label => 'Account Balance (after Exit)',
        short => 'Account',
        calc  => sub { shift->exit_balance },
    },
);

sub props { \%PROPERTY }

sub _options {
    my ($field) = @_;
    return sub {
        my ($trade) = @_;
        return join('/',
            map { $_->$field } $trade->entry_position->options,
        );
    };
}

1;

