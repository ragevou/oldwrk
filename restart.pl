#!/usr/db/perl/CURRENT/bin/perl
#This code checks the last modification time of the last besclient log file
#If the log file was modified lond time ago - the besclient will be restarted
#Can be used for SunOS, Linux and AIX operating systems
#
#Author: Alexandra Nikandrova a.nikandrova@cz.ibm.com
#Date: 2018-01-19
#Version: 1
#GTS Infrastructure Services Delivery

use strict;
use warnings;

use File::stat;
use POSIX qw(strftime);
use POSIX qw(uname);

my $system  = uname();
my $LOGDIR = "/var/opt/BESClient/__BESData/__Global/Logs";

#Find current time minus 12 hours - to compare with last modification timestamp
my $last_time = time() - 12 * 60 * 60;
my $newest_time = 0;


opendir(my $dh, $LOGDIR) || die "Can't open $LOGDIR: $!";
while (my $fn = readdir($dh))
  {
    my $fp = "$LOGDIR/$fn";

#Check if element is a file
    if (! -f "$fp")
      {
        next;
      }

#Get modification time
    my $st = stat("$fp");
    my $mtime = $st->mtime;

#Equate modification time to latest, if it's more then previous time - to find the timestamp of the last log file
    if ($mtime > $newest_time)
      {
        $newest_time = $mtime;
      }
  }
closedir($dh);

#Restart besclient in case of the last modification time was more then 12 hours ago
if ($last_time >= $newest_time)
  {
    if ($system eq "AIX") 
      {
        `/etc/rc.d/rc2.d/SBESClientd stop`;
        sleep 10;
        `/etc/rc.d/rc2.d/SBESClientd start`;
      }
    elsif ($system eq "SunOS")
      {
        `svcadm disable BESClient`;
        sleep 10;
        `svcadm enable BESClient`;
      }
    else
      {
        `/etc/init.d/besclient stop`;
        sleep 10;
        `/etc/init.d/besclient start`;
      }
  }
