#!/usr/bin/perl

##!/usr/db/perl/CURRENT/bin/perl

use strict;
use warnings;
use POSIX qw(strftime);

#my $timestamp = strftime "%Y%m%d", localtime;
my $datetime_log = strftime "%Y-%m-%d %H:%M:%S", localtime;
#my $path_to_log_files = "/repo/strategic/etllogs";
my $path_to_log_files = "/home/rage/Documents/db/ct/log_maintaince";

my $list_of_files = `ls $path_to_log_files`;

#getting array from list of files for comfortable reading information
my @files_to_be_filtered = split(/\n/, $list_of_files);

my @deleted_logs;

foreach my $file_to_be_filtered(@files_to_be_filtered){
	if ($file_to_be_filtered =~ /(^secmart|bpm).+/gi){
		`rm -f $path_to_log_files/$file_to_be_filtered`;
		push @deleted_logs, "$path_to_log_files/$file_to_be_filtered";
	}
}

my $list_of_scan_error_log = `ls -1tr $path_to_log_files/scan_error* | head -n-5`;

my  @scan_error_logs = split(/\n/, $list_of_scan_error_log);

foreach my $scan_error_log(@scan_error_logs){
	`rm -f $scan_error_log`;
	push @deleted_logs, $scan_error_log;
}

my $list_of_ecm_log = `ls -1tr $path_to_log_files/ecm* | head -n-20`;

my @ecm_logs = split(/\n/, $list_of_ecm_log);

foreach my $ecm_log(@ecm_logs){
	`rm -f $ecm_log`;
	push @deleted_logs, $ecm_log;
}

my $deleted_logs_line = join(";", @deleted_logs);

print "$deleted_logs_line\n";

open (FILE, ">>./deleted_log_files.log") || die "File not found";
print FILE $datetime_log.";".$deleted_logs_line."\n";
close(FILE);
 
