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
BEGIN { plan tests => 263 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::MathImageCellularRule246;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 77;
  ok ($Math::PlanePath::MathImageCellularRule246::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageCellularRule246->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageCellularRule246->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageCellularRule246->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::MathImageCellularRule246->new;
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
  my $path = Math::PlanePath::MathImageCellularRule246->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 0, 'y_negative()');
}
{
  my @pnames = map {$_->{'name'}}
    Math::PlanePath::MathImageCellularRule246->parameter_info_list;
  ok (join(',',@pnames), '');
}


#------------------------------------------------------------------------------
# rect_to_n_range()

{
  my $path = Math::PlanePath::MathImageCellularRule246->new;
  foreach my $i (0 .. 50) {
    {
      my $n_left = $path->xy_to_n(-$i,$i);
      my ($n_lo, $n_hi) = $path->rect_to_n_range(0,$i, -$i,$i);
      ok ($n_lo, $n_left);
    }
    {
      my $n_right = $path->xy_to_n($i,$i);
      my ($n_lo, $n_hi) = $path->rect_to_n_range($i,$i, 0,0);
      ok ($n_hi, $n_right);
    }
  }
}


#------------------------------------------------------------------------------
# random points

{
  my $path = Math::PlanePath::MathImageCellularRule246->new;
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

exit 0;
