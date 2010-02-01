package Icydee::Docs::Web::Controller::Root;
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

use IO::Dir;
use IO::File;

BEGIN {extends 'Catalyst::Controller'};

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    # Test Grid
    $c->stash->{template} = 'index.html';
}

sub categorise: Local: {
    my ($self, $c) = @_;

    $c->stash->{template} = 'categorise.html';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
