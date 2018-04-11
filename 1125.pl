#!/usr/db/perl/CURRENT/bin/perl

use strict;
use warnings;
use POSIX qw(uname);

my ($system) = uname();
# get mount data
my $mount = `mount`;
# get the data about the users and they home dirs
my $passwd = slurp_file("/etc/passwd");
# get the priviliged users list
my $p_users_data = slurp_file("./privileged_service_accounts");
# filter the privileged users according to the client system
my @p_users = ($p_users_data =~ m/$system:(.*)\n/g);
my $wl_p_users = join("|", @p_users);
#	print $wl_p_users; die;
#	print $1; die;
	
# setup the regex for the privileged user white list
$wl_p_users =~ s/([\w.-]+)/\^$1\$/g;
#	print $wl_p_users; die;

my @mounted_fs;
# the AIX has different mount structure
if ($system ne "AIX") {
  @mounted_fs = ($mount =~ m/on[\t\s]+(\/[\/\w.-]+)/g);
} else {
  @mounted_fs = ($mount =~ m/(?:[\t\s]+(?:\/[\/\w.-]+))(?:[\t\s]+(\/[\/\w.-]+))/g);
}
# get the regex list of mounted filesystems
my $mounted_fs = join("|", @mounted_fs);
$mounted_fs =~ s/([\/\w.-]+)/\^$1\$/g;
$mounted_fs =~ s/\//\\\//g;
# get the user and home dir of this user from passwd
my @passwd_data = ($passwd =~ m/^([\w-]+):.*:.*:.*:.*:(\/.+):.*$/gm);
my $violations = "";
# the filesystem regex whitelist
my $wl_fs = "\^\/var\/lib\/nfs\/rpc_pipefs\$|\^\/dev\/pts\$|\^\/dev\/shm\$|\^\/oracle\/.+\$|\^\/var\/lib\/named\$|\^\/home\/cognos8\/deploy\/cube\$";

while(@passwd_data) {
  my $user = shift(@passwd_data);
#	print $user."\n";

  my $home = shift(@passwd_data);
# check all the whitelist and mounted filesystems if all the conditions will be true then then a violations will be created
=cut
  if ($user !~ /$wl_p_users/ && $home !~ /$wl_fs/ && $home =~ /$mounted_fs/) {
    $violations .= "Home of user $user. Mount point '$home' is found.\n";
  }
=cut
	if ($home =~ /$mounted_fs/){print "true\n";} else {print "false\n";};

}

# the violations are written into the result files
#write_file("./1125.result", $violations);


sub slurp_file {
    my ($config_file_path) = @_;

    open(my $fh, '<', $config_file_path) or die "Could not open file '$config_file_path'! ERROR: $!";
    local $/ = undef;
    my $config_file = <$fh>;
    close($fh);

    return $config_file;
}

sub write_file {
    my ($config_file_path, $config_file) = @_;

    open (my $fh, '>', $config_file_path) or die "Could not open file '$config_file_path'! ERROR: $!";
    print $fh $config_file;
    close $fh;
}
