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
BEGIN { plan tests => 754 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::MathImageUlamWarburton;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 77;
  ok ($Math::PlanePath::MathImageUlamWarburton::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageUlamWarburton->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageUlamWarburton->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageUlamWarburton->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::MathImageUlamWarburton->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::MathImageUlamWarburton->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}


#------------------------------------------------------------------------------
# random points

{
  my $path = Math::PlanePath::MathImageUlamWarburton->new;
  for (1 .. 50) {
    my $bits = int(rand(20));         # 0 to 20, inclusive
    my $n = int(rand(2**$bits)) + 1;  # 1 to 2^bits, inclusive

    my ($x,$y) = $path->n_to_xy ($n);
    my $rev_n = $path->xy_to_n ($x,$y);
    if (! defined $rev_n) { $rev_n = 'undef'; }
    ok ($rev_n, $n, "xy_to_n($x,$y) reverse to expect n=$n, got $rev_n");

    my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
    ok ($n_lo <= $n, 1, "rect_to_n_range() reverse n=$n cf got n_lo=$n_lo");
    ok ($n_hi >= $n, 1, "rect_to_n_range() reverse n=$n cf got n_hi=$n_hi");
  }
}


#------------------------------------------------------------------------------
# x,y coverage

{
  my $path = Math::PlanePath::MathImageUlamWarburton->new;
  foreach my $x (-10 .. 10) {
    foreach my $y (-10 .. 10) {
      my $n = $path->xy_to_n ($x,$y);
      next if ! defined $n;
      my ($nx,$ny) = $path->n_to_xy ($n);

      ok ($nx, $x, "xy_to_n($x,$y)=$n then n_to_xy() reverse");
      ok ($ny, $y, "xy_to_n($x,$y)=$n then n_to_xy() reverse");
    }
  }
}

exit 0;
