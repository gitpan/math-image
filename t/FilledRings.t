#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
plan tests => 55;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::MathImageFilledRings;

# uncomment this to run the ### lines
#use Smart::Comments;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 94;
  ok ($Math::PlanePath::MathImageFilledRings::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageFilledRings->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageFilledRings->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageFilledRings->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# _cumul_extend()

sub cumul_calc {
  my ($r) = @_;
  my $sq = ($r+.5)**2;
  my $count = 0;
  foreach my $x (-$r-1 .. $r+1) {
    my $x2 = $x*$x;
    foreach my $y (-$r-1 .. $r+1) {
      $count += ($x2 + $y*$y <= $sq);
    }
  }
  return $count + 1;
}

foreach my $r (0 .. 50) {
  my $want = cumul_calc($r);
  Math::PlanePath::MathImageFilledRings::_cumul_extend();
  my $got = $Math::PlanePath::MathImageFilledRings::_cumul[$r];
  ok ($got, $want, "r=$r");
}

exit 0;


