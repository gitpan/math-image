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


# math-image --path=MathImageSierpinskiArrowhead --lines --scale=10
# math-image --path=MathImageSierpinskiArrowhead --output=numbers

package Math::PlanePath::MathImageSierpinskiArrowhead;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 59;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiArrowhead n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my ($x, $y);
  {
    my $whole = int($n);
    $y = $n - $whole;
    $x = - $y;
    $n = $whole;
  }
  my $len = 1;
  while ($n) {
    my $digit = ($n % 3);
    ### even left: "$x,$y  len=$len"
    ### $digit
    if ($digit == 0) {

    } elsif ($digit == 1) {
      $x = - $x - $len;  # mirror and offset
      $y += $len;

    } else {
      ($x,$y) = ((3*$y-$x)/2,              # rotate -120
                 ($x+$y)/-2  + 2*$len)
    }
    $len *= 2;

    $n = int($n/3) || last;
    $digit = ($n % 3);
    $n = int($n/3);

    ### odd right: "$x,$y  len=$len"
    ### $digit
    if ($digit == 0) {

    } elsif ($digit == 1) {
      $x = $len - $x;  # mirror and offset
      $y += $len;

    } else {
      ($x,$y) = (($x+3*$y)/-2,             # rotate +120
                 ($x-$y)/2    + 2*$len);
    }
    $len *= 2;
  }

  ### final: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  ### SierpinskiArrowhead xy_to_n(): "$x, $y"

  if ($x < 0
      || $y < 0
      || $y > $x
      || (($x^$y) & 1)
     ) {
    return undef;
  }

  my ($len, $level) = _round_up_pow2 ($x+$y + ($y==0 || $x==$y));
  ### pow2 round: ($x+$y + ($y==0 || $x==$y))
  ### $len
  ### $level

  my $n = 0;
  while ($level) {
    $n *= 3;
    ### at: "$x,$y  level=$level len=$len"
    ### assert: $x+$y < 2 * $len + ! ($y==0||$x==$y)

    if ($x < 0 || $y < 0 || $y > $x) {
      ### out of range
      return undef;
    }
    if ($x < $len && $y < $len-$x + !($y==0||$x==$y)) {
      ### digit 0, first triangle, no change
    } else {
      unless ($level & 1) {
        $y = -$y;  # mirror X
        ($x,$y) = (($x-3*$y)/2,   # rotate +60
                   ($x+$y)/2);
        ### odd flip to: "$x,$y"
      }
      if ($y < $len/2) {
        ### digit 1, right triangle
        $n += 1;
        $x -= $len;
        ### shift to: "$x,$y"
        $y = -$y;  # mirror X
        ($x,$y) = (($x-3*$y)/2,   # rotate +60
                   ($x+$y)/2);
        ### flip to: "$x,$y"
      } else {
        $n += 2;
        $x -= 3*$len/2;
        $y -= $len/2;
        ($x,$y) = ((3*$y-$x)/2,   # rotate -120
                   ($x+$y)/-2);
        ### digit 2, top triangle
        ### now: "$x,$y"
      }
    }

    $len /= 2;
    $level--;
  }

  if ($x == 0 && $y == 0) {
    return $n;
  } else {
    return undef;
  }
}

sub _round_up_pow2 {
  my ($x) = @_;
  my $exp = ceil (log(max(1, $x)) / log(2));
  my $pow = 2 ** $exp;
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }
  $x1 = floor($x1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y1 = floor($y1 + 0.5);
  $y2 = floor($y2 + 0.5);

  if ($y2 < 0 || $x2 < 0 || $y1 > $x2) {
    return (1,0);
  }
  $y2 = max($x2,$y2);
  my $d = ();

  my $level = _log2_ceil ($x2+$y2);
  return (0, 3 ** $level - 1);
}

sub _log2_ceil {
  my ($x) = @_;
  my $exp = ceil (log(max(1, $x)) / log(2));
  return $exp + (2 ** ($exp+1) <= $x);
}

1;
__END__

=for stopwords eg Ryde OEIS Sierpinski

=head1 NAME

Math::PlanePath::MathImageSierpinskiArrowhead -- self-similar path traversal

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSierpinskiArrowhead;
 my $path = Math::PlanePath::MathImageSierpinskiArrowhead->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is an integer version of the Sierpinski arrowhead path.  It follows a
self-similar triangular shape leaving middle triangle gaps.

                            27 ...                           8
                              \
                          .    26                            7
                              /
                      24----25     .                         6
                     /
                   23     .    20----19                      5
                     \        /        \
                 .    22----21    .     18                   4
                                       /
              4---- 5     .     .    17    .                 3
            /        \                 \
           3     .     6     .     .    16----15             2
            \         /                         \
        .     2     7     .    10----11     .    14          1
            /        \        /        \        /
     0---- 1     .     8---- 9     .    12----13    .    <- Y=0

    X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 ...


The starting figure is the N=0,1,2 part, then it's flipped and repeated as
N=3,4,5, then rotated and repeated as N=6,7,8.  Then that N=0 to N=8 shape
is repeated in the same way as the N=0,1,2, to make N=9 to N=17, and N=18 to
N=26.  The process repeats infinitely.

The X,Y coordinates are on a triangular lattice done in integers by using
every second X.

=head2 Sierpinski Triangle

At each level the arrowhead doubles in size, but only three of its four
sub-triangles are traversed.  This becomes clearer at bigger sizes.  For
example the following is N=0 to N=81.  Notice the middle inverted triangle
is not traversed.

                   * *
                  *   *
                   * *
                * *   * *
               *         *
                * *   * *
             * *   * *   * *
            *   * *   * *   *
             *             *
          * *               * *
         *   * *         * *   *
          * *   *       *   * *
       * *     *         *     * *
      *   *     * *   * *     *   *
       * *   * *   * *   * *   * *
    * *   * *   * *   * *   * *   * *

The path is related to the Sierpinski triangle of middle gaps by treating
each line segment as the side of a little triangle.

               N=3
              /  \
             /    \
            /  C   \
           /        \
          **--------N=2
         /  \       / \
        /    \     /   \
       /   A  \   /  B  \
      /        \ /       \
    N=0--------N=1-------**

The N=0 to N=1 segment has a triangle "A" above it, the N=1 to N=2 segment
triangle "B" to right, and N=2 to N=3 triangle "C" to the left.  Notice the
middle triangle is missed.  In general for N even the segment N to N+1 has
the triangle to the left and N odd has it to the right.

This pattern of little triangles is why the segment N=4 to N=5 looks like it
hasn't visited the vertex of the triangle with base N=0 to N=9, ie. the line
segment is standing in for a little triangle to the left of the segment,
which in this case is above it.  Similarly N=13 to N=14 and the middle of
each replication level.

=head2 Level Sizes

Treating the N=0,1,2 segment as level 1, each level goes from N=0 to
N=3^level, inclusive of its final triangular corner position.  For example
level 2 from N=0 to N=3^2=9.

Each level doubles in size, so height Y=2^level and width X=2*2^level.  The
extra factor of 2 horizontally is because every second integer X is used.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageSierpinskiArrowhead-E<gt>new ()>

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

Copyright 2010, 2011 Kevin Ryde

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
