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


# math-image --path=MathImageTwinDragon --lines --scale=10
# math-image --path=MathImageTwinDragon --all --output=numbers_dash --size=80x50

package Math::PlanePath::MathImageTwinDragon;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 68;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageTwinDragon n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # is this sort of midpoint worthwhile? not documented yet
  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $x = 0;
  my $y = 0;
  my $dx = 1;
  my $dy = 0;

  while ($n) {
    ### at: "$x,$y"
    ### digit: ($n % 2)
    if ($n % 2) {
      $x += $dx;
      $y += $dy;
    }
    $n = int($n/2);

    # *(-1+i)
    $dy = -$dy;
    ($dx,$dy) = ($dy-$dx, $dx+$dy);
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageTwinDragon xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  my $n = 0;
  my $power = 1;
  while ($x || $y) {
    if (($x + $y) % 2) {
      $x -= 1;
      $n += $power;
    }
    # div i-1, is *-(1+i)/2

    ($x,$y) = (($x-$y)/-2, ($x+$y)/-2);
    $power *= 2;
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageTwinDragon rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = abs($x1);
  $y1 = abs($y1);
  $x2 = abs($x2);
  $y2 = abs($y2);
  my $xm = ($x1 > $x2 ? $x1 : $x2);
  my $ym = ($y1 > $y2 ? $y1 : $y2);
  my $r = $xm*$xm + $ym*$ym;
  my $level = ceil(log($r || 1) / log(2 - .1)) + 6;
  ### $level
  return (0, 2**$level - 1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageTwinDragon -- points in complex number base i-1

=head1 SYNOPSIS

 use Math::PlanePath::MathImageTwinDragon;
 my $path = Math::PlanePath::MathImageTwinDragon->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This an integer version of the "twindragon" formed from the complex number
base i-1,

           26  27          10  11                             3
               24  25           8   9                         2
   18  19  30  31   2   3  14  15                             1
       16  17  28  29   0   1  12  13                     <- Y=0
   22  23           6   7  58  59          42  43            -1
       20  21           4   5  56  57          40  41        -2
                   50  51  62  63  34  35  46  47            -3
                       48  49  60  61  32  33  44  45        -4
                   54  55          38  39                    -5
                       52  53          36  37                -6

                        ^
    -5  -4  -3  -2 -1  X=0  1   2   3   4   5   6   7

With base b=i-1, a complex integer can be represented by

    X+Yi = a[n]*b^n + ... + a2*b^2 + a1*b + a0

where the digits a[n] to a0 are each either 0 or 1.  The index N is those a[i]
in binary and the X,Y is the resulting complex number.  It can be shown that
this is a one-to-one transformation, that every integer point of the plane
is visited, just once.

The pattern of a given 0 to 2^level-1 is repeated in the following 2^level
to (2*2^level)-1.  For example the shape of N=0 to N=7 is repeated as N=8 to
N=15, but starting up at X=2,Y=2.  This is due to the base b^3 = 2+2i.
There's no rotations or mirroring etc in this replication, just a simple
shift.

Each each N=2^level point is at b^level, and that powering of the base
rotates around by +135 degrees and a factor sqrt(2) on the radius each time.
So for example b^3 = 2+2i is followed by b^4 = -4 which is 135 degrees
around, and the radius |b^3|=sqrt(8) becomes |b^4|=sqrt(16).

=head2 Radius Range

In general, after the first few innermost levels, each N=2^level increases
the covered radius around by a factor sqrt(2), ie.

    N = 0 to 2^level-1
    Xmin,Ymin closest to origin
    Xmin^2+Ymin^2 approx 2^(level-7)

The "level-7" is since the innermost few levels take a while to cover the
points surrounding the origin.  Notice for example X=1,Y=-1 is not reached
until N=58.  But after that it grows like N ~ pi*R^2.

=head2 Fractal

The twindragon is generally conceived as taking fractional N like binary
0.abcde and giving complex components X,Y components.  The twindragon is
then all the points of the real plane reached by such N -- which can be
shown to be connected and having a certain radius around the origin which is
completely covered.

The code here might be pressed into use for that, for some finite number of
N digits, by taking a suitable power N*256^k to get an integer then X/16^k,
Y/16^k for fractions X,Y.  256 is a good base because b^8=16 so there's no
rotations to apply to the X,Y, just a division.  (b^4=-4 for multiplier 16^k
and divisor (-4)^k would be almost as easy too.)

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageTwinDragon-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

C<$n> should be an integer, it's unspecified yet what will be done for a
fraction.

=back

=head1 FORMULAS

=head2 X,Y to N

A given X,Y representing X+Yi can be broken into digits of N by complex
division by i-1, with remainder 0 or 1 being each digit.

The remainder can be determined simply from (X+Y) mod 2.  If it's 1 then
X-1,Y gives a point which is an exact multiple of i-1 and that base can be
divided out

    X   <-   -(X-Y)/2
    Y   <-   -(X+Y)/2

This can also be thought of as a rotate by -135 degrees and divide by
sqrt(2).

The binary bits of N from low to high are generated this way.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>

=cut
