#!/usr/db/perl/CURRENT/bin/perl

use POSIX qw(uname);
use strict;
use warnings;

my ($system)  = uname();

#get the white list for control 1120
my @exceptions_home = ("/home/oracle","/applications/maestro\*/maestro/\*","/home/\*db2\*","/var/spool/postfix/","/usr/sap/transfer/\*");
my %exceptions_user = ("svctag"=>"","messagebus"=>"/var/spool/clientmqueue\*","uuidd"=>"/var/run/uuidd","polkituser"=>"/var/run/PolicyKit");
# get the data about the users and they home dirs
my $passwd = slurp_file("/etc/passwd");
# get the priviliged users list
my $p_users_data = slurp_file("./privileged_service_accounts");
# get the user and home dir of this user from passwd
my @passwd_data = ($passwd =~ m/^([\w-]+):.*:.*:.*:.*:(\/.+):.*$/gm);
# filter the privileged users according to the client system
my @p_users = ($p_users_data =~ m/$system:(.*)\n/g);
my $wl_p_users = join("|", @p_users);
#shell command to get rights and users for home directory
my $home_command_line = "ls -l /home | cut -d' ' -f1,3";

# setup the regex for the privileged user white list
my $wl_p_users =~ s/([\w.-]+)/\^$1\$/g;
my @excep_result = "";
my @result = "";


while(@passwd_data) {
  my $user = shift(@passwd_data);
#	print $user."\n";

  my $home = shift(@passwd_data);

#Check if the home directory is in exception list
  foreach my $home_elem (@exceptions_home){
	if ($home_elem eq $home){
		push @excep_result, $user;
	} else (push @result, $user;)
  }

#Check if user + home directory are in exception list
while (my ($key, $value) = each %exception_user){
  if ($key eq $user && $value eq $home){
  	push @excep_result, $user;
  } else (push @result, $user;)
}

#getting array of rights and users from command line
my @output_users = `$home_command_line`;
chomp @output_users;

my $a = 1;
my $arr_user_size = scalar @output_users;

#getting rights and user from array
while (@output_users){
  if ($a < $arr_user_size){
    my $rights_user = $output_users[$a];
  
    my @sub_array = split(/\s/, $rights_user);
#    my $new = substr $sub_array[0], 1;
#    if ()  

    $a++;
    last;
  }
}

=cut
#Check if user + home directory are in exception list
  my @user_names = keys %exceptions_user;
  while(@user_names){
	my $i=0;
	if ($user_names[i] eq $user){
		push @excep_result, $user;
	} else (push @result, $user;)
	$i++;
  }
=cut
  
}
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
#       print $config_file;
           open (my $fh, '>', $config_file_path) or die "Could not open file '$config_file_path'! ERROR: $!";
#               print $fh $config_file;
           close $fh;
}


sub get_linux_distro {
    my $release = `cat /etc/*-release`;
    my @system = ($release =~ m/(Red Hat|SUSE)/g);
    return $system[0];
}

