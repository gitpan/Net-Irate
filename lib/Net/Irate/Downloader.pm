package Net::Irate::Downloader;

use Data::Dumper;
use Net::Irate::Track;
use LWP::UserAgent;
use URI::Escape;

@ISA = ("LWP::UserAgent");

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = $class->SUPER::new();

    $self->{dl_cb} = \&download_callback;

    bless ($self, $class);          # reconsecrate
    return $self;
}

sub get_url {
    my $self = shift;
    my $url = shift;
    my $dest = shift;

    $sz = -s $dest || 0;

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

    my $url = $track->url;
    my $dest = "/home/thayer/irate/download/" . calc_filename($url);

    $self->{ctr} = undef;
    $resp = $self->get_url($url, $dest);

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

## functions
sub calc_filename {
    my $url = shift;

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

sub download_cb {
    my $dat = shift;
    my $resp = shift;
    my $prot = shift;

    my $ua = $prot->{ua};

    if($ua->{ctr} eq undef &&
       $resp->header('Content-Length') > 0) {
	print "Size: ", $resp->header('Content-Length'), "\n";
    }

    $ua->{ctr} += length($dat);
    $ofile = $ua->{output_file};

    print $ofile $dat;

    if($ua->{ctr} > 10000) {
	print ".";
	$ua->{ctr} = 0;
    }
}


