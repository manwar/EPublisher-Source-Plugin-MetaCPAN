package EPublisher::Source::Plugin::MetaCPAN;

use strict;
use warnings;

use File::Basename;
use MetaCPAN::API;

use EPublisher::Source::Base;
use EPublisher::Utils::PPI qw(extract_pod_from_code);

our @ISA = qw( EPublisher::Source::Base );

our $VERSION = 0.01;

# implementing the interface to EPublisher::Source::Base
sub load_source{
    my ($self) = @_;

    my $options = $self->_config;
    
    return '' unless $options->{module};

    my $module = $options->{module};    # the name of the CPAN-module
    my $mcpan  = MetaCPAN::API->new;

    # fetiching the requested module from meatcpan
    my $module_result = $mcpan->fetch( 'release/' . $module );

    # this produces something like e.g. "EPublisher-0.6"
    my $release  = sprintf "%s-%s", $module, $module_result->{version};

    # get the manifest with module-author and modulename-moduleversion
    my $manifest = $mcpan->source(
        author  => $module_result->{author},
        release => $release,
        path    => 'MANIFEST',
    );

    # make a list from all possible POD-files in the lib directory
    my @files     = split /\n/, $manifest;
    my @pod_files = grep{ /^lib\/.*\.p(?:od|m)\z/ }@files;

    # here whe store POD if we find some later on
    my @pod;

    # look for POD
    for my $file ( @pod_files ) {

        my $result = $mcpan->pod(
            author         => $module_result->{author},
            release        => $release,
            path           => $file,
            'content-type' => 'text/x-pod',
        );

        next if $result eq '{}';
        
        # check if $result is always only the Pod
        #push @pod, extract_pod_from_code( $result );
        my $filename = basename $file;
        my $title    = $file;

        $title =~ s{lib/}{};
        $title =~ s{\.p(?:m|od)\z}{};
        $title =~ s{/}{::}g;
 
        push @pod, { pod => $result, filename => $filename, title => $title };
    }
    
    # voilà
    return @pod;
}

1;

=head1 NAME

EPublisher::Source::Plugin::MetaCPAN - MetaCPAN source plugin

=head1 SYNOPSIS

  my $source_options = { type => 'MetaCPAN', module => 'Moose' };
  my $url_source     = EPublisher::Source->new( $source_options );
  my $pod            = $url_source->load_source;

=head1 METHODS

=head2 load_source

  $url_source->load_source;

reads the URL 

=head1 COPYRIGHT & LICENSE

Copyright 2012 Renee Baecker and Boris Daeppen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of Artistic License 2.0.

=head1 AUTHOR

Renee Baecker (E<lt>module@renee-baecker.deE<gt>), Boris Daeppen (E<lt>boris_daeppen@bluewin.chE<gt>)

=cut
