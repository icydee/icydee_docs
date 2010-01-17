package Icydee::Docs::Web::Controller::Ajax;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Data::Dumper;
use DateTime;


sub test_tree : Local {
    my ($self, $c) = @_;

    $c->stash->{json_data} = [
        { data  => "First node" },
        { data  => "Second node", children  => [
            {data   => "grand child", },
            {data   => "grand child 2", },
        ],},
        { data  => "Last child" },
    ];
    $c->stash->{current_view} = 'JSON';
}

1;
