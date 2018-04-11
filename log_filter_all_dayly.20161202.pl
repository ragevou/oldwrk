#!/usr/bin/perl

##!/usr/db/perl/CURRENT/bin/perl

use strict;
use warnings;
use POSIX qw(strftime);

my $timestamp = strftime "%Y%m%d", localtime;
my $datetime_log = strftime "%Y-%m-%d %H:%M:%S", localtime;
#my $path_to_log_files = "/repo/ecm/ecm/";
my $path_to_log_files = "/home/rage/Documents/db/ct/arch/";

my $list_of_files = `ls $path_to_log_files`;

#getting array from list of files for comfortable reading information
my @files_to_be_filtered = split(/\n/, $list_of_files);
my @files_to_be_modified;
my @unzipped_files;
my @filtered_lines;
my @LINES;
my @modified_files;

my $extracted_file;

foreach my $file_to_be_filtered(@files_to_be_filtered){
	while ($file_to_be_filtered =~ /viol.+02.(\d{8})/gi){
		if ($1 eq $timestamp){
			push @files_to_be_modified, $file_to_be_filtered;
		}

	}
}

foreach my $file_to_be_modified(@files_to_be_modified){
	while($file_to_be_modified =~ /(.+).gz/gi){
		my $unzipped_file = $1;
		my $full = $path_to_log_files.$file_to_be_modified;
		my $unzip = $path_to_log_files.$unzipped_file;
		$extracted_file = `gunzip -c $full > $unzip`;
		push @unzipped_files, $unzip;
		`rm -f $full`;
	}
}

foreach my $unzipped_file(@unzipped_files){
	open(FILE,"<$unzipped_file");
	my $first_line = <FILE>;
	@LINES = <FILE>;
	close(FILE); 
	
	foreach my $LINE(@LINES){
		while ($LINE =~ /^.+D041-S-Gv2.3.1-WIN.+|^.+D041-A-Gv2.3.1-IIS-WIN.+|^.+D041-A-Gv2.3.1-WEBLOGIC-UNIX.+|^.+D041-A-Gv2.3.1-APACHE-AIX.+|^.+D041-A-Gv2.3.1-APACHE-LNXSUN.+|^.+D041-A-Gv2.3.1-APACHE-WIN.+|^.+D041-A-Gv2.3.1-MQM-WIN.+|^.+D041-A-Gv2.3.1-MQM-aix.+|^.+D041-A-Gv2.3.1-MQM-LNXSUN.+|^.+D041-A-Gv2.3.1-CITRIX-WIN.+|^.+D041-A-Gv2.3.1-TWS-UNIX.+|^.+D041-A-Gv2.3.1-SLS-UNIX.+|^.+D041-A-Gv2.3.1-DB2-UNIX.+|^.+D041-C-Gv2.3.1-AIX.+|^.+D041-C-Gv2.3.1-LNX.+/gim){
			push @filtered_lines, $LINE;
			
		}
	}
	
	my $filtered_line_file = "$path_to_log_files.temp.txt";
	open (FILE,">>$filtered_line_file");
	print FILE "$first_line";
	foreach my $filtered_line(@filtered_lines){
		print FILE "$filtered_line";
	}
	close (FILE);

	`rm -f $unzipped_file`;
	`mv $filtered_line_file $unzipped_file`;	
	`gzip $unzipped_file`;
	
	push @modified_files, "$unzipped_file.gz";	
}

	my $modified_files_line = join(";", @modified_files);
        
        open (FILE, ">>./filter_log_files.log") || die "File not found";
        print FILE $datetime_log.";".$modified_files_line."\n";
        close(FILE);
