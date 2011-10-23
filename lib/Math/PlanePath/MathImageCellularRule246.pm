# or better rule 190 3s from the left, or option to mirror - not symmetric





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


# math-image --path=MathImageCellularRule246 --all --scale=3
# math-image --path=MathImageCellularRule246 --all --output=numbers --size=132x50
#
# http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
#
# Loeschian numbers strips on the right ...
#

package Math::PlanePath::MathImageCellularRule246;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 78;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant y_negative => 0;

# 31    32 33 34   35 36 37    38 39 40
#    22 23 24   25 26 27    28 29 30
#       15   16 17 18    19 20 21
#          9 10 11    12 13 14
#             5     6  7  8
#                2  3  4
#                   1
#
# even  y = [ 0, 2, 4, 6 ]
#       N = [ 1, 5, 15, 31 ]
# Neven = (3/4 y^2 + 1/2 y + 1)
#       = (3y + 2)*y/4 + 1
#       = ((3y + 2)*y + 4) /4
#       = (3 (y/2)^2 + (y/2) + 1)
#       = (3*(y/2) + 1)*(y/2) + 1
#
# odd  y = [ 1, 3, 5,7 ]
#      N = [ 2,9,22,41 ]
# Nodd = (3/4 y^2 + 1/2 y + 3/4)
#      = ((3y+2)*y+ 3) / 4
#
# pair even d = [0,1,2,3]
#           N = [ 1, 5, 15, 31 ]
# Npair = (3 d^2 + d + 1)
# d = -1/6 + sqrt(1/3 * $n + -11/36)
#   = [ -1 + sqrt(1/3 * $n + -11/36)*6 ] / 6
#   = [ -1 + sqrt(1/3 * $n*36 + -11/36*36) ] / 6
#   = [ -1 + sqrt(12n-11) ] / 6
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageCellularRule246 n_to_xy(): $n

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
    if ($frac >= 0.5) {
      $frac -= 1;
      $n += 1;
    }
    # -0.5 <= $frac < 0.5
    ### assert: $frac >= -0.5
    ### assert: $frac < 0.5
  }

  if ($n < 1) {
    return;
  }

  # d is the two-row number, ie. d=2*y, where n belongs
  # start of the two-row group is nbase = 3 d^2 + d + 1
  #
  my $d = int ((sqrt(12*$n-11) - 1) / 6);
  $n -= ((3*$d + 1)*$d + 1);   # remainder within two-row
  ### $d
  ### remainder: $n
  if ($n <= 3*$d) {
    # 3d+1 many points in the Y=0,2,4,6 etc even row
    $d *= 2;    # y=2*d
    return ($frac + $n + int(($n+2)/3) - $d,
            $d);
  } else {
    # 3*d many points in the Y=1,3,5,7 etc odd row, using 3 in 4 cells
    $n -= 3*$d+1;    # remainder 0 upwards into odd row
    $d = 2*$d+1;   # y=2*d+1
    return ($frac + $n + int($n/3) - $d,
            $d);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### MathImageCellularRule246 xy_to_n(): "$x,$y"

  if ($y < 0 || $x > $y) {
    return undef;
  }

  $x += $y;  # move to have x=0 the start of the row
  if ($x < 0) {
    return undef;
  }

  ### x centred: $x
  if ($y % 2) {
    ### odd row, 3s from the start ...
    if (($x % 4) == 3) {
      return undef;
    }
    return $x-int($x/4) + ((3*$y+2)*$y+3)/4;
  } else {
    ## even row, 1 sep then 3s ...
    if (($x % 4) == 1) {
      return undef;
    }
    return $x-int(($x+2)/4) + ((3*$y+2)*$y+4)/4;
  }
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageCellularRule246 rect_to_n_range(): "$x1,$y1, $x2,$y2"

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2
  if ($y2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); } # swap to x1<=x2

  #     \        /
  #   y2 \      / +-----
  #       \    /  |
  #        \  /
  #         \/    x1
  #
  #        \        /
  #   ----+ \      /  y2
  #       |  \    /
  #           \  /
  #       x2   \/
  #
  my $nx2 = -$x2;
  if ($x1 > $y2
      || $nx2 > $y2) {  # x2 < -y2, done as -x2 > y2
    ### rect all off to the left or right, no N
    return (1, 0);
  }

  ### x1 to x2 top row intersects some of the pyramid
  ### assert: $x2 >= -$y2
  ### assert: $x1 <= $y2

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum

  #     \       | /
  #      \      |/
  #       \    /|       |
  #    y1  \  / +-------+
  #         \/  x1
  #
  if ($x1 > $y1) {
    ### x1 off to the right, y1 row is outside, increase y1
    $y1 = $x1;
  }

  #        \|       /
  #         \      /
  #         |\    /
  #  -------+ \  /   y1
  #        x2  \/
  if ($nx2 > $y1) {
    ### x2 off to the right, y1 row is outside, increase y1
    $y1 = $nx2;
  }
  ### new y1: "$y1"

  # even right  y = [ 0, 2, 4, 6 ]
  #             N = [ 1,8,21,40 ]
  # Nright = (3/4 y^2 + 2 y + 1)
  #        = (3 y^2 + 8 y + 4) / 4
  #        = ((3y + 8)y + 4) / 4
  #
  # odd right  y = [ 1, 3, 5, 7 ]
  #            N = [ 4,14,30, 52 ]
  # Nright = (3/4 y^2 + 2 y + 5/4)
  #        = (3 y^2 + 8 y + 5) / 4
  #        = ((3y + 8)y + 5) / 4
  #
  # Nleft y even ((3y+2)*y + 4)/4
  # Nleft y odd  ((3y+2)*y + 3)/4
  # Nright even ((3(y+1)+2)*(y+1) + 3)/4 - 1
  #          = ((3y+3+2)*(y+1) + 3 - 4)/4
  #          = ((3y+5)*(y+1) - 1)/4
  #          = ((3y^2 + 8y + 5 - 1)/4
  #          = ((3y^2 + 8y + 4)/4
  #          = ((3y+8)y + 4)/4
  #          = ((3y+2)(y+2)/4
  #
  $y2 += $zero;
  $y1 += $zero;
  return (((3*$y1 + 2)*$y1 + 4 - ($y1%2)) / 4,    # even/odd Nleft
          ((3*$y2 + 8)*$y2 + 4 + ($y2%2)) / 4);   # even/odd Nright
}

1;
__END__

=for stopwords straight-ish PyramidRows Ryde Math-PlanePath ie hexagonals 18-gonal Xmax-Xmin Nleft Nright

=head1 NAME

Math::PlanePath::MathImageCellularRule246 -- cellular automaton points

=head1 SYNOPSIS

 use Math::PlanePath::MathImageCellularRule246;
 my $path = Math::PlanePath::MathImageCellularRule246->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the pattern of Stephen Wolfram's "rule 246" cellular automaton
arranged as rows.

    66 67 68    69 70 71    72 73 74    75 76 77    78 79 80      9
       53    54 55 56    57 58 59    60 61 62    63 64 65         8
          41 42 43    44 45 46    47 48 49    50 51 52            7 
             31    32 33 34    35 36 37    38 39 40               6 
                22 23 24    25 26 27    28 29 30                  5 
                   15    16 17 18    19 20 21                     4 
                       9 10 11    12 13 14                        3 
                          5     6  7  8                           2 
                             2  3  4                              1 
                                1                             <- Y=0

    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9 

Each row is runs of 3 out of 4 cells, with even numbered rows having one
extra at the start.  Each two-row group has a step of 6 more points than the
previous two-row.

The rightmost N on the even rows Y=0,2,4,6 etc is the octagonal numbers
N=1,8,21,40,65, etc k*(3k-2).  The octagonal numbers of the "second kind"
5,16,33,56,85, etc j*(3j+2) are a straight-ish line upwards to the left.

=head2 Row Ranges

The left end of each row is

    Nleft = ((3Y+2)*Y + 4)/4     if Y even
            ((3Y+2)*Y + 3)/4     if Y odd

The right end is

    Nright = ((3Y+8)*Y + 4)/4    if Y even
             ((3Y+8)*Y + 5)/4    if Y odd

           = Nleft(Y+1) - 1   ie. 1 before next Nleft

The row width Xmax-Xmin = 2*Y but with the gaps the number of visited points
in a row is less than that,

    rowpoints = 3*Y/2 + 1        if Y even
                3*(Y+1)/2        if Y odd

For any Y of course the Nleft to Nright difference is the number of points
in the row too

    rowpoints = Nright - Nleft + 1

=cut

# even Nright - Nleft + 1
#      = ((3Y+8)Y + 4)/4 - ((3Y+2)*Y + 4)/4 + 1
#      = [ (3Y+8)Y + 4 - (3Y+2)*Y - 4 ]/4 + 1
#      = [ (3Y+8)Y - (3Y+2)*Y ] / 4 + 1
#      = (3Y+8-3Y-2)Y/4 + 1
#      = 6Y/4 + 1
#      = 3Y/2 + 1
# odd Nright - Nleft + 1
#     = ((3Y+8)Y + 5)/4 - ((3Y+2)*Y + 3)/4 + 1
#     = [ (3Y+8)Y + 5 - (3Y+2)*Y - 3 ]/4 + 1
#     = [ (3Y+8)Y - (3Y+2)*Y + 2 ]/4 + 1
#     = [ 6Y + 2 ]/4 + 1
#     = [ 6Y + 2 + 4]/4
#     = [ 6Y + 6]/4
#     = 3(Y+1)/2

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageCellularRule246-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are each
rounded to the nearest integer, which has the effect of treating each cell
as a square of side 1.  If C<$x,$y> is outside the pyramid or on a skipped
cell the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CellularRule54>,
L<Math::PlanePath::PyramidRows>

http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

=cut
