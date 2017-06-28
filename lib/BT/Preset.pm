package BT::Preset;

use Mojo::Base -base;

use Data::Dump qw/pp/;
use Module::Find qw/useall/;

use BT::Params;
useall 'BT::Strategy';
useall 'BT::Target';
useall 'BT::Sizing';


has params => sub { {} };

foreach my $type (qw/strategy target sizing/) {
    has $type => sub {
        $_[0]->_initiate($type);
    };
}


sub entry { shift->strategy->entry(@_) }
sub size  { shift->sizing->size(@_) }
sub check_position { shift->strategy->check_position(@_) }

sub _class {
    my ($self, $type) = @_;

    return join(
        '::',
        'BT',
        ucfirst($type),
        $self->meta->{$type},
    );
}

sub _params {
    my ($self, $type) = @_;

    return $self->strategy_params if $type eq 'strategy';

    my $param_defs = $self->all_params->{$type};
    my $params = {};
    foreach my $param_def (@$param_defs) {
        my $name = $param_def->{name};
        $params->{$name} = $self->params->{$name} // $param_def->{default};
    }

    return $params;
}

sub _initiate {
    my ($self, $type) = @_;

    my $class  = $self->_class($type);
    my $params = $self->_params($type);

    $class->new($params);
}


sub all_params {
    return {
        preset  => $_[0]->meta->{params},
        target  => $_[0]->_class('target')->params,
        sizing  => $_[0]->_class('sizing')->params,
        general => $_[0]->general_params,
    };
}

sub strategy_params {
    my ($self) = @_;

    $self->_params('preset');
}

sub general_params {
    BT::Params::general_params;
}

1;

