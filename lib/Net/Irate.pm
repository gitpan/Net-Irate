package Net::Irate;

$VERSION="0.1";

use LWP::UserAgent;
use XML::TreeBuilder;

use Net::Irate::Track;
use Net::Irate::Downloader;

sub new {
    my $pkg = shift || __PACKAGE__;
    my $self = shift || { };

    if($self->{downloader} eq undef) {
	$self->{downloader} = Net::Irate::Downloader->new;
    }

    bless $self => $pkg;

    if($self->{file} ne undef) {
	$self->load();
    }

    return $self;
}

sub load {
    my $self = shift;

    if($self->{tree} ne undef) {
	$self->{tree}->delete;
    }

    $self->{tree} = new XML::TreeBuilder;
    if(-e $self->{file}) {
	$self->{tree}->parse_file($self->{file});
	$self->{user} = $self->{tree}->look_down("_tag", "User");
	
	if($self->{name}) { 
	    $self->{user}->attr("name", $self->{name});
	}
	if($self->{password}) {
	    $self->{user}->attr("password", $self->{password});
	}
    } else {
	if(! $self->{name} || ! $self->{password}) {
	    die "must provide name and password to create new database";
	}
	
	$self->{tree}->tag("TrackDatabase");
	$self->{user} = new XML::Element("User", 
					 host => "server.irateradio.org", 
					 name => $self->{name},
					 password => $self->{password},
					 client => "Net::Irate 0.1",
					 port => "2278"
					 );	
	$self->{tree}->push_content($self->{user});
    }

    $self->{index} = 0;
    $self->{tracks} = [];
    foreach $trk ($self->{tree}->look_down("_tag", "Track")) {
	push( @{$self->{tracks}}, new Net::Irate::Track($trk));
    }

}

sub save {
    my $self = shift;
    my $file = shift || $self->{file};

    open(O, "> $file");
    print O $self->{tree}->as_XML;
    close O;
}

sub contact_server {
    my $self = shift;

    my $url = "http://" . $self->{user}->attr("host") . ":" . 
	$self->{user}->attr("port") . "/";

    my $req = new HTTP::Request GET => $url;
    $req->content($self->{tree}->as_XML);
    my $ret = $self->{downloader}->request($req);

    if (! $ret->is_success) {
	die "not ok\n";
    }

    my $t2 = XML::TreeBuilder->new;
    $t2->parse($ret->content);
    $self->{tree}->push_content($t2->look_down("_tag", "Track"));

    foreach $trk ($t2->look_down("_tag", "Track")) {
	push(@{$self->{tracks}}, new Net::Irate::Track($trk));
    }
}

sub download_track {
    my $self = shift;
    my $track = shift;

    $self->{downloader}->get_track($track);
}

sub first_track {
    my $self = shift;

    $self->{index} = 0;
    return $self->track;
}

sub next_track {
    my $self = shift;

    if( @{$self->{tracks}} > ($self->{index} +1)) {
	$self->{index} ++;
	return $self->track;
    } else {
	return undef;
    }
}

sub track {
    my $self = shift;

    return ${$self->{tracks}}[$self->{index}];
}

sub tracks {
    my $self = shift;

    return @{$self->{tracks}};
}


sub get_fetch {
    my $self = shift;
    my @tracks;

    foreach $track ($self->{tracks}) {
	if($track->file eq undef && 
	   $track->state eq undef) {
	    push(@tracks, $track);
	}
    }
    return @tracks;
}

1;

