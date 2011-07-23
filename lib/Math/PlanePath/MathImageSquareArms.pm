# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


# math-image --path=MathImageSquareArms --lines --scale=10
# math-image --path=MathImageSquareArms --all --output=numbers_dash
# math-image --path=MathImageSquareArms --values=Polygonal,polygonal=8

# 2
# 164  +162
# 542  +378  +216
# 1136 +594  +216
#

package Math::PlanePath::MathImageSquareArms;
use 5.004;
use strict;
use List::Util 'max';
use POSIX 'floor', 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 65;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Devel::Comments '###';

# [ 0, 1, 2, 3,],
# [ 0, 2, 6, 12 ],
# N = (d^2 + d)
# d = -1/2 + sqrt(1 * $n + 1/4)
#   = (-1 + 2*sqrt($n + 1/4)) / 2
#   = (-1 + sqrt(4*$n + 1)) / 2

sub n_to_xy {
  my ($self, $n) = @_;
  #### MathImageSquareArms n_to_xy: $n
  if ($n < 1) {
    return;
  }
  if ($n < 2) {
    ### centre
    return (0, 1-$n);  # from n=1 towards n=5 at x=0,y=-1
  }
  $n -= 2;
  my $frac;
  { my $int = int($n);
    $frac = $n - $int;
    $n = $int;
  }
  my $rot = $n % 4;
  $n = int($n/4);
  ### $n

  my $d = int ((-1 + sqrt(4*$n + 1)) / 2);
  ### d frac: ((-1 + sqrt(4*$n + 1)) / 2)
  ### $d
  ### base: $d*($d+1)

  $n -= $d*($d+1);
  ### remainder: $n

  $rot += ($d % 4);
  my $x = $d + 1;
  my $y = $n - $d + $frac;

  $rot %= 4;
  if ($rot & 2) {
    $x = -$x;  # rotate 180
    $y = -$y;
  }
  if ($rot & 1) {
    return (-$y,$x);  # rotate +90
  } else {
    return ($x,$y);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  ### MathImageSquareArms xy_to_n: "x=$x, y=$y"

  if ($x == 0 && $y == 0) {
    return 1;
  }

  my $rot = 0;
  # eg. y=2 have (0<=>$y)-$y == -1-2 == -3
  if ($y <= -$x) {
    ### below diagonal, rot 180 ...
    $rot = 2;
    $x = -$x;  # rotate 180
    $y = -$y;
  }
  if ($x <= $y) {
    ### left of diagonal, rot -90 ...
    $rot++;
    ($x,$y) = ($y,-$x);       # rotate -90
  }

  # diagonal down from N=2
  #     d=0   n=2
  #     d=4   n=82
  #     d=8   n=290
  #     d=12  n=626
  # N = (4 d^2 + 4 d + 2)
  #   = ((4*$d + 4)*$d + 2)
  # xoffset = $y + $x-1    upwards from diagonal
  # N + xoffset = 
  #             = 
  #             = 
  #
  my $d = $x-1;
  ### xy: "$x,$y"
  ### $rot
  ### x offset: $x-1 + $y
  ### quadratic: "d=$d  q=".((4*$d + 4)*$d + 2)
  ### d mod: $d % 4
  ### rot d mod: (($rot-$d) % 4)
  return ((4*$d + 4)*$d + 2) + 4*($y+$x-1) + (($rot-$d) % 4);
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  # d    = [ 1, 2,   3,  4,  5,   6,   7,   8,   9 ],
  # Nmax = [ 9, 25, 49, 81, 121, 169, 225, 289, 361 ]
  #   being the N=5 arm one spot before the corner of each run
  # N = (4 d^2 + 4 d + 1)
  #   = ((4*$d + 4)*$d + 1)
  #
  my ($d_lo, $d_hi) = _rect_square_range ($x1,$y1, $x2,$y2);
  return (1,
          ((4*$d_hi + 4)*$d_hi + 1));
}

sub _rect_square_range {
  my ($x1,$y1, $x2,$y2) = @_;
  ### _rect_square_range(): "$x1,$y1  $x2,$y2"

  # if x1,x2 opposite signs then origin x=0 covered, similarly y
  my $x_origin_covered = ($x1<0) != ($x2<0);
  my $y_origin_covered = ($y1<0) != ($y2<0);

  foreach ($x1,$y1, $x2,$y2) {
    $_ = abs(floor($_+0.5));
  }
  ### abs rect: "x=$x1 to $x2,  y=$y1 to $y2"

  if ($x2 < $x1) { ($x1,$x2) = ($x2,$x1) } # swap to x1<x2
  if ($y2 < $y1) { ($y1,$y2) = ($y2,$y1) } # swap to y1<y2

  return (max (0, # if both $x_origin_covered and $y_origin_covered
               $x_origin_covered ? () : ($x1),
               $y_origin_covered ? () : ($y1)),
          max ($x2, $y2));
}

1;
__END__

=for stopwords MathImageSquareArms Math-PlanePath Ryde

=head1 NAME

Math::PlanePath::MathImageSquareArms -- four spiral arms

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSquareArms;
 my $path = Math::PlanePath::MathImageSquareArms->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

B<In progress ...>

This path follows four spiral arms, each advancing successively,

                                 --33--29
                                        |
                   26--22--18--14--10  25
                    |               |   |
                   30  11-- 7-- 3   6  21
                    |   |           |   |
                       15   4   1   2  17
                        |   |   |       |   |
                       19   8   5-- 9--13  32
                        |   |               |
                       23  12--16--20--24--28
                        |
                       27--31--

     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The X,Y points are integers using every second position to give a triangular
lattice, per L<Math::PlanePath/Triangular Lattice>.

Each arm is N=6*k+rem for a remainder rem=0,1,2,3,4,5, so sequences related
to multiples of 6 or with a modulo 6 pattern may fall on particular arms.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageSquareArms-E<gt>new ()>

Create and return a new square spiral object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  For C<$n
E<lt> 1> the return is an empty list, as the path starts at 1.

Fractional C<$n> gives a point on the line between C<$n> and C<$n+4>, that
C<$n+4> being the next on the same spiralling arm.  This is probably of
limited use, but arises fairly naturally from the calculation.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::MathImageSquareSpiral>

=cut
