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
    $c->stash->{template} = 'test.html';
}

sub tree: Local: {
    my ($self, $c) = @_;

    # Test Tree
    $c->stash->{template} = 'tree.html';
}

sub mif_tree: Local: {
    my ($self, $c) = @_;

    # Test Tree
    $c->stash->{template} = 'mif_tree.html';
}

sub pdfs: Local: {
    my ($self, $c) = @_;

    my $dir = IO::Dir->new("/var/sandbox/icydee/root/static/import");
    my @files;
    if (defined $dir) {
FILE:
        while (my $file = $dir->read) {
            next FILE if $file =~ m/^\./;
            push @files, $file;
        }
    }

    $c->stash->{files} = \@files;
    # Show pdfs
    $c->stash->{template} = 'pdfs.html';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
