package Net::Irate::Track;

use XML::TreeBuilder;

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

1;


