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
BEGIN { plan tests => 4 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::MathImagePowerRationals;
use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

my $path = Math::PlanePath::MathImagePowerRationals->new;

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
# A060837 - permutation diagonals N -> power N

{
  my $anum = 'A060837';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::DiagonalRationals;
    my $columns = Math::PlanePath::DiagonalRationals->new;
    my $n = 1;
    while (@got < @$bvalues) {
      my ($x,$y) = $columns->n_to_xy ($n++);
      push @got, $path->xy_to_n($x,$y);
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A071970 - permutation Stern a[i]/[ai+1] which is CW N -> power N

{
  my $anum = 'A071970';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
    my $n = 1;
    while (@got < @$bvalues) {
      my ($x,$y) = $sb->n_to_xy ($n++);
      push @got, $path->xy_to_n($x,$y);
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A071974 - numerators

{
  my $anum = 'A071974';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A071975 - denominators

{
  my $anum = 'A071975';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues, 10000; # trim down
    foreach my $n (1 .. @$bvalues) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, $y;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


exit 0;
