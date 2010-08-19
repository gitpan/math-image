#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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


use 5.004;
use strict;
use warnings;
use POSIX ();
use App::MathImage::PlanePath::MultipleRings;

{
  my $width = 79;
  my $height = 40;
  my $x_scale = 3;
  my $y_scale = 2;

  my $y_origin = int($height/2);
  my $x_origin = int($width/2);

  my $path = App::MathImage::PlanePath::MultipleRings->new;
  my @rows = (' ' x $width) x $height;

  foreach my $n (0 .. 60) {
    my ($x, $y) = $path->n_to_xy ($n) or next;
    $x *= $x_scale;
    $y *= $y_scale;

    $x += $x_origin;
    $y = $y_origin - $y;  # inverted

    $x -= length($n) / 2;
    $x = POSIX::floor ($x + 0.5); # round
    $y = POSIX::floor ($y + 0.5);

    if ($x >= 0 && $x < $width && $y >= 0 && $y < $height) {
      substr ($rows[$y], $x,length($n)) = $n;
    }

  }

  foreach my $row (@rows) {
    print $row,"\n";
  }
  exit 0;
}

{
  foreach my $i (0 .. 50) {
    my $theta = Math::PlanePath::ArchimedeanSpiral::_inverse($i);
    my $length = Math::PlanePath::ArchimedeanSpiral::_arc_length($theta);
    printf "%2d %8.3f %8.3f\n", $i, $theta, $length;
  }
  exit 0;
}
