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
BEGIN { plan tests => 538 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath::MathImageDragonRounded;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 66;
  ok ($Math::PlanePath::MathImageDragonRounded::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageDragonRounded->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageDragonRounded->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageDragonRounded->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::MathImageDragonRounded->new;
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
  my $path = Math::PlanePath::MathImageDragonRounded->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}


#------------------------------------------------------------------------------
# first few points

{
  my @data = (
              [ 1, 1,0 ],
              [ 2, 2,0 ],
              [ 3, 3,1 ],
              [ 4, 3,2 ],

              [ 5, 2,3 ],
              [ 6, 1,3 ],
              [ 7, 0,4 ],
              [ 8, 0,5 ],

              [ 9, -1,6 ],
              [ 10, -2,6 ],
              [ 11, -3,5 ],
              [ 12, -3,4 ],

              [ 1.25,  1.25, 0 ],
              [ 2.25,  2.25, 0.25 ],
              [ 3.25,  3, 1.25 ],
              [ 4.25,  2.75, 2.25 ],

              [ 5.25,  1.75, 3 ],
              [ 6.25,  0.75, 3.25 ],
              [ 7.25,  0, 4.25 ],
              [ 8.25,  -.25, 5.25 ],

              [ 9.25, -1.25, 6 ],
              [ 10.25, -2.25, 5.75 ],
              [ 11.25, -3, 4.75 ],
              [ 12.25, -3.25, 3.75 ],
             );
  my $path = Math::PlanePath::MathImageDragonRounded->new;
  foreach my $elem (@data) {
    my ($n, $x, $y) = @$elem;
    {
      # n_to_xy()
      my ($got_x, $got_y) = $path->n_to_xy ($n);
      if ($got_x == 0) { $got_x = 0 }  # avoid "-0"
      if ($got_y == 0) { $got_y = 0 }
      ok ($got_x, $x, "n_to_xy() x at n=$n");
      ok ($got_y, $y, "n_to_xy() y at n=$n");
    }
    if ($n==int($n)) {
      # xy_to_n()
      my $got_n = $path->xy_to_n ($x, $y);
      ok ($got_n, $n, "xy_to_n() n at x=$x,y=$y");
    }
    {
      $n = int($n);
      my ($got_nlo, $got_nhi) = $path->rect_to_n_range (0,0, $x,$y);
      ok ($got_nlo <= $n, 1, "rect_to_n_range() nlo=$got_nlo at n=$n,x=$x,y=$y");
      ok ($got_nhi >= $n, 1, "rect_to_n_range() nhi=$got_nhi at n=$n,x=$x,y=$y");
    }
  }
}


#------------------------------------------------------------------------------
# random fracs

{
  my $path = Math::PlanePath::MathImageDragonRounded->new;
  for (1 .. 20) {
    my $bits = int(rand(25));         # 0 to 25, inclusive
    my $n = int(rand(2**$bits)) + 1;  # 1 to 2^bits, inclusive

    my ($x1,$y1) = $path->n_to_xy ($n);
    my ($x2,$y2) = $path->n_to_xy ($n+1);

    foreach my $frac (0.25, 0.5, 0.75) {
      my $want_xf = $x1 + ($x2-$x1)*$frac;
      my $want_yf = $y1 + ($y2-$y1)*$frac;

      my $nf = $n + $frac;
      my ($got_xf,$got_yf) = $path->n_to_xy ($nf);

      ok ($got_xf, $want_xf, "n_to_xy($nf) frac $frac, x");
      ok ($got_yf, $want_yf, "n_to_xy($nf) frac $frac, y");
    }
  }
}

#------------------------------------------------------------------------------
# random points

{
  my $path = Math::PlanePath::MathImageDragonRounded->new;
  for (1 .. 100) {
    my $bits = int(rand(25));         # 0 to 25, inclusive
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
