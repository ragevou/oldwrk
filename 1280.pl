#!/usr/db/perl/CURRENT/bin/perl

use strict;
use warnings;

my $sshd_config_path = config_path();
my $sshd_config = slurp_file($sshd_config_path);


my %sshd_compliant_settings = ("Protocol" => ['^Protocol\s+(.+)$', "2"], "PermitRootLogin" => ['^PermitRootLogin\s+(.+)$', "without-password"], "SyslogFacility" => ['^SyslogFacility\s+(.+)$', "AUTH"], "LogLevel" => ['^LogLevel\s+(.+)$', "INFO|DEBUG|VERBOSE"], "StrictModes" => ['^StrictModes\s+(.+)$', "yes"], "RSAAuthentication" => ['^RSAAuthentication\s+(.+)$', "yes"], "PubkeyAuthentication" => ['^PubkeyAuthentication\s+(.+)$', "yes"], "AuthorizedKeysFile" => ['^AuthorizedKeysFile\s+(.+)$', '.ssh/authorized_keys'], "RhostsRSAAuthentication" => ['^RhostsRSAAuthentication\s+(.+)$', "no"], "HostbasedAuthentication" => ['^HostbasedAuthentication\s+(.+)$', "no"], "IgnoreUserKnownHosts" => ['^IgnoreUserKnownHosts\s+(.+)$', "no"], "IgnoreRhosts" => ['^IgnoreRhosts\s+(.+)$',"yes"], "PermitEmptyPasswords" => ['^PermitEmptyPasswords\s+(.+)$',"no"], "ChallengeResponseAuthentication" => ['^ChallengeResponseAuthentication\s+(.+)$',"no"], "PrintLastLog" => ['^PrintLastLog\s+(.+)$',"yes"], "KeepAlive" => ['^KeepAlive\s+(.+)$',"yes"], "UseLogin" => ['^UseLogin\s+(.+)$',"no"], "UsePrivilegeSeparation" => ['^UsePrivilegeSeparation\s+(.+)$',"yes"], "PermitUserEnvironment" => ['^PermitUserEnvironment\s+(.+)$',"no"], "PasswordAuthentication" => ['^PasswordAuthentication\s+(.+)$',"no"], "LoginGraceTime" => ['^LoginGraceTime\s+(.+)$',"120"], "MaxStartups" => ['^MaxStartups\s+(.+)$',"100"], "MaxAuthTries" => ['^MaxAuthTries\s+(.+)$',"5"], "KeyRegenerationInterval" => ['^KeyRegenerationInterval\s+(.+)$',"3600"], "GatewayPorts" => ['^GatewayPorts\s+(.+)$',"no"], "PrintMotd" => ['^PrintMotd\s+(.+)$',"yes"]);

my $property_name;
my $property_values;
my @property_values;
my $setting_regex;
my $compliant_value;
my $actual_value;
my $violations = "";

while(($property_name, $property_values) = each %sshd_compliant_settings) {

    @property_values = @$property_values;
    $setting_regex = shift(@property_values);
    $compliant_value = shift(@property_values);
    if ($sshd_config =~ /$setting_regex/m) {

      $actual_value = $1;
      if ($actual_value !~ /$compliant_value/) {
#        $violations .= "The keyword $property_name has value: $actual_value which is not compliant. The compliant value should be: $compliant_value.\n";
        $violations .= "Process /applications/ssh/CURRENT/sbin/sshd -o PidF, config file $sshd_config_path. Keyword $property_name is missing or has wrong value. Must be set at $compliant_value (default $actual_value)\n";
      }
    } else {

      $violations .= "The keyword $property_name is missing from SSH configuration file $sshd_config_path and has to have compliant value: $compliant_value.\n";
    }
}

write_file("./sshd_config.result", $violations);

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

#subroutin which finding out with path to sshd_config file is used
sub config_path{
	my $com = `ps -eo command | grep [s]shd`;
	my $path_to_config = "";

	if ($com =~ /-f/){
        	$path_to_config = "/etc/sshd_config";
	} else {$path_to_config = "/etc/ssh/sshd_config";}

	return $path_to_config;
}
