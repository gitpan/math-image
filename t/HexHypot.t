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
BEGIN { plan tests => 11 }

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Smart::Comments;

require Math::PlanePath::MathImageHexHypot;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 58;
  ok ($Math::PlanePath::MathImageHexHypot::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::MathImageHexHypot->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::MathImageHexHypot->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::MathImageHexHypot->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::MathImageHexHypot->new;
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
  my $path = Math::PlanePath::MathImageHexHypot->new;
  ok ($path->n_start, 1, 'n_start()');
  ok (!! $path->x_negative, 1, 'x_negative()');
  ok (!! $path->y_negative, 1, 'y_negative()');
}

#------------------------------------------------------------------------------
# monotonic hypotenuse

# (sqrt(3)/2 * y)^2 + (x/2)^2
#     = 3/4 * y^2 + 1/4 * x^2
#     = 1/4 * (3*y^2 + x^2)
sub hex_hypot {
  my ($x, $y) = @_;
  return 3*$y*$y + $x*$x;
}

{
  my $path = Math::PlanePath::MathImageHexHypot->new;
  my $bad = 0;
  my $n = $path->n_start;
  my ($x,$y) = $path->n_to_xy($n);
  my $h = hex_hypot($x,$y);
  while (++$n < 5000) {
    my ($x2,$y2) = $path->n_to_xy ($n);
    if (($x2 ^ $y2) & 1) {
      MyTestHelpers::diag ("n=$n x=$x2,y=$y2 same parity");
      last if $bad++ > 10;
    }
    my $h2 = hex_hypot($x2,$y2);
    ### xy: "$x2,$y2  is $h2"
    if ($h2 < $h) {
      MyTestHelpers::diag ("n=$n x=$x2,y=$y2 h=$h2 < prev h=$h x=$x,y=$y");
      last if $bad++ > 10;
    }
    $h = $h2;
    $x = $x2;
    $y = $y2;
  }
  ok ($bad, 0, "n_to_xy() hypot non-decreasing");
}

exit 0;
