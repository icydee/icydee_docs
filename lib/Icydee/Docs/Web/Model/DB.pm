package Icydee::Docs::Web::Model::DB;
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

BEGIN {extends 'Catalyst::Model::DBIC::Schema'};

__PACKAGE__->config(
    schema_class    => 'Icydee::Docs::DB',
    connect_info => [
        Icydee::Docs::Web->config->{DB}{dsn},
        Icydee::Docs::Web->config->{DB}{username},
        Icydee::Docs::Web->config->{DB}{password},
        { 'mysql_enable_utf8' => 1 },
        { on_connect_do =>[ 'set names utf8' ] },
    ]
);

1;
