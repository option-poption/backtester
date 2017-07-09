package BT::Config;

use Mojo::Base -strict;

my %CONFIG = (
    sp3 => [
        'ShortPut::Delta',
        {
            dte           => '90+',
            delta         => '3+',
            profit_target => 50,
            multiple      => 25,
        },
    ],
    sp80 => [
        'ShortPut::Percent',
        {
            dte           => '90+',
            percent       => 80,
            profit_target => 50,
            multiple      => 25,
        },
    ],
    cs80 => [
        'CreditSpread::Percent',
        {
            dte           => '90+',
            percent       => 80,
            width         => 100,
            profit_target => 50,
            multiple      => 25,
        },
    ],
    falde => [
        'Falde604020',
        {
            dte           => '60+',
            delta_percent => 30,
            round_turn    => 1.23,
        },
    ],
);

sub preset {
    my ($class, $name) = @_;

    my $config = $CONFIG{$name || 'sp3'};
    my $preset = 'BT::Preset::' . $config->[0];
    my $params = $config->[1];

    return $preset->new(params => $params);
}

1;
