package DBIx::Class::Tree::NestedSet;

use strict;
use warnings;

use parent qw/DBIx::Class/;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;

__PACKAGE__->mk_classdata( _tree_columns => {} );

sub tree_columns {
    my ($class, $args) = @_;

    if (defined $args) {
        $args = {
            root_rel        => 'root',
            nodes_rel       => 'nodes',
            children_rel    => 'children',
            ancestors_rel   => 'parents',
            parent_rel      => 'parent',
            %{ $args },
        };

        my ($root, $left, $right) = map {
            my $col = $args->{"${_}_column"};

            croak("required param $_ not specified")
                if !defined $col;

            $col;
        } qw/root left right/;

        my $table     = $class->table;
        my %join_cond = ( "foreign.$root" => "self.$root" );

        $class->belongs_to(
            $args->{root_rel} => $class,
            \%join_cond,
            { where => \"me.$left = 1", },                  #"
        );
        $class->has_many(
            $args->{nodes_rel} => $class,
            \%join_cond,
        );
        $class->has_many(
            $args->{children_rel} => $class,
            \%join_cond,
            { where    => \"me.$left > parent.$left AND me.$right < parent.$right",         #"
              order_by =>  "me.$left",
              from     =>  "$table me, $table parent" },
        );
        $class->has_many(
            $args->{ancestors_rel} => $class,
            { %join_cond, },
            { where    => \"child.$left > me.$left AND child.$right < me.$right",  #"
              order_by =>  "me.$right",
              from     =>  "$table me, $table child" },
        );
        {
            no strict 'refs';
            no warnings 'redefine';

            my $meth = $args->{ancestors_rel};
            *{ "${class}::${\$args->{parent_rel}}" } = sub { shift->$meth(@_)->first };
        }
        $class->_tree_columns($args);
    }
    return $class->_tree_columns;
}


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
# Return children (or undef if the node has no children)
#
sub children {
    my ($self) = @_;

    if ($self->left_extent == $self->right_extent - 1) {
        return;
    }
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
