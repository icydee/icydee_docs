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

# Get the root node of the tree
#
sub tree_root: Local: {
    my ($self, $c) = @_;

    my $root = $c->model('DB::Folder')->find(1);

    $c->stash->{json_data} = [
        {
            property    => { name   => $root->title},
            type        => 'folder',
            data        => { node_id    => 1 },
        }
    ];
    $c->stash->{current_view} = 'JSON';
}

# Process the input file request
#
sub input_file: Local: {
    my ($self, $c) = @_;

    my $dir         = "/var/sandbox/icydee/root/static/import/";
    my $filename    = $c->req->param('s_filename');
    my $title       = $c->req->param('s_file_title');
    my $description = $c->req->param('s_file_description');
    my $node_id     = $c->req->param('s_node_id');
    my $file_id     = $c->req->param('s_file_id');

    if (-e "$dir$filename") {
        # Process file and put it in the database

        my $folder_id;
        if ($node_id) {
            # Put it in this folder.
            $folder_id = $node_id;
        }
        elsif ($file_id) {
            # Put it in this files folder
            my $file = $c->model('DB::File')->find($file_id) || die "Could not get file";
            $folder_id = $file->folder_id;
        }
        else {
            die "We should not get here";
        }

        my $folder = $c->model('DB::Folder')->find($folder_id);
        my $file = $folder->add_to_files({
            title       => $title,
            description => $description,
        });

        # Create directory structure
        my $id      = sprintf("%08s", $file->id);
        my $dir0    = substr($id, 0, 4);
        my $dir1    = substr($id, 4, 2);
        my $file_n  = substr($id, 6, 2);
        mkdir("/var/sandbox/icydee/root/static/files/$dir0");
        mkdir("/var/sandbox/icydee/root/static/files/$dir0/$dir1");
        if (link("$dir$filename", "/var/sandbox/icydee/root/static/files/$dir0/$dir1/$file_n.pdf")) {
            unlink("$dir$filename");
        }

        $c->stash->{json_data} = {
            error       => 0,
            message     => 'SUCCESS: File saved',
        };
    }
    else {
        $c->stash->{json_data} = {
            error       => 1,
            message     => "ERROR: File [$dir$filename] does not exist",
        };
    }
    $c->stash->{current_view} = 'JSON';
}

# Get the first file from the input directory
#
sub first_input_file: Local: {
    my ($self, $c) = @_;

    my $dir = IO::Dir->new("/var/sandbox/icydee/root/static/import");
    my ($filename, @files);

    if (defined $dir) {
FILE:
        while (my $file = $dir->read) {
            next FILE if $file =~ m/^\./;
            $filename = $file;
            last FILE;
        }
    }
    if (defined $filename) {
        $c->stash->{json_data} = {
            error       => 0,
            filename    => $filename,
        };
    }
    else {
        $c->stash->{json_data} = {
            error       => 1,
            message     => "no more input files",
        };
    }
    $c->stash->{current_view} = 'JSON';
}

# Get the stored filename from the files directory
#
sub stored_filename : Local : {
    my ($self, $c) = @_;

    my $file_id = $c->request->param('s_file_id');
    my $file = $c->model('DB::File')->find($file_id);
    if ($file) {
        my $id      = sprintf("%08s", $file->id);
        my $dir0    = substr($id, 0, 4);
        my $dir1    = substr($id, 4, 2);
        my $file_n  = substr($id, 6, 2);
        $c->stash->{json_data} = {
            error       => 0,
            filename    => "/static/files/$dir0/$dir1/$file_n.pdf",
        };
    }
    else {
        $c->stash->{json_data} = {
            error       => 1,
            message     => "ERROR: Can't find file",
        };
    }
    $c->stash->{current_view} = 'JSON';
}


# Get the children of a specified node
#
sub tree_children: Local: {
    my ($self, $c) = @_;

    my $node_id = $c->request->param('node_id');
    my $node = $c->model('DB::Folder')->find($node_id) || die "Cannot get tree node $node_id";

    my @json_data;
    my $child_rs = $node->children;
    while (my $child = $child_rs->next) {
        # Check if the child has any files or is a branch
        my $is_folder = $child->is_branch ? 1 : 0;
        if ($child->files->count) {
            $is_folder = 1;
        }

        my $json_entry = {
            property    => {name        => $child->title, },
            type        => 'folder',
            data        => {node_id     => $child->id, },
        };
        push @json_data, $json_entry;
    }
    my $files_rs = $node->files;
    while (my $file = $files_rs->next) {
        my $json_entry = {
            property    => {name        => $file->title, },
            type        => 'file',
            data        => {file_id     => $file->id, },
        };
        push @json_data, $json_entry;
    }

    $c->stash->{json_data} = \@json_data;
    $c->stash->{current_view} = 'JSON';
}

1;
