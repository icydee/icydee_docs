#!/app/aupa/bin/perl
#
# Test the email archive by checking the date/time of the last email sent
#
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Icydee::Docs::DB;
use DateTime;
use DateTime::Duration;
use File::Util;
use YAML;
use Data::Dumper;

#
# This odd line allows the program to be tested without running it!
#
main(@ARGV) unless caller();

#################### subroutines ##########################

#
# Main routine, just takes ARGV
#
sub main {

    my $config = YAML::LoadFile("$FindBin::Bin/../icydee_docs_web.yml");

    my $schema = Icydee::Docs::DB->connect(
        $config->{DB}{dsn},
        $config->{DB}{username},
        $config->{DB}{password},
        $config->{DB}{dbi_attr},
        $config->{DB}{extra_attr}
    );

    if (! $schema) {
        croak("ERROR: cannot connect to database\n");
    }

    my $trees = $schema->resultset('Folders');

    if (! $trees) {
        croak("ERROR: Cannot get 'Folder' resultset");
    }

    my $root = $trees->create({ title => 'root' });
    if (! $root) {
        croak("ERROR: Cannot create root");
    }

    my $personal = $root->add_to_children({ title => 'Personal' });
    my $business = $root->add_to_children({ title => 'Business' });
    $business->add_to_children({ title => 'Icydee' });
    $business->add_to_children({ title => 'PanLok' });
    $business->add_to_children({ title => 'Horivert' });


}
1;
