#!/usr/bin/env perl
#
# $Id: $
# $Revision: $
# $Author: $
# $Source:  $
#
# $Log: $
#
use strict;
use warnings;

use Test::More tests => 202;
use Test::Exception;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Icydee::Docs::DB;

use DBICx::TestDatabase;

my $schema = DBICx::TestDatabase->new('Icydee::Docs::DB');

# 1
ok($schema, "Schema is defined");

#$schema->deploy;

my $auto_inc = 1;
my $table = 'Demo2';

# Create a test tree
my $test_tree = [
    [1,  1,  20, 'root'],
    [2,  2,  13, 'A'],
    [3,  3,   4, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 19, 'G'],
    [9,  15, 16, 'H'],
    [10, 17, 18, 'I'],
];

my ($success, $root, $child, $parent);

#### insert_left_child tests ####
# Insert a left child of the root node
$root = create_tree($test_tree);
$child = $schema->resultset($table)->create({
    id              => 11,
    title           => 'left child',
});
$success = $root->insert_left_child($child);
ok($success, "Left child inserted to root");
test_tree("Left Child to Root",[
    [1,  1,  22, 'root'],
    [2,  4,  15, 'A'],
    [3,  5,   6, 'B'],
    [4,  7,  12, 'C'],
    [5,  13, 14, 'D'],
    [6,  8,  9,  'E'],
    [7,  10, 11, 'F'],
    [8,  16, 21, 'G'],
    [9,  17, 18, 'H'],
    [10, 19, 20, 'I'],
    [11,  2,  3, 'left child'],
]);


# Insert a left child of a leaf node
$root = create_tree($test_tree);
$child = $schema->resultset($table)->create({
    id              => 11,
    title           => 'left child',
});
($parent) = $schema->resultset($table)->search({id => 10,});
$success = $parent->insert_left_child($child);
ok($success, "Left child inserted to 10");
test_tree("Left Child to Leaf", [
    [1,  1,  22, 'root'],
    [2,  2,  13, 'A'],
    [3,  3,   4, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 21, 'G'],
    [9,  15, 16, 'H'],
    [10, 17, 20, 'I'],
    [11, 18, 19, 'left child'],
]);

# Insert a left child of a non leaf node
$root = create_tree($test_tree);
$child = $schema->resultset($table)->create({
    id              => 11,
    title           => 'left child',
});
($parent) = $schema->resultset($table)->search({id => 8,});
$success = $parent->insert_left_child($child);
ok($success, "Left child inserted to 8");
test_tree("Left Child to non Leaf",[
    [1,  1,  22, 'root'],
    [2,  2,  13, 'A'],
    [3,  3,   4, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 21, 'G'],
    [9,  17, 18, 'H'],
    [10, 19, 20, 'I'],
    [11, 15, 16, 'left child'],
]);

#### insert_right_child tests ####
# Insert a right child of the root node
$root = create_tree($test_tree);
$child = $schema->resultset($table)->create({
    id              => 11,
    title           => 'right child',
});
$success = $root->insert_right_child($child);
ok($success, "Right child inserted to root");
test_tree("Right Child to Root",[
    [1,  1,  22, 'root'],
    [2,  2,  13, 'A'],
    [3,  3,   4, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 19, 'G'],
    [9,  15, 16, 'H'],
    [10, 17, 18, 'I'],
    [11, 20, 21, 'right child'],
]);

# Insert a right child of a leaf node
$root = create_tree($test_tree);
$child = $schema->resultset($table)->create({
    id              => 11,
    title           => 'right child',
});
($parent) = $schema->resultset($table)->search({id => 9,});
$success = $parent->insert_right_child($child);
ok($success, "Right child inserted to 9");
test_tree("Right Child to Leaf",[
    [1,  1,  22, 'root'],
    [2,  2,  13, 'A'],
    [3,  3,   4, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 21, 'G'],
    [9,  15, 18, 'H'],
    [10, 19, 20, 'I'],
    [11, 16, 17, 'right child'],
]);

# Insert a right child to a non leaf node
$root = create_tree($test_tree);
$child = $schema->resultset($table)->create({
    id              => 11,
    title           => 'right child',
});
($parent) = $schema->resultset($table)->search({id => 8,});
$success = $parent->insert_right_child($child);
ok($success, "Right child inserted to 8");
test_tree("Right Child to non Leaf",[
    [1,  1,  22, 'root'],
    [2,  2,  13, 'A'],
    [3,  3,   4, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 21, 'G'],
    [9,  15, 16, 'H'],
    [10, 17, 18, 'I'],
    [11, 19, 20, 'right child'],
]);

# Test for parents
$root = create_tree($test_tree);
for my $test ([2,1],[3,2],[4,2],[6,4],[7,4],[5,2],[9,8],[10,8],[8,1]) {
    my $child_id    = $test->[0];
    my $parent_id   = $test->[1];

    my $child       = $schema->resultset($table)->find($child_id);
    my $parent      = $child->parent;
    is($parent->id, $parent_id, "Parent of $child_id is $parent_id");
}

# Test for ancestors
$root = create_tree($test_tree);
for my $test ([2,[1]],[3,[1,2]],[4,[1,2]],[6,[1,2,4]],[7,[1,2,4]],[5,[1,2]],[9,[1,8]],[10,[1,8]],[8,[1]]) {
    my $child_id    = $test->[0];
    my @ancestor_ids= @{$test->[1]};
    # list context
    $child          = $schema->resultset($table)->find($child_id);
    my @ancestors   = $child->ancestors;
    my $index = 0;
    for my $ancestor (@ancestors) {
        is($ancestor->id, $ancestor_ids[$index++], "List - Ancestor $index of $child_id");
    }
    # scalar context
    $child          = $schema->resultset($table)->find($child_id);
    my $ancestors   = $child->ancestors;
    $index = 0;
    while (my $ancestor = $ancestors->next) {
        is($ancestor->id, $ancestor_ids[$index++], "Scalar - Ancestor $index of $child_id");
    }
}

# Test for children of leaf nodes
$root = create_tree($test_tree);
for my $id (3,6,7,5,9,10) {
    $parent = $schema->resultset($table)->find($id);
    # list context
    my @children = $parent->children;
    is(scalar @children, 0, "List - Children of leaf node $id");
    # scalar context
    $child  = $parent->children;
    is($child, undef, "Scalar - Children of leaf node $id");
}
exit;

# Test for children of non-leaf nodes
$root = create_tree($test_tree);
for my $test ([1,[2,8]],[2,[3,4,5]],[4,[6,7]],[8,[9,10]]) {
    my $parent_id    = $test->[0];
    my @children_ids= @{$test->[1]};
    # list context
    $parent         = $schema->resultset($table)->find($parent_id);
    my @children    = $parent->children;
    my $index = 0;
    for my $child (@children) {
        is($child->id, $children_ids[$index++], "List - Child $index of $parent_id");
    }
    # scalar context
    $parent         = $schema->resultset($table)->find($parent_id);
    my $children    = $parent->children;
    $index = 0;
    while (my $child = $children->next) {
        is($child->id, $children_ids[$index++], "Scalar - Child $index of $parent_id");
    }
}

#============== subroutines ====================

# Test an array of nodes, each contains an array of id, left_extent and right_extent
sub test_tree {
    my ( $test_name, $array_ref) = @_;

    # left and right extents must be unique
    my @extents = [];
    for my $node (@$array_ref) {
        my ($id, $left, $right, $title) = @$node;
        my $node = $schema->resultset($table)->find($id);
        ok($node, "$test_name: Node $id found");
        is($node->left_extent, $left, "$test_name: Left Extent is $left");
        is($node->right_extent, $right, "$test_name: Right Extent is $right");
        is($node->title, $title, "$test_name: Title is $title");
    }
}

# Create a complete tree
sub create_tree {
    my ($array_ref) = @_;

    $schema->resultset($table)->delete;
    $auto_inc = 1;

    for my $node (@$array_ref) {
        my ($id, $left, $right, $title) = @$node;
        my $node = $schema->resultset($table)->create({
            id              => $id,
            root            => 1,
            left_extent     => $left,
            right_extent    => $right,
            title           => $title,
        });
        if ($id >= $auto_inc) {
            $auto_inc = $id + 1;
        }
    }
    my ($root) = $schema->resultset($table)->search({
        left_extent     => 1,
    });
    return $root;
}
