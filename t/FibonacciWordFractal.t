#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
plan tests => 5;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::MathImageFibonacciWordFractal;

#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 79;
  ok ($Math::PlanePath::MathImageFibonacciWordFractal::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageFibonacciWordFractal->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageFibonacciWordFractal->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageFibonacciWordFractal->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");
}


#------------------------------------------------------------------------------
# xy_to_n() near origin

{
  my $bad = 0;
  my $path = Math::PlanePath::MathImageFibonacciWordFractal->new;
 OUTER:
  foreach my $x (-8 .. 16) {
    foreach my $y (-8 .. 16) {
      my $n = $path->xy_to_n ($x,$y);
      next unless defined $n;
      my ($nx,$ny) = $path->n_to_xy ($n);

      if ($nx != $x || $ny != $y) {
        MyTestHelpers::diag("xy_to_n($x,$y) gives n=$n, which is $nx,$ny");
        last OUTER if ++$bad > 10;
      }
    }
  }
  ok ($bad, 0);
}

exit 0;
