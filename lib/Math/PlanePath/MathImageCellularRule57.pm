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

package Math::PlanePath::MathImageCellularRule57;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 88;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant y_negative => 0;

#            left
# even  y=3     5
#         5    12
#         7    23
#         9    38
# [1,2,3,4], [5,12,23,38]
#
# N = (2 d^2 + d + 2)
#   = (2*$d**2 + $d + 2)
#   = ((2*$d + 1)*$d + 2)
# d = -1/4 + sqrt(1/2 * $n + -15/16)
#   = (-1 + 4*sqrt(1/2 * $n + -15/16)) / 4
#   = (sqrt(8*$n-15)-1)/4
# with Y=2*d+1

# row 19, d=9
# N=173 to N=181 is 9 cells rem=0..8  is d-1
# 1/3 section 3 cells rem=0,1,2  floor((d-1)/3)
# 2/3 section 6 cells
# right solid N=191 to N=200 is 10 of is rem<d
#
# row 21, d=10
# 1/3 section 4 cells rem=0,1,2,3  floor((d-1)/3)
# 2/3 section 6 cells
#
# row 23, d=11
# 1/3 section 4 cells rem=0,1,2,3  floor((d-1)/3)
# 2/3 section 7 cells
#
# row 25, d=12
# 2/3 section 8 cells
#
# row 27, d=13
# 2/3 section 8 cells
#
# row 29, d=14
# 2/3 section 9 cells    floor(2d/3)
#
# row 31, d=15
# 2/3 section 10 cells   floor(2d/3)
#
#
# row 18 d=8
# odd 1/3 section   4 cells  (d+4)/3
#
# row 20 d=9
# odd 1/3 section   4 cells
#
# row 22 d=10
# odd 1/3 section   4 cells
#
# row 23 d=11
# odd 1/3 section   5 cells


sub n_to_xy {
  my ($self, $n) = @_;
  ### CellularRule57 n_to_xy(): $n

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
    if (2*$frac >= 1) {
      $frac -= 1;
      $n += 1;
    }
    # -0.5 <= $frac < 0.5
    ### assert: 2*$frac >= -1
    ### assert: 2*$frac < 1
  }

  if ($n <= 1) {
    if ($n == 1) {
      return (0,0);
    } else {
      return;
    }
  }

  # d is the two-row group number, y=2*d+1, where n belongs
  #
  my $d = int ((sqrt(8*$n-15)-1)/4);
  $n -= ((2*$d + 1)*$d + 2);   # remainder
  ### $d
  ### remainder: $n

  if ($n < $d) {
    ### left solid: $n
    return ($frac + $n - 2*$d - 1,
            2*$d+1);
  }
  $n -= $d;

  if ($n < int(($d+2)/3)) {
    ### left 1/3: $n
    return ($frac + 3*$n - $d + 1,
            2*$d+1);
  }
  $n -= int(($d+2)/3);

  if ($n < int(2*$d/3)) {
    ### right 2/3: $n
    return ($frac + $n + int(($n+(-$d%3))/2) + 1,
            2*$d+1);
  }
  $n -= int(2*$d/3);

  if ($n <= $d) {
    ### right solid: $n
    return ($frac + $d + $n + 1,
            2*$d+1);
  }
  $n -= $d+1;

  if ($n < int(($d+4)/3)) {
    ### odd 1/3: $n
    return ($frac + 3*$n - $d - 1,
            2*$d+2);
  }
  $n -= int(($d+4)/3);

  ### odd 2/3: $n
  return ($frac + $n + int(($n+((1-$d)%3))/2) + 1,
          2*$d+2);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### CellularRule57 xy_to_n(): "$x,$y"

    return undef;

  if ($y < 0
      || $x < -$y
      || $x > $y) {
  }
  $x += $y;
  ### x centred: $x
  if ($y % 2) {
    ### odd row, 3 in 4 ...
    if (($x % 4) == 3) {
      return undef;
    }
    return $x - int($x/4) + $y*($y+1)/2 + 1;
  } else {
    ## even row, sparse ...
    if ($x % 4) {
      return undef;
    }
    return $x/4 + $y*($y+2)/2  + 1;
  }
}

# left edge ((2*$d + 1)*$d + 2)
# where y=2*d+1
#       d=floor((y-1)/2)
# left N = (2*floor((y-1)/2) + 1)*floor((y-1)/2) + 2
#        = (yodd + 1)*yodd/2 + 2


# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### CellularRule57 rect_to_n_range(): "$x1,$y1, $x2,$y2"

  ($x1,$y1, $x2,$y2) = _rect_for_V ($x1,$y1, $x2,$y2)
    or return (1,0); # rect outside pyramid

  my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum

  $y1 -= ! ($y1 % 2);
  $y2 -= ! ($y2 % 2);
  return ($zero + ($y1 < 1
                   ? 1
                   : ($y1-1)*$y1/2 + 2),
          $zero + ($y2+2)*($y2+1)/2 + 1);
}


#------------------------------------------------------------------------------
# shared ...

# Return ($x1,$y1, $x2,$y2) which is the rectangle part chopped to the top
# row entirely within the pyramid V and the bottom row partly within.
#
sub _rect_for_V {
  my ($x1,$y1, $x2,$y2) = @_;
  ### _rect_for_V(): "$x1,$y1, $x2,$y2"

  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); } # swap to y1<=y2

  unless ($y2 >= 0) {
    ### rect all negative, no N ...
    return;
  }
  unless ($y1 >= 0) {
    # increase y1 to zero, including negative infinity discarded
    $y1 = 0;
  }

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); } # swap to x1<=x2
  my $neg_y2 = -$y2;

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
  if ($x1 > $y2            # off to the right
      || $x2 < $neg_y2) {  # off to the left
    ### rect all off to the left or right, no N
    return;
  }

  #     \        /  x2
  #      \   +------+ y2
  #       \  | /    |
  #        \ +------+
  #         \/
  #
  if ($x2 > $y2) {
    ### top-right beyond pyramid, reduce ...
    $x2 = $y2;
  }

  #
  #    x1  \        /
  # y2 +--------+  /  y2
  #    |     \  | /
  #    +--------+/
  #            \/
  #
  if ($x1 < $neg_y2) {
    ### top-left beyond pyramid, increase ...
    $x1 = $neg_y2;
  }

  #     \       | /
  #      \      |/
  #       \    /|       |
  #    y1  \  / +-------+
  #         \/  x1
  #
  #        \|       /
  #         \      /
  #         |\    /
  #  -------+ \  /   y1
  #        x2  \/
  #
  # in both of the following y1=x2 or y1=-x2 leaves y1<=y2 because have
  # already established some part of the rectangle is in the V shape
  #
  if ($x1 > $y1) {
    ### x1 off to the right, so y1 row is outside, increase y1 ...
    $y1 = $x1;

  } elsif ((my $neg_x2 = -$x2) > $y1) {
    ### x2 off to the left, so y1 row is outside, increase y1 ...
    $y1 = $neg_x2;
  }

  # values ordered
  ### assert: $x1 <= $x2
  ### assert: $y1 <= $y2

  # top row x1..x2 entirely within pyramid
  ### assert: $x1 >= -$y2
  ### assert: $x2 <= $y2

  # bottom row x1..x2 some part within pyramid
  ### assert: $x1 <= $y1
  ### assert: $x2 >= -$y1

  return ($x1,$y1, $x2,$y2);
}

1;
__END__

=for stopwords straight-ish PyramidRows Ryde Math-PlanePath ie hexagonals 18-gonal Xmax-Xmin Nleft Nright OEIS

=head1 NAME

Math::PlanePath::MathImageCellularRule57 -- cellular automaton points

=head1 SYNOPSIS

 use Math::PlanePath::MathImageCellularRule57;
 my $path = Math::PlanePath::MathImageCellularRule57->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the pattern of Stephen Wolfram's "rule 57" cellular automaton

    http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

arranged as rows

                51       52       53 54    55 56                 10
    38 39 40 41       42       43    44 45    46 47 48 49 50      9
                   33       34    35    36 37                     8
          23 24 25       26       27 28    29 30 31 32            7
                      19       20    21 22                        6
                12 13       14    15    16 17 18                  5
                          9       10 11                           4
                       5        6     7  8                        3
                             3     4                              2
                                   2                              1
                                1                             <- Y=0

    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9


On odd Y rows there's a solid block at either end and 1 of 3 cells to the
left and 2 of 3 to the right of the centre.  On even Y rows there's similar
1 of 3 and 2 of 3, without the solid ends.

=head2 Row Ranges

The left end of each row is

    ...

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageCellularRule57-E<gt>new ()>

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
L<Math::PlanePath::CellularRule190>,
L<Math::PlanePath::PyramidRows>

http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

=cut

# Local variables:
# compile-command: "math-image --path=MathImageCellularRule57 --all"
# End:
#
# math-image --path=MathImageCellularRule57 --all --output=numbers --size=132x50
#
