#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use EPublisher::Source::Plugin::MetaCPAN;

my $config = { module => 'EPublisher' };
my $obj    = EPublisher::Source::Plugin::MetaCPAN->new( $config );

my @pods   = $obj->load_source;

my @titles = qw(
    EPublisher
    EPublisher::Config
    EPublisher::Source
    EPublisher::Source::Base
    EPublisher::Source::Plugin::Dir
    EPublisher::Source::Plugin::File
    EPublisher::Source::Plugin::Module
    EPublisher::Target
    EPublisher::Target::Base
    EPublisher::Target::Plugin::Text
    EPublisher::Utils::PPI
);

is_deeply [ map{ $_->{title} }@pods ], \@titles, 'titles';
