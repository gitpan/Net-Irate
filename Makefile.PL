use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME            => 'Net::Irate',
	      VERSION_FROM    => 'lib/Net/Irate.pm',
	      AUTHOR   => 'Doug Thayer <d_l_thayer@yahoo.com>',
	      ABSTRACT => 'Client interface to Irate <irate.sf.net>',
	      PREREQ_PM =>  {
		  'XML::TreeBuilder' => 3.08,
		  'LWP::UserAgent' => 2.024,
	      },
      
	      );
