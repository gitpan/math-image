#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use Math::Matrix;
use List::Util 'min', 'max';
use Math::Libm 'hypot';

# uncomment this to run the ### lines
use Smart::Comments;

{
  require Math::PlanePath::MathImagePythagoreanUAD;
  my $path = Math::PlanePath::MathImagePythagoreanUAD->new;
  my $x_limit = 500;
  my @max_n;
  foreach my $n (0 .. 500000) {
    my ($x,$y) = $path->n_to_xy($n);
    if ($x <= $x_limit) {
      $max_n[$x] = max($max_n[$x] || $n, $n);
    }
  }
  foreach my $x (0 .. $x_limit) {
    if ($max_n[$x]) {
      print "$x   $max_n[$x]\n";
    }
  }
  exit 0;
}

{
  require Math::PlanePath::MathImagePythagoreanUAD;
  my $path = Math::PlanePath::MathImagePythagoreanUAD->new;
  foreach my $n (0 .. 100) {
    my ($x,$y) = $path->n_to_xy($n);
    my $z = hypot($x,$y);
    print "$x, $y, $z\n";
  }
  exit 0;
}

{
  my $u = Math::Matrix->new ([1,2,2],
                             [-2,-1,-2],
                             [2,2,3]);
  my $a = Math::Matrix->new ([1,2,2],
                             [2,1,2],
                             [2,2,3]);
  my $d = Math::Matrix->new ([-1,-2,-2],
                             [2,1,2],
                             [2,2,3]);
  my $ui = $u->invert;
  print $ui;
  exit 0;
}

{
  my (@x) = 3;
  my (@y) = 4;
  my (@z) = 5;

  for (1..3) {
    for my $i (0 .. $#x) {
      print "$x[$i], $y[$i], $z[$i]    ",sqrt($x[$i]**2+$y[$i]**2),"\n";
    }
    print "\n";

    my @new_x;
    my @new_y;
    my @new_z;
    for my $i (0 .. $#x) {
      my $x = $x[$i];
      my $y = $y[$i];
      my $z = $z[$i];
      push @new_x,   $x - 2*$y + 2*$z;
      push @new_y, 2*$x -   $y + 2*$z;
      push @new_z, 2*$x - 2*$y + 3*$z;

      push @new_x,   $x + 2*$y + 2*$z;
      push @new_y, 2*$x +   $y + 2*$z;
      push @new_z, 2*$x + 2*$y + 3*$z;

      push @new_x,  - $x + 2*$y + 2*$z;
      push @new_y, -2*$x +   $y + 2*$z;
      push @new_z, -2*$x + 2*$y + 3*$z;
    }
    @x = @new_x;
    @y = @new_y;
    @z = @new_z;
  }
  exit 0;
}
