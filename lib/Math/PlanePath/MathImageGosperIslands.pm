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


# math-image --path=MathImageGosperIslands --lines --scale=10
# math-image --path=MathImageGosperIslands --all --output=numbers

package Math::PlanePath::MathImageGosperIslands;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::PlanePath::KochCurve;
use Math::PlanePath::SacksSpiral;
use Math::PlanePath::MathImageGosperIslandSide;

use vars '$VERSION', '@ISA';
$VERSION = 59;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

# innermost origin 0,0 N=0 level 0
#     level 0    len=1
#     level 1    len=6
#     level 2    len=18
# each ring is 6*3^(level-1)
#              = 2*3^level
# side len = ring/6
#          = 2*3^level / 6
#          = 3^(level-1)
#
# Nstart(level) = 1 + 6*3^0 + 6*3^1 + ... + 6*3^(level-2)
#               = 1 + 6* [ (3^(level-1) - 1)/2 ]
#               = 1 + 3*(3^(level-1) - 1)
#               = 1 + 3*3^(level-1) - 3
#               = 1 + 3^level - 3
#               = 3^level - 2
#
# 3^level = N+2
# level = log3(N+2)

my @level_x = (0);
my @level_y = (0);

sub n_to_xy {
  my ($self, $n) = @_;
  ### GosperIslands n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n) || $n==0) {
    return ($n,$n);
  }

  my ($pow, $level) = Math::PlanePath::KochCurve::_round_down_pow3($n+2);
  my $side = $pow / 3;
  ### $level
  ### base: $pow - 2
  ### $side
  ### assert: $pow == 3 ** $level

  $n -= $pow-2;  # remainder
  my $sixth = int ($n / $side);
  my ($x, $y) = Math::PlanePath::MathImageGosperIslandSide->n_to_xy ($n % $side);

  if (! exists $level_x[$level]) {
    ($level_x[$level], $level_y[$level]) =
      Math::PlanePath::MathImageGosperIslandSide->n_to_xy ($side);
  }
  my $pos_x = $level_x[$level];
  my $pos_y = $level_y[$level];
  ### pos: "$pos_x,$pos_y"
  ### raw xy: "$x,$y"

  ($x,$y) = (($x+3*$y)/-2,             # rotate +120
             ($x-$y)/2);
  # ($x,$y) = (($x-3*$y)/2,   # rotate +60
  #            ($x+$y)/2);
  foreach (1 .. $sixth) {
    ($x,$y) = (($x-3*$y)/2,   # rotate +60
               ($x+$y)/2);
    ($pos_x,$pos_y) = (($pos_x-3*$pos_y)/2,   # rotate +60
                       ($pos_x+$pos_y)/2);
  }
  return ($pos_x + $x,
          $pos_y + $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  ### GosperIslands xy_to_n(): "$x, $y"
  return undef;
}

# Each
#           *---
#          /
#      ---*
# is width=5 heightflat=1 is
#     hypot^2 = 5*5 + 3 * 1*1
#             = 25+3
#             = 28
#     hypot = 2*sqrt(7)
#
# comes in closer to
#     level=2   x=2,y=2 is hypot=sqrt(2*2+3*2*2) = sqrt(16) = 4
#     level=3   x=2,y=6 is hypot=sqrt(2*2+3*6*6) = sqrt(112) = sqrt(7)*4
# so
#     radius = 4 * sqrt(7)^(level-2)
#     radius/4 = sqrt(7)^(level-2)
#     level-2 = log(radius/4) / log(sqrt(7))
#     level = log(radius/4) / log(sqrt(7)) + 2
#
# Nstart(level) - 1 = 3^level - 2 - 1
#                   = 3^level - 3
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  $y1 *= sqrt(3);
  $y2 *= sqrt(3);
  my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
    ($x1,$y1, $x2,$y2);
  my $level = ceil( log(max(1,$r_hi/4)) / log(sqrt(7)) ) + 2;
  return (0, 3**$level - 3);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImageGosperIslands -- concentric Gosper islands

=head1 SYNOPSIS

 use Math::PlanePath::MathImageGosperIslands;
 my $path = Math::PlanePath::MathImageGosperIslands->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path is integer versions of the Gosper island arranged as concentric
circles on a triangular lattice (see L<Math::PlanePath/Triangular Lattice>).
These rings are the outlines of a self-similar tiling of the plane by
hexagons.

                   35----34                
                  /        \
          37----36          33----32          29----28
         /                           \        /        \
       38                             31----30          27----26
         \                                                      \
          39                                                     25
         /                                                
     --40                                                    ...
    
                            11-----10                         3
                           /         \
                   13----12           9---- 8                 2
                  /                          \
                14           3---- 2           7              1
                  \        /        \    
                   15     4     0---- 1    24             <- Y=0
                  /        \                 \
                16           5----- 6         23             -1
                  \                          /
                   17----18          21----22                -2
                           \        /
                            19----20                         -3

       -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The side N=1 to N=2 expands to the zig-zag N=7 to N=10, then each section of
that expands similarly (and at those angles) to become N=25 to N=34.  The
N=25 ring is shown in part above is as follows.

              * *                 
           * *   * *   * *        
          *         * *   * *     
           *                 *    
        * *                 *     
     * *                     *    
    *                       *     
     *                       * *  
    *                           * 
     * *                       *  
        *                       * 
       *                     * *  
        *                 * *     
       *                 *        
        * *   * *         *       
           * *   * *   * *        
                    * *           

Each ring is the outline of seven of the previous level shape arranged one
in the centre and six around.  This N=25 shape is seven of the N=7 to N=24
shapes.  The sides become successively bumpier at each level but they fit
together exactly because the six sides are symmetric.

=head2 Level Ranges

Counting the inner hexagon as level=1, the ring for each level begins at

    Nstart(level) = 3^level - 2
    length        = 2*3^level

For example level=3 is at Nstart=3^3-2=25.

The shape is kept on integer coordinates of L<Math::PlanePath/Triangular
Lattice> by starting each ring at successively rotated positions.  The angle
of the N=7 start at X=5,Y=1 is

    angle = atan(sqrt(3) / 5) = 19.106.. degrees

The sqrt(3) is for the flattened triangular grid.  The subsequent starts at
N=25 etc are multiples of this angle.

=head2 Fractal Island

This construction is often made as a fractal, with each side of the initial
hexagon having more and more detail at each level.  The code here can be
used for that by rotating and scaling down to a fixed size starting at the X
axis.

Use Y*sqrt(3) on all points to make equilateral triangle grid.  A scale and
rotation can be obtained from the Nstart first point of each level.

    scale factor = 1 / hypot(Y*sqrt(3), X)
    rotate angle = - atan2 (Y*sqrt(3), X)

This puts the Nstart at X=1,Y=0, and further points at the ring around from
that.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageGosperIslands-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
