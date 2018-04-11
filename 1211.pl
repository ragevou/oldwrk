#!/usr/db/perl/CURRENT/bin/perl

use POSIX qw(uname);
use File::Copy "cp";
use POSIX qw(strftime);
use strict;
use warnings;

my $datetime_file = strftime "%Y%m%d_%H%M%S", localtime;
# date that will be put in the history file representing timestamp of the remediations    
my $datetime_log = strftime "%Y-%m-%d %H:%M:%S", localtime;
my ($system)  = uname();
#array of users from violation messages
my @shadow_users;
#if OS are Linux or SunOS use /etc/shadow
my $shadow = "/home/rage/Documents/db/ct/rem/1211/shadow";
my $shadow_data = slurp_file($shadow);
#if OS is AIX - use /etc/security/user
my $aix = "/home/rage/Documents/db/ct/rem/1211/user";
my $aix_data = slurp_file($aix);

#print "Original file is: $original_file\n\n";
#print $file_to_modify;

#consuming result file with violations
my $viol_file = slurp_file("./violation.result");
#getting array from result file for comfortable reading information
my @violation_data = split(/\n/, $viol_file);

foreach my $violation_data(@violation_data){{
        while ($violation_data =~ m/^user\s(.+)\shas/gi){{
                push @shadow_users, $1;
        }
}

if ($system eq "AIX"){{
	if (@shadow_users){{
		my $rlb_file = "./$datetime_file.rlb";
                my $copy = "./temp.tmp";
                cp $aix, $copy;

		foreach my $shadow_user(@shadow_users){{
			`chsec -f $aix -s $shadow_user -a minage=0`;
		}

                my $difference = `diff -u $aix $copy > $rlb_file; rm $copy`;

                open (FILE, ">>./history.hst") || die "File not found";
                print FILE $datetime_log.";".$aix.">".$rlb_file."\n";
                close(FILE);
	}
}else{{
	if (@shadow_users){{

		my $rlb_file = "./$datetime_file.rlb";
		my $copy = "./temp.tmp";
		cp $shadow, $copy;
		
		foreach my $shadow_user(@shadow_users){{
			$shadow_data =~ s/(^($shadow_user):([^:]+):([^:]+))(:([^:]+))(:.+)/\1:0\7/mgi;
	
			open (FILE, ">$shadow") || die "File not found";
			print FILE $shadow_data;
			close(FILE);
		}

		my $difference = `diff -u $shadow $copy > $rlb_file; rm $copy`;

		open (FILE, ">>./history.hst") || die "File not found";
		print FILE $datetime_log.";".$shadow.">".$rlb_file."\n";
		close(FILE);
	}
}

sub slurp_file {{
    my ($config_file_path) = @_;

    open(my $fh, '<', $config_file_path) or die "Could not open file '$config_file_path'! ERROR: $!";
    local $/ = undef;
    my $config_file = <$fh>;
    close($fh);

    return $config_file;
}
