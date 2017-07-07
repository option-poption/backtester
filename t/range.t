use Test::More tests => 9;

use BT::DB;


my @data = (
    ['20+', 20, 'AND field >= ? ORDER BY field ASC LIMIT 1'],
    ['20-', 20, 'AND field <= ? ORDER BY field DESC LIMIT 1'],
    ['20!', 20, 'AND field = ? LIMIT 1'],
    [20, 20, 'ORDER BY ABS(field - ?) ASC LIMIT 1'],
);

my $db = BT::DB->new;

foreach my $data (@data) {
    my $range = shift @$data;

    my ($value, $sql) = $db->_range(
        range => $range,
        field => 'field',
    );
    is($value, shift @$data, 'value');
    is($sql,   shift @$data, 'sql');
}

my ($value, $sql) = $db->_range(
    range => '30',
    field => 'date',
    type  => 'date',
);
is($sql, 'ORDER BY ABS(DATEDIFF(date, ?)) ASC LIMIT 1', 'date');

