package BT::Config;

use Mojo::Base -strict;

use Mojo::File;
use Mojo::JSON;

my $CONFIG = Mojo::JSON::decode_json(Mojo::File->new('config.json')->slurp);

sub preset {
    my ($class, $name) = @_;

    my $config = $CONFIG->{$name || 'sp3'};
    my $preset = 'BT::Preset::' . $config->[0];
    my $params = $config->[1];

    return $preset->new(params => $params);
}

1;
