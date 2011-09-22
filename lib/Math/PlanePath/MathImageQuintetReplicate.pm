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


# math-image --path=MathImageQuintetReplicate --lines --scale=10
# math-image --path=MathImageQuintetReplicate --output=numbers

package Math::PlanePath::MathImageQuintetReplicate;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use vars '$VERSION', '@ISA';
$VERSION = 71;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

#     10        7
#         2  8  5  6
#      3  0  1  9
#         4

# my @digit_to_xbx = (0,1,0,-1,0);
# my @digit_to_xby = (0,0,-1,0,1);
# my @digit_to_y = (0,0,1,0,-1);
# my @digit_to_yby = (0,0,1,0,-1);
#     $x += $bx * $digit_to_xbx[$digit] + $by * $digit_to_xby[$digit];
#     $y += $bx * $digit_to_ybx[$digit] + $by * $digit_to_yby[$digit];

sub n_to_xy {
  my ($self, $n) = @_;
  ### QuintetReplicate n_to_xy(): $n
  if ($n < 0 || _is_infinite($n)) {
    return;
  }

  {
    my $int = int($n);
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $x = my $y = my $by = ($n & 0); # inherit bignum 0
  my $bx = $x+1; # inherit bignum 1
  do {
    my $digit = ($n % 5);
    ### $digit
    ### $bx
    ### $by

    if ($digit == 1) {
      $x += $bx;
      $y += $by;
    } elsif ($digit == 2) {
      $x -= $by;  # i*(bx+i*by) = rotate +90
      $y += $bx;
    } elsif ($digit == 3) {
      $x -= $bx;  # -1*(bx+i*by) = rotate 180
      $y -= $by;
    } elsif ($digit == 4) {
      $x += $by;  # -i*(bx+i*by) = rotate -90
      $y -= $bx;
    }

    # power (bx,by) = (bx + i*by)*(i+2)
    #
    ($bx,$by) = (2*$bx-$by, 2*$by+$bx);

  } while ($n = int($n/5));

  return ($x, $y);
}

# digit   modulus 2Y+X mod 5
#   2        2
# 3 0 1    1 0 4
#   4        3
#
my @modulus_to_x = (0,-1,0,0,1);
my @modulus_to_y = (0,0,1,-1,0);
my @modulus_to_digit = (0,3,2,4,1);

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### QuintetReplicate xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  my $n = ($x & 0 & $y);  # inherit bignum 0
  my $power = $n + 1;     # inherit bignum 1

  while ($x || $y) {
    ### at: "$x,$y n=$n power=$power"

    my $m = (2*$y - $x) % 5;
    ### $m
    ### digit: $modulus_to_digit[$m]
    ### powered: $modulus_to_digit[$m] * $power

    $n += $modulus_to_digit[$m] * $power;
    $power *= 5;

    $x -= $modulus_to_x[$m];
    $y -= $modulus_to_y[$m];
    ### shrink to: "$x,$y"

    # div i+2,
    # = (i*y + x) * (i-2)/-5
    # = (-y -2*y*i + x*i -2*x) / -5
    # = (y + 2*y*i - x*i + 2*x) / 5
    # = (2x+y + (2*y-x)i) / 5
    #
    ### assert: ((2*$x + $y) % 5) == 0
    ### assert: ((2*$y - $x) % 5) == 0
    #
    ($x,$y) = ((2*$x + $y) / 5,
               (2*$y - $x) / 5);
  }
  return $n;
}

# level 1   s=0            snext=5*s+2
#       3   s=2            base 5  22...
#       5   s=12
#       7   s=62
#       9   s=312
#
# level 2   s=1            snext=5*s+1
#       4   s=6            base 5  11...
#       6   s=31
#       8   s=156
#      10   s=781
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $level = 2 * ceil (log(max(36,
                                abs($x1),abs($x2),
                                abs($y1),abs($y2))) / log(6));
  return (0, 5 ** $level - 1);
}

1;
__END__

=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImageQuintetReplicate -- self-similar "+" tiling

=head1 SYNOPSIS

 use Math::PlanePath::MathImageQuintetReplicate;
 my $path = Math::PlanePath::MathImageQuintetReplicate->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is a self-similar tiling of the plane with "+" shapes.  It's the same
kind of tiling as the QuintetCurve (and QuintetCentres), but with the middle
square of the "+" centred on the origin.

            12                         3

        13  10  11       7             2

            14   2   8   5   6         1

        17   3   0   1   9         <- Y=0

    18  15  16   4  22                -1

        19      23  20  21            -2

                    24                -3

                 ^
    -4 -3 -2 -1 X=0  1  2  3  4

=head2 Complex Base

This tiling corresponds to expressing a complex integer X+i*Y in base b=i+2

    X+Yi = a[n]*b^n + ... + a[2]*b^2 + a[1]*b + a[0]

with each digit a[i] = 0, 1, i, -1, or -i.  Those digits are then
represented in integer N by 0,1,2,3,4.

The base b=i+2 is at an angle atan(1/2) = 26.56 degrees and successive
powers b^2, b^3, b^4 etc rotate around by that much each time.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageQuintetReplicate-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>,
L<Math::PlanePath::HilbertCurve>,
L<Math::PlanePath::PeanoCurve>,
L<Math::PlanePath::ZOrderCurve>

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
