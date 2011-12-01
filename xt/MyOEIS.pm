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

# uncomment this to run the ### lines
#use Devel::Comments;

my $without;

sub import {
  shift;
  foreach (@_) {
    if ($_ eq '-without') {
      $without = 1;
    } else {
      die __PACKAGE__." unknown option $_";
    }
  }
}

sub oeis_dir {
  require File::Spec;
  if ($without) {
    return undef;
  }
  return File::Spec->catfile ($ENV{'HOME'} || File::Spec->curdir,
                              'OEIS');
}

sub anum_validate {
  my ($anum) = @_;
  unless ($anum =~ /^A?0*([0-9]{6,})$/) {
    require Carp;
    Carp::croak("Bad A-number: $anum");
  }
  return $1;
}

sub anum_to_bfile {
  my ($num, $prefix) = @_;
  ### anum_to_bfile: @_
  $prefix ||= 'b';
  return sprintf '%s%06d.txt', $prefix, $num;
}
sub anum_to_html {
  my ($num, $suffix) = @_;
  ### anum_to_html: @_
  $suffix ||= '.html';
  return sprintf 'A%06d%s', $num, $suffix;
}

sub read_values {
  my ($anum, %option) = @_;
  $anum = anum_validate ($anum);

  if ($without) {
    return;
  }

  my ($aref, $lo, $filename) = _read_values($anum, %option)
    or return;
  # MyTestHelpers::diag("$filename read ",scalar(@$aref)," values");
  return ($aref, $lo, $filename);
}

sub _read_values {
  my ($anum, %option) = @_;

  require File::Spec;
  require POSIX;
  my $max_value = $option{'max_value'}
    || POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5);

 ABFILE: foreach my $basefile
    (anum_to_bfile($anum,'a'), anum_to_bfile($anum)) {

    # a003849.txt has replication level words rather than the individual
    # sequence values
    next if $basefile eq 'a003849.txt';

    # a027750.txt is unflattened divisors
    next if $basefile eq 'a027750.txt';

    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename

    if (open FH, "<$filename") {
      my @array;
      my $lo;
      while (defined (my $line = <FH>)) {
        $line =~ s/^\s+//;     # leading white space
        next if $line eq '';   # ignore blank lines
        next if $line =~ /^#/; # ignore comment lines, eg. b006450.txt

        # eg. a005228.txt source code not numbers, skip file
        if ($line =~ /^From [A-Za-z]/) {
          next ABFILE;
        }

        # a002260.txt some text not numbers, skip file
        if ($line =~ /^Doubly/) {
          next ABFILE;
        }

        my ($i, $n) = split /\s+/, $line;
        if (! defined $lo) {
          $lo = $i;
        }
        if (! (defined $n && $n =~ /^-?[0-9]+$/)) {
          die "oops, bad line in $filename: '$line'";
        }
        if ($max_value eq 'unlimited') {
          if (length($n) > 9) {
            require Math::BigInt;
            $n = Math::BigInt->new($n);
          }
        } else {
          if ($n > $max_value) {
            # MyTestHelpers::diag("$filename stop at bignum value: $line");
            last;
          }
        }
        push @array, $n;
      }
      close FH or die;
      return (\@array, $lo, $filename);
    }
    ### no bfile: $!
  }

  foreach my $basefile (anum_to_html($anum), anum_to_html($anum,'.htm')) {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    unless (open FH, "< $filename") {
      ### no html: $!
      next;
    }
    my $contents = do { local $/; <FH> }; # slurp
    close FH or die;

    unless ($contents =~ /OFFSET(\s*<[^>]*>)*\s*([0-9-]+)/s) {
      MyTestHelpers::diag("$filename oops OFFSET not found");
      die;
    }
    my $lo = $2;

    # fragile grep out of the html ...
    $contents =~ s{>graph</a>.*}{};
    $contents =~ m{.*<tt>([^<]+)</tt>};
    my $list = $1;
    unless ($list =~ m{^([0-9,-]|\s)+$}) {
      MyTestHelpers::diag("$filename oops list of values not found");
      die;
    }
    my @array = split /[, \t\r\n]+/, $list;
    ### $list
    ### @array
    return (\@array, $lo, $filename);
  }
  return;
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
