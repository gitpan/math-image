#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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
BEGIN { plan tests => 3 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::MathImageFractionsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

#------------------------------------------------------------------------------
# A093873 -- Kepler numerators

# {
#   my $path  = Math::PlanePath::MathImageFractionsTree->new (tree_type => 'Kepler');
#   my $anum = 'A093873';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     foreach my $n (1 .. @$bvalues) {
#       my ($x, $y) = $path->n_to_xy (int(($n+1)/2));
#       push @got, $x;
#     }
#     MyTestHelpers::diag ("$anum has $#$bvalues values");
#   } else {
#     MyTestHelpers::diag ("$anum not available");
#   }
#   ### bvalues: join(',',@{$bvalues}[0..20])
#   ### got: '    '.join(',',@got[0..20])
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum -- Kepler tree numerators");
# }
# 
# sub sans_high_bit {
#   my ($n) = @_;
#   return $n ^ high_bit($n);
# }
# sub high_bit {
#   my ($n) = @_;
#   my $bit;
#   for ($bit = 1; $bit <= $n; $bit <<= 1) {
#     $bit <<= 1;
#   }
#   return $bit >> 1;
# }

#------------------------------------------------------------------------------
# A093875 -- Kepler denominators

# {
#   my $path  = Math::PlanePath::MathImageFractionsTree->new (tree_type => 'Kepler');
#   my $anum = 'A093875';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     foreach my $n (2 .. @$bvalues) {
#       my ($x, $y) = $path->n_to_xy (int($n/2));
#       push @got, $y;
#     }
#     MyTestHelpers::diag ("$anum has $#$bvalues values");
#   } else {
#     MyTestHelpers::diag ("$anum not available");
#   }
#   ### bvalues: join(',',@{$bvalues}[0..20])
#   ### got: '    '.join(',',@got[0..20])
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1, "$anum -- Kepler tree denominators");
# }


#------------------------------------------------------------------------------
# A020651 -- Kepler half-tree numerators

{
  my $path  = Math::PlanePath::MathImageFractionsTree->new (tree_type => 'Kepler');
  my $anum = 'A020651';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Kepler half-tree numerators");
}

#------------------------------------------------------------------------------
# A086592 -- Kepler half-tree denominators

{
  my $path  = Math::PlanePath::MathImageFractionsTree->new (tree_type => 'Kepler');
  my $anum = 'A086592';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Kepler half-tree denominators");
}

#------------------------------------------------------------------------------
# A086593 -- Kepler half-tree denominators, every second value

{
  my $path  = Math::PlanePath::MathImageFractionsTree->new (tree_type => 'Kepler');
  my $anum = 'A086593';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy (2*$n-1);
      push @got, $y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Kepler half-tree denominators every second value");
}

#------------------------------------------------------------------------------
exit 0;
