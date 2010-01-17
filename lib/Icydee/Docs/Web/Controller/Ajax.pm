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

sub tree_root: Local: {
    my ($self, $c) = @_;

    my $root = $c->model('DB::Folders')->find(1);

    $c->stash->{json_data} = [
        {
            property    => { name   => $root->title},
            type        => 'folder',
            data        => { node_id    => 1 },
        }
    ];
    $c->stash->{current_view} = 'JSON';
}

sub tree_children: Local: {
    my ($self, $c) = @_;

    my $node_id = $c->request->param('node_id');
    my $node = $c->model('DB::Folders')->find($node_id) || die "Cannot get tree node $node_id";

    my @json_data;
    my $child_rs = $node->children;
    while (my $child = $child_rs->next) {
        my $json_entry = {
            property    => {name        => $child->title, },
            type        => $child->is_leaf ? 'file' : 'folder',
            data        => {node_id     => $child->id, },
        };
        push @json_data, $json_entry;
    }
    $c->stash->{json_data} = \@json_data;
    $c->stash->{current_view} = 'JSON';
}

1;
