package Net::Irate::Track;

use strict;
use XML::TreeBuilder;
use URI::Escape;

sub new {
    my $pkg = shift || __PACKAGE__;

    my $self = { };

    $self->{track} = shift || XML::Element->new('track');

    bless $self => $pkg;

    return $self;
}

sub track {
    my $self = shift;

    return $self->{track};
}

sub is_downloadable {
    my $self = shift;

    if($self->file eq undef &&
       $self->state ne "broken") {
	return 1;
    } else {
	return 0;
    }
}

sub file {
    my $self = shift;

    if(@_) { $self->track->attr("file", shift); }
    return $self->track->attr("file");
}

sub xml {
    my $self = shift;

    return $self->{track}->as_XML;
}

sub state {
    my $self = shift;

    if(@_) { $self->track->attr("state", shift); }
    return $self->track->attr("state");
}

sub url {
    my $self = shift;

    if(@_) { $self->track->attr("url", shift); }
    return $self->track->attr("url");
}

sub rating {
    my $self = shift;

    if(@_) { $self->track->attr("rating", shift); }
    return $self->track->attr("rating");
}

sub calc_filename {
    my $self = shift;

    my $url = $self->url;

    my $t = uri_unescape($url);
    $t =~ s/\s+/_/g;
    $t =~ s/_+/_/g;
    $t =~ s/[\'\"\,\!\(\)]//g;
    $t =~ s/\&/and/g;
    $t =~ s/_-_/-/g;
    $t =~ s/-none-/-/ig;
    $t =~ s/-unknown-/-/ig;
    my @fn_parts = split(/\//, $t);
    my $fn = pop(@fn_parts);

    return $fn;
}


1;


