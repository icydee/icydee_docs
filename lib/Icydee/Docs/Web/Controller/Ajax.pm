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
            data        => { node_id    => 1, expand_me => 1 },
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

    if ($node_id) {
        # Save it in session data
        $c->session->{node_id} = $node_id;
    }
    if ($file_id) {
        # Save it in session data
        $c->session->{file_id} = $file_id;
    }

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
        $c->session->{file_id} = $file->id;

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

# Respond to a move node in the tree
#
sub move_file: Local: {
    my ($self, $c) = @_;

    my $from_node_id    = $c->request->param('s_from_node_id');
    my $from_file_id    = $c->request->param('s_from_file_id');
    my $to_node_id      = $c->request->param('s_to_node_id');
    my $to_file_id      = $c->request->param('s_to_file_id');
    my $where           = $c->request->param('s_where');

    my $moving_file;            # If not moving file, we are moving a folder
    my ($from_file, $to_file);

    if ($from_file_id) {
        $from_file = $c->model('DB::File')->find($from_file_id) || die "Cannot get file node $from_file_id";
        $from_node_id = $from_file->folder_id;
        $moving_file = 1;
    }

    if ($to_file_id) {
        $to_file = $c->model('DB::File')->find($to_file_id) || die "Cannot get file node $to_file_id";
        $to_node_id = $to_file->folder_id;
        if (! $moving_file) {
            $where = 'inside';
        }
    }

    # At the moment we have no way of positioning files, only folders.
    if ($moving_file) {
        # just move the file into the appropriate folder
        $from_file->folder_id($to_node_id);
        $from_file->update();
    }
    else {
        # Moving a node
        my $to_node = $c->model('DB::Folder')->find($to_node_id) || die "Cannot get folder node $to_node_id";
        my $from_node = $c->model('DB::Folder')->find($from_node_id) || die "Cannot get folder node $from_node_id";

        if ($where eq 'inside') {
            $to_node->attach_rightmost_child($from_node);
        }
        elsif ($where eq 'before') {
            $to_node->attach_left_sibling($from_node);
        }
        elsif ($where eq 'after') {
            $to_node->attach_right_sibling($from_node);
        }
        else {
            die "Unknown 'where' = [$where]";
        }
    }

    $c->stash->{json_data} = {
        error       => 0,
        message     => "Success: Moved correctly",
    };
    $c->stash->{current_view} = 'JSON';
}



# Get the children of a specified node
#
sub tree_children: Local: {
    my ($self, $c) = @_;

    my $node_id         = $c->request->param('node_id');
    my $current_file_id = $c->session->{file_id};
    my $current_node_id = $c->session->{node_id};

    my ($node, $current_node);

    if ($node_id) {
        $node = $c->model('DB::Folder')->find($node_id) || die "Cannot get tree node $node_id";
    }
    if ($current_file_id) {
        my $file = $c->model('DB::File')->find($current_file_id) || die "Cannot get file $current_file_id";
        $current_node_id = $file->folder_id;
    }

    my @json_data;
    my $child_rs = $node->children;
    $c->log->debug("TREE_CHILDREN session node_id=[$current_node_id]");
    $c->log->debug("TREE_CHILDREN session file_id=[$current_file_id]");
    while (my $child = $child_rs->next) {
        my $expand_me = 0;
        if ($current_node_id == $child->id) {
            $expand_me = 1;
            $c->log->debug("TREE_CHILDREN: node [$current_node_id] is this node");
        }
        if ($child->has_descendant($current_node_id)) {
            $expand_me = 1;
            $c->log->debug("TREE_CHILDREN: node [$current_node_id] has ancestor child ".$child->id." expand_me $expand_me");
        }
        my $currently_selected = $child->id == $current_node_id && ! $current_file_id ? 1 : 0;
        my $json_entry = {
            property    => {name        => $child->title},
            type        => $currently_selected ? 'folder_current' : 'folder',
            data        => {
                node_id     => $child->id,
                file_id     => 0,
                expand_me   => $expand_me,
                selected    => $currently_selected,
            },
        };
        push @json_data, $json_entry;
    }
    my $files_rs = $node->files;
    while (my $file = $files_rs->next) {
        my $currently_selected = $file->id == $current_file_id ? 1 : 0;
        my $json_entry = {
            property    => {name        => $file->title},
            type        => $currently_selected ? 'file_current' : 'file',
            data        => {
                file_id     => $file->id,
                node_id     => 0,
                selected    => $currently_selected,
            },
        };
        push @json_data, $json_entry;
    }

    $c->stash->{json_data} = \@json_data;
    $c->stash->{current_view} = 'JSON';
}

1;
