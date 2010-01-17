package MooseTree;
#
# $Id: $
# $Revision: $
# $Author: $
# $Source:  $
#
# $Log: $
#
use Moose::Role;
use namespace::autoclean;

#
# Insert a left-child to a parent node
#
#   Increment all left_extent by 2 where left_extent > parent->left_extent
#   Increment all right_extent by 2 where right_extent > parent->left_extent
#
sub insert_left_child {
    my ($self, $child) = @_;

    my $parent_right_extent = $self->right_extent;

    $self->result_source->resultset->search({
        left_extent => {'>' => $self->left_extent},
    })->update({
        left_extent => \"left_extent + 2",                  #"
    });
    $self->result_source->resultset->search({
        right_extent => {'>' => $self->left_extent},
    })->update({
        right_extent => \"right_extent + 2",                #"
    });

    $child->left_extent($self->left_extent + 1);
    $child->right_extent($self->left_extent + 2);
    $child->update;

    $self->right_extent($parent_right_extent + 2);
    $self->update;

    return $self;
}

#
# Insert a right-child to a parent node
#
#   Increment all left_extent by 2 where left_extent > parent->right_extent
#   Increment all right_extent by 2 where right_extent >= parent->right_extent
#   The child has left_extent = parent->right_extent, right_extent = parent->right_extent + 1
#
sub insert_right_child {
    my ($self, $child) = @_;

    my $parent_right_extent = $self->right_extent;

    $self->result_source->resultset->search({
        left_extent => {'>' => $parent_right_extent},
    })->update({
        left_extent => \"left_extent + 2",                  #"
    });
    $self->result_source->resultset->search({
        right_extent => {'>' => $parent_right_extent},
    })->update({
        right_extent => \"right_extent + 2",                #"
    });

    $child->left_extent($parent_right_extent);
    $child->right_extent($parent_right_extent + 1);
    $child->update;

    $self->right_extent($parent_right_extent + 2);
    $self->update;

    return $self;
}

#
# Return all ancestors for a node ardered from root down
#
sub ancestors {
    my ($self) = @_;

    # Root has no ancestors
    if ($self->left_extent == 1) {
        return;
    }

    my $ancestors_rs = $self->result_source->resultset->search({
        left_extent     => {'<' => $self->left_extent},
        right_extent    => {'>' => $self->right_extent},
    },{
        order_by        => 'left_extent',
    });

    if (wantarray) {
        return $ancestors_rs->all;
    }
    return $ancestors_rs;
}


#
# Return a nodes parent (or undef if the node is the root node)
#
sub parent {
    my ($self) = @_;

    # Root has no parent
    if ($self->left_extent == 1) {
        return;
    }

    my ($parent) = $self->ancestors->search({},{
        order_by    => 'left_extent desc',
        rows        => 1,
    })->first;

    return $parent;
}

#
# Return children (or undef if the node has no children)
#
sub children {
    my ($self) = @_;

    if ($self->left_extent == $self->right_extent - 1) {
        return;
    }

    # all nodes that have me as their parent


#    my $chilren_rs = $self->result_source->resultset->search({
#        left_extent     =>
#

    return;
}

#
# Delete a sub-tree (or a single node)
#
#   Delete all nodes where left_extent >= deletee->left_extent and right_extent <= deletee->right_extent
#   Decrement all right_extent by deletee->right_extent - deletee->left_extent + 1 where right_extent > deletee->right_extent
#   Decrement all left_extent by deletee->right_extent - deletee->left_extent + 1 where left_extent > deletee->right_extent
# On success returns the deleted nodes parent
#
sub delete {
    my ($self) = @_;

    # cannot delete the root node
    if ($self->left_extent == 1) {
        return;
    }

#    my $parent = $self->parent;
}


1;
