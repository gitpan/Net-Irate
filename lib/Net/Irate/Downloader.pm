package Net::Irate::Downloader;

use strict;
use vars qw (@ISA);

use Net::Irate::Track;
use LWP::UserAgent;

@ISA = ("LWP::UserAgent");

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = $class->SUPER::new();

    $self->{dl_cb} = undef;
    $self->{destdir} = undef;

    bless ($self, $class); 
    return $self;
}

sub get_url {
    my $self = shift;
    my $url = shift;
    my $dest = shift;

    my $sz = -s $dest || 0;

    open($self->{output_file}, ">> $dest");
    my $resp = $self->get($url, 
			  'Range' => "bytes=$sz-",
			  ':content_cb' => \&download_cb);
    close $self->{output_file};

    return $resp;
}

sub get_track {
    my $self = shift;
    my $track = shift;

    my $dest = $self->{destdir} . "/" . $track->calc_filename;

    $self->{ctr} = undef;

    my $url = $track->url;
    my $resp = $self->get_url($url, $dest);

    if($resp->is_success) {
	$track->file($dest);
    } else {
	print $resp->status_line,"\n";
	if($resp->code == 404 || 
	   $resp->code == 510) {
	    $track->state("broken");
	    unlink($dest);
	}
    }
}

sub destdir {
    my $self = shift;

    if(@_) { $self->{destdir} = shift; } 
    
    return $self->{destdir};
}

sub callback {
    my $self = shift;

    if(@_) { $self->{dl_cb} = shift; }
    return $self->{dl_cb};
}


## functions
sub download_cb {
    my $dat = shift;
    my $resp = shift;
    my $prot = shift;

    my $ua = $prot->{ua};
    print {$ua->{output_file}} $dat;

    if($ua->{dl_cb} ne undef) {
	&{$ua->{dl_cb}}($ua, $resp, length($dat));
    }
}

1;
