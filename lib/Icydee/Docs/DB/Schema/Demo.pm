package Icydee::Docs::DB::Schema::Demo;
#
# $Id: $
# $Revision: $
# $Author: $
# $Source:  $
#
# $Log: $
#
use Moose;
use namespace::autoclean;

with 'MooseTree';

extends 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto','Core');
__PACKAGE__->table("demo");
__PACKAGE__->add_columns(
    # autoincrement index to table
    id => {
        data_type       => "INT",
        default_value   => undef,
        is_nullable     => 0,
        size            => 10,
    },
    left_extent => {
        data_type       => "INT",
        default_value   => undef,
        is_nullable     => 1,
        size            => 10,
    },
    right_extent => {
        data_type       => "INT",
        default_value   => undef,
        is_nullable     => 1,
        size            => 10,
    },
    title => {
        data_type       => "VARCHAR",
        default_value   => "",
        is_nullable     => 1,
        size            => 32,
    },
);
__PACKAGE__->set_primary_key("id");


1;
