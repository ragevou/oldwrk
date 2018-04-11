#!/usr/db/perl/CURRENT/bin/perl

use strict;
use warnings;
use Fcntl ':mode';


my $PATH = $ENV{"PATH"};
my @path_dirs = split(':', $PATH);
my $passwd = slurp_file("/etc/passwd");
my $violations = "";
# check if there is the current directory in the $PATH variable
if ($PATH =~ /(?::\.(?:\/)?(?::)?)/g) {
    $violations .= "Root's variable PATH contains \".\". Must be removed.\n";
}

my @filemode_table = (
    [[S_IFLNK,         "l"],
     [S_IFREG,         "-"],
     [S_IFBLK,         "b"],
     [S_IFDIR,         "d"],
     [S_IFCHR,         "c"],
     [S_IFIFO,         "p"]],

    [[S_IRUSR,         "r"],],
    [[S_IWUSR,         "w"],],
    [[S_IXUSR|S_ISUID, "s"],
     [S_ISUID,         "S"],
     [S_IXUSR,         "x"]],

    [[S_IRGRP,         "r"],],
    [[S_IWGRP,         "w"],],
    [[S_IXGRP|S_ISGID, "s"],
     [S_ISGID,         "S"],
     [S_IXGRP,         "x"]],

    [[S_IROTH,         "r"],],
    [[S_IWOTH,         "w"],],
    [[S_IXOTH|S_ISVTX, "t"],
     [S_ISVTX,         "T"],
     [S_IXOTH,         "x"]]
);

sub filemode {
  my $mode = shift(@_);
  my $text = "";

  foreach my $table (0..@filemode_table-1) {
    my $l = length($text);
    foreach my $sub (0..@{$filemode_table[$table]}-1) {
      my $bit = $filemode_table[$table][$sub][0];
      my $char = $filemode_table[$table][$sub][1];
      if (($mode & $bit) == $bit) {
        $text .= $char;
        last;
      }
    }
    if ($l eq length($text)) {
      $text .= "-";
    }
  }

  return $text;
}

my $dir;
my $uid;
my $perms;
my @dir_info;
while (@path_dirs) {
    $dir = shift(@path_dirs);
    @dir_info = stat($dir);
    $uid = $dir_info[4];
    if (-e $dir && -d $dir) {
      my $mode = $dir_info[2];
# check if a directory has the right permissions
      if ($mode & S_IWGRP || $mode & S_IWOTH) {
          $violations .= "Directory $dir (Root PATH directory) has wrong settings: - Wrong permissions ".filemode($mode).".\n";
      }
# find the user name of the user by his uid from /etc/passwd
      if ($passwd =~ /^(\w+):(?:\w+):$uid:.*?:.*?:.*?$/gm) {
# check if the user is something different than bin or root
        if ($1 !~ /root|bin/) {
          $violations .= "The directory $dir included in \$PATH variable is owned by $1 user. Can only be owned by root or bin user.\n";
        }
      }
    }
}

write_file("./1225.result", $violations);

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

