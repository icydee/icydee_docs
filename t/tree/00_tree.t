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

use Test::More tests => 21;
use Test::Exception;
use Data::Dumper;
use File::Temp 'tempfile';

use FindBin;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Icydee::Docs::DB;

my (undef, $sql_file) = tempfile;

my $schema = Icydee::Docs::DB->connect(
    "dbi:SQLite:dbname=$sql_file",
    '',
    '',
    {AutoCommit => 1, PrintError => 1},
);

# 1
ok($schema, "Schema is defined");

$schema->deploy;

my $auto_inc = 1;

# Clean out the tree structure
$schema->resultset('Demo')->delete;

# Create a test tree
my $test_tree = [
    [1,  1,  20, 'root'],
    [2,  2,  13, 'A'],
    [3,  4,  20, 'B'],
    [4,  5,  10, 'C'],
    [5,  11, 12, 'D'],
    [6,  6,  7,  'E'],
    [7,  8,  9,  'F'],
    [8,  14, 19, 'G'],
    [9,  15, 16, 'H'],
    [10, 17, 18, 'I'],
];

create_tree($test_tree);
exit;

# Create a root node

my $root = $schema->resultset('Demo')->create({
    id              => $auto_inc++,
    left_extent     => 1,
    right_extent    => 2,
    title           => 'root',
});
ok($root, "Root node created");

# Insert a left child of the root node
my $child = $schema->resultset('Demo')->create({
    id              => $auto_inc++,
    title           => 'left child',
});

my $success = $root->insert_left_child($child);

ok($success, "Left child inserted");
is($root->right_extent, 4, "Root right_extent = 4");

test_nodes([[1,1,4],[2,2,3]]);

# Insert a right child to the root node
$child = $schema->resultset('Demo')->create({
    id              => $auto_inc++,
    title           => 'right child',
});

$root = $schema->resultset('Demo')->find(1);
$success = $root->insert_right_child($child);

ok($success, "Right child inserted");
is($root->right_extent, 6, "Root right_extent = 6");
test_nodes([[1,1,6],[2,2,3],[3,4,5]]);


# Test an array of nodes, each contains an array of id, left_extent and right_extent
sub test_nodes {
    my ($array_ref) = @_;

    for my $node (@$array_ref) {
        my ($id, $left, $right) = @$node;
        my $node = $schema->resultset('Demo')->find($id);
        ok($node, "Node $id found");
        is($node->left_extent, $left, "Left Extent is $left");
        is($node->right_extent, $right, "Right Extent is $right");
    }
}

# Create a complete tree
sub create_tree {
    my ($array_ref) = @_;

    $schema->resultset('Demo')->delete;
    $auto_inc = 1;

    for my $node (@$array_ref) {
        my ($id, $left, $right, $title) = @$node;
        my $node = $schema->resultset('Demo')->create({
            id              => $id,
            left_extent     => $left,
            right_extent    => $right,
            title           => $title,
        });
        if ($id >= $auto_inc) {
            $auto_inc = $id + 1;
        }
    }
}

END {
    if ($ENV{ICYDEE_KEEP_TEST}) {
        print {*STDERR} "Keeping Test Database $sql_file\n";
    }
    else {
        unlink $sql_file;
    }
}