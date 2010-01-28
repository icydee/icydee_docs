package Icydee::Docs::DB::Schema::File;

use strict;
use warnings;

use parent 'DBIx::Class';

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('file');

__PACKAGE__->add_columns(
    id => {
        data_type         => 'integer',
        is_auto_increment => 1,
    },
    title       => { data_type => 'text' },
    description => { data_type => 'text' },
    folder_id   => { data_type => 'int' },
);

__PACKAGE__->set_primary_key(qw/id/);

# Every file has a folder
__PACKAGE__->belongs_to(
  "folder",
  "Icydee::Docs::DB::Schema::Folder",
  { id => "folder_id" },
);

1;
