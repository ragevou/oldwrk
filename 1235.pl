#!/usr/db/perl/CURRENT/bin/perl

use POSIX qw(uname);
use strict;
use warnings;
use File::Copy "cp";

my ($system)  = uname();

#consuming result file with violations
my $viol_file = slurp_file("./1235.result");

#if ($system eq "Linux"){

#regex to parse the violations
my $viol_regex = qr/([\d]{1,4}).*in\s(\/.*?)\.\s/; 
#getting array from result file for comfortable reading information
my @violation_data = split(/\n/, $viol_file);

foreach my $violation_data(@violation_data){
#	while ($violation_data =~ m/([\d]{1,4}).*in\s(\/.*?)\.\s/g){
	while ($violation_data =~ m/in\s+(.+)\.\s+Must/g){
#		print "umask: $1, file: $2\n";
		push @config_paths_linux, $1;
	}
}

#get uniq files paths because it cou be met several times in the violation file
sub uniq {
	my %seen;
	grep !$seen{$_}++, @_;
}	

my @array = @config_paths_linux;
my @filtered_conf_paths = uniq(@array);

#print "@filtered_conf_paths\n"; die;

my $i=1;

if ($system eq "Linux"){
foreach $filtered_conf_path(@filtered_conf_paths){
	if (-f $filtered_conf_path){
		cp $filtered_conf_path, $filtered_conf_path.$i;
		$i++;
        	my $config = slurp_file($filtered_conf_path);
		
		$config =~ s/^(\s*umask\s+)([0-7]{1,4})/\1 22/gmi;

		open (FILE, ">$filtered_conf_path") || die "File not found";
		print FILE $config;
		close(FILE);

                }
        }
}

if ($system eq "AIX"){
    foreach $filtered_conf_path(@filtered_conf_paths){
        if (-f $filtered_conf_path){
                cp $filtered_conf_path, $filtered_conf_path.$i;
                $i++;

    my $config = slurp_file($filtered_conf_path);
	$config =~ s/(umask[\s]=[\s])([0-7]{1,4})/\1 22/gmi;

	open (FILE, ">$filtered_conf_path") || die "File not found";
	print FILE $config;
	close(FILE);
}

if ($system eq "SunOS"){
	foreach $filtered_conf_path(@filtered_conf_paths){
        if (-f $filtered_conf_path){
                cp $filtered_conf_path, $filtered_conf_path.$i;
                $i++;

    my $config = slurp_file($filtered_conf_path);
        $config =~ s/(umask)(=[0-7]{1,4})/\1=22/gmi;

        open (FILE, ">$filtered_conf_path") || die "File not found";
        print FILE $config;
        close(FILE);
}

sub slurp_file {
    my ($config_file_path) = @_;

    open(my $fh, '<', $config_file_path) or die "Could not open file '$config_file_path'! ERROR: $!";
    local $/ = undef;
    my $config_file = <$fh>;
    close($fh);

    return $config_file;
}	
