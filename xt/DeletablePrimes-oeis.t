#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use Test;
BEGIN { plan tests => 11 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::NumSeq::MathImageDeletablePrimes;

# uncomment this to run the ### lines
#use Smart::Comments '###';


sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  my $i = 0;
  while ($i < @$a1 && $i < @$a2) {
    if ($a1->[$i] ne $a2->[$i]) {
      return 0;
    }
    $i++;
  }
  return (@$a1 == @$a2);
}


#------------------------------------------------------------------------------
# A096235 to A096245

foreach my $num (96235 .. 96245) {
  my $anum = sprintf 'A%06d', $num;
  my $radix = $num - 96235 + 2; # A096235 binary

  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $bvalues_length_full = scalar(@$bvalues);

    {
      my $trunc = 1;
      my $pow = $radix;
      while ($pow < 100000) {
        $pow *= $radix;
        $trunc++;
      }
      $#$bvalues = $trunc;
    }
    my $bvalues_length = scalar(@$bvalues);
    MyTestHelpers::diag ("$anum has $bvalues_length_full values, truncate to $bvalues_length");

    my $seq  = Math::NumSeq::MathImageDeletablePrimes->new (radix => $radix);
    my $pow = $radix;
    my $count = 0;
    while (@got < @$bvalues) {
      my ($i, $value) = $seq->next;
      if ($value >= $pow) {
        push @got, $count;
        $count = 0;
        $pow *= $radix;
      }
      $count++;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- num n-digit deletable primes");
}

#------------------------------------------------------------------------------
exit 0;
