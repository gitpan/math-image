#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Math::Libm 'hypot', 'M_PI';
use POSIX ();
use App::MathImage::PlanePath::ArchimedeanChords;

use lib "$ENV{HOME}/p/path/lib";

# uncomment this to run the ### lines
use Smart::Comments;


{
  require App::MathImage::PlanePath::ArchimedeanChords;
  require Math::PlanePath::TheodorusSpiral;
  require Math::PlanePath::VogelFloret;
  #my $path = Math::PlanePath::VogelFloret->new;
  my $path = App::MathImage::PlanePath::ArchimedeanChords->new;
  ### $path
  my $n = $path->xy_to_n (600, 0);
  ### $n
 $n = $path->xy_to_n (600, 0);
  ### $n
  exit 0;
}

{
  require Math::Symbolic;
  use Math::Symbolic::Derivative;
  my $tree = Math::Symbolic->parse_from_string(
                                               # '(t*cos(t)-c)^2'
                                               # '(t*sin(t)-s)'
                                               # '(t+1)^2'
                                               # '(t+u)^2 + t^2'
                                               '(t+u)*cos(u)'
                                              );
  # my $tree = Math::Symbolic->parse_from_string();
  print "$tree\n";
  my $derived = Math::Symbolic::Derivative::total_derivative($tree, 'u');
   $derived = $derived->simplify;
  print "$derived\n";

  exit 0;
}


# sub _chord_length {
#   my ($t1, $t2) = @_;
#   my $hyp = hypot(1,$theta);
#   return 0.5 * _A * ($theta*$hyp + asinh($theta));
# }

sub step {
  my ($x, $y) = @_;
  my $r = hypot($x,$y);
  my $len = 1/$r;
  my ($x2, $y2);
  foreach (1 .. 5) {
    ($x2,$y2) = ($x - $y*$len, $y + $x*$len);
    # atan($y2,$x2)
    my $f = hypot($x-$x2, $y-$y2);
    $len /= $f;
    ### maybe: "$x2,$y2 $f"
  }
  return ($x2, $y2);
}

sub next_t {
  my ($t1, $prev_dt) = @_;

  my $t = $t1;
  # my $c1 = $t1 * cos($t1);
  # my $s1 = $t1 * sin($t1);
  # my $c1_2 = $c1*2;
  # my $s1_2 = $s1*2;
  # my $t1sqm = $t1*$t1 - 4*M_PI()*M_PI();

  my $u = 2*M_PI()/$t;
  printf "estimate u=%.6f\n", $u;

  foreach (0 .. 10) {
    # my $slope = 2*($t + (-$c1-$s1*$t)*cos($t) + ($c1*$t-$s1)*sin($t));

    # my $f = ( ($t*cos($t) - $c1) ** 2
    #           + ($t*sin($t) - $s1) ** 2
    #           - 4*M_PI()*M_PI() );
    # my $slope = (2*($t*cos($t)-$c1)*(cos($t) - $t*sin($t))
    #          + 2*($t*sin($t)-$s1)*(sin($t) + $t*cos($t)));

    my $f = ($t+$u)**2 + $t**2 - 2*$t*($t+$u)*cos($u) - 4*M_PI()*M_PI();
    my $slope = 2 * ( $t*(1-cos($u)) + $u + $t*($t+$u)*sin($u) );
    my $sub = $f/$slope;
    $u -= $sub;

    # my $ct = cos($t);
    # my $st = sin($t);
    # my $f = (($t - $ct*$c1_2 - $st*$s1_2) * $t + $t1sqm);
    # my $slope = 2 * (($t*$ct - $c1) * ($ct - $t*$st)
    #                  + ($t*$st - $s1) * ($st + $t*$ct));
    # my $sub = $f/$slope;
    # $t -= $sub;

    last if ($sub < 1e-15);
    printf ("h=%.6f d=%.6f sub=%.20f u=%.6f\n", $slope, $f, $sub, $u);
  }

  return $t + $u;
}
{
  my $t = 2*M_PI;
  my $prev_dt = 1;
  my $prev_x = 1;
  my $prev_y = 0;

  foreach (1 .. 50) {
    my $nt = next_t($t,$prev_dt);
    my $prev_dt = $nt - $t;
    $t = $nt;
    my $r = $t * (1 / (2*M_PI()));
    my $x = $r*cos($t);
    my $y = $r*sin($t);
    my $d = hypot($x-$prev_x, $y-$prev_y);
    my $pdest = 2*M_PI()/$t;
    printf "%d t=%.6f  d=%.3g    pdt=%.3f/%.3f\n",
      $_, $t, $d-1, $prev_dt, $pdest;

    $prev_x = $x;
    $prev_y = $y;
  }
  exit 0;
}

{
  my $t1 = 1 * 2*M_PI;
  my $t = $t1;
  my $r1 = $t / (2*M_PI);
  my $c = cos($t);
  my $s = sin($t);
  my $c1 = $t1 * cos($t1);
  my $s1 = $t1 * sin($t1);
  my $c1_2 = $c1*2;
  my $s1_2 = $s1*2;
  my $t1sqm = $t1*$t1 - 4*M_PI()*M_PI();
  my $x1 = $r1*cos($t1);
  my $y1 = $r1*sin($t1);
  print "x1=$x1 y1=$y1\n";

  $t += 1;
  # {
  #   my $r2 = $t / (2*M_PI);
  #   my $dist = ($t1*cos($t1) - $t*cos($t) ** 2
  #            + ($t1*sin($t1) - $t*sin($t)) ** 2
  #            - 4*M_PI()*M_PI());
  #   my $slope = (2*($t*cos($t)-$c1)*(cos($t) - $t*sin($t))
  #                + 2*($t*sin($t)-$s1)*(sin($t) + $t*cos($t)));
  #   # my $slope = 2*($t + (-$c1-$s1*$t)*cos($t) + ($c1*$t-$s1)*sin($t));
  #   printf "d=%.6f slope=%.6f 1/slope=%.6f\n", $dist, $slope, 1/$slope;
  # }

  foreach (0 .. 10) {
    # my $slope = 2*($t + (-$c1-$s1*$t)*cos($t) + ($c1*$t-$s1)*sin($t));

    # my $dist = ( ($t*cos($t) - $c1) ** 2
    #           + ($t*sin($t) - $s1) ** 2
    #           - 4*M_PI()*M_PI() );
    # my $slope = (2*($t*cos($t)-$c1)*(cos($t) - $t*sin($t))
    #          + 2*($t*sin($t)-$s1)*(sin($t) + $t*cos($t)));

    my $ct = cos($t);
    my $st = sin($t);
    my $dist = (($t - $ct*$c1_2 - $st*$s1_2) * $t + $t1sqm);
    my $slope = 2 * (($t*$ct - $c1) * ($ct - $t*$st)
                     + ($t*$st - $s1) * ($st + $t*$ct));

    my $sub = $dist/$slope;
    $t -= $sub;
    printf ("h=%.6f d=%.6f sub=%.20f t=%.6f\n", $slope, $dist, $sub, $t);
  }

  my $r2 = $t / (2*M_PI);
  my $x2 = $r2 * cos($t);
  my $y2 = $r2 * sin($t);
  my $dist = hypot ($x1-$x2, $y1-$y2);

  printf ("d=%.6f dt=%.6f\n", $dist, $t - $t1);
  exit 0;
}


{
  my ($x, $y) = (1, 0);
  foreach (1 .. 3) {
    step ($x, $y);
    ### step to: "$x, $y"
  }
  exit 0;
}



{
  my $width = 79;
  my $height = 40;
  my $x_scale = 3;
  my $y_scale = 2;

  my $y_origin = int($height/2);
  my $x_origin = int($width/2);

  my $path = App::MathImage::PlanePath::ArchimedeanChords->new;
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
    my $theta = App::MathImage::PlanePath::ArchimedeanChords::_inverse($i);
    my $length = App::MathImage::PlanePath::ArchimedeanChords::_arc_length($theta);
    printf "%2d %8.3f %8.3f\n", $i, $theta, $length;
  }
  exit 0;
}
