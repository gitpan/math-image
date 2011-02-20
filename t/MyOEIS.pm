#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# MyOEIS.pm is shared by several distributions.
#
# MyOEIS.pm is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# MyOEIS.pm is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this file.  If not, see <http://www.gnu.org/licenses/>.

package MyOEIS;
use strict;
use warnings;

# uncomment this to run the ### lines
#use Smart::Comments;


sub oeis_dir {
  require File::Spec;
  return File::Spec->catfile (File::Spec->updir, 'oeis');
}

sub anum_validate {
  my ($anum) = @_;
  unless ($anum =~ /^A?([0-9]{6,})$/) {
    require Carp;
    Carp::croak("Bad A-number: $anum");
  }
  return $1;
}

sub anum_to_bfile {
  my ($str, $prefix) = @_;
  ### anum_to_bfile: @_
  $prefix ||= 'b';
  $str =~ s/^A(.*)/$prefix$1.txt/;
  return $str;
}

sub read_values {
  my ($anum) = @_;
  $anum = anum_validate ($anum);

  my ($aref, $filename) = _read_values($anum);
  if (defined $aref) {
    Test::More::diag("$filename read ",scalar(@$aref)," values");
  }
  return $aref;
}

sub _read_values {
  my ($anum) = @_;

  require POSIX;
  my $max_value = POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5);

  require File::Spec;
  foreach my $basefile (anum_to_bfile($anum,'a'), anum_to_bfile($anum)) {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    
    if (open FH, "<$filename") {
      my @array;
      while (defined (my $line = <FH>)) {
        chomp $line;
        next if $line =~ /^\s*$/;   # ignore blank lines
        my ($i, $n) = split /\s+/, $line;
        if (! (defined $n && $n =~ /^-?[0-9]+$/)) {
          die "oops, bad line in $filename: '$line'";
        }
        if ($n > $max_value) {
          Test::More::diag("$filename stop at bignum value: $line");
          last;
        }
        push @array, $n;
      }
      close FH or die;
      return (\@array, $filename);
    }
    ### no bfile: $!
  }

  foreach my $basefile ("$anum.html", "$anum.htm") {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    if (open FH, "<$filename") {
      my $contents = do { local $/; <FH> }; # slurp
      close FH or die;

      # fragile grep out of the html ...
      $contents =~ s{>graph</a>.*}{};
      $contents =~ m{.*<tt>([^<]+)</tt>};
      my $list = $1;
      unless ($list =~ m{^([0-9,-]|\s)+$}) {
        Test::More::diag("$filename oops list of values not found");
        return undef;
      }
      my @array = split /[, \t\r\n]+/, $list;
      ### $list
      ### @array
      return (\@array, $filename);
    }
    ### no html: $!
  }
  return undef;
}

# with Y reckoned increasing downwards
sub dxdy_to_direction {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # south
  if ($dy < 0) { return 3; }  # north
}

1;
__END__
