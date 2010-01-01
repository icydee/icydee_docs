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

    my $success = $self->result_source->resultset->search({
        left_extent => {'>' => $self->left_extent},
    })->update({
        left_extent => \"left_extent + 2",                  #"
    });

    $success = $self->result_source->resultset->search({
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

    my $success = $self->result_source->resultset->search({
        left_extent => {'>' => $parent_right_extent},
    })->update({
        left_extent => \"left_extent + 2",                  #"
    });
    $success = $self->result_source->resultset->search({
        right_extent => {'>' => $parent_right_extent},
    })->update({
        right_extent => \"right_extent + 2",                  #"
    });

    $child->left_extent($parent_right_extent);
    $child->right_extent($parent_right_extent + 1);
    $child->update;

    $self->right_extent($parent_right_extent + 2);
    $self->update;

    return $self;
}


1;
