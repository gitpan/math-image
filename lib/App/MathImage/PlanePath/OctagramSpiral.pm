# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


package App::MathImage::PlanePath::OctagramSpiral;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use POSIX 'floor', 'ceil';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 41;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments '###';

# http://d4maths.lowtech.org/mirage/ulam.htm
# http://d4maths.lowtech.org/mirage/img/ulam.gif
#     sample gif of primes made by APL or something
#
# http://www.sciencenews.org/view/generic/id/2696/title/Prime_Spirals
#     Ulam's sprial of primes
#
# http://yoyo.cc.monash.edu.au/%7Ebunyip/primes/primeSpiral.htm
# http://yoyo.cc.monash.edu.au/%7Ebunyip/primes/triangleUlam.htm
#     Pulchritudinous Primes of Ulam sprial.

# wider==0
# base from bottom-right corner
#   d = [ 1,  2,  3,  4 ]
#   N = [ 2, 10, 26, 50 ]
#   N = (4 d^2 - 4 d + 2)
#   d = 1/2 + sqrt(1/4 * $n + -4/16)
#
# wider==1
# base from bottom-right corner
#   d = [ 1,  2,  3,  4 ]
#   N = [ 3, 13, 31, 57 ]
#   N = (4 d^2 - 2 d + 1)
#   d = 1/4 + sqrt(1/4 * $n + -3/16)
#
# wider==2
# base from bottom-right corner
#   d = [ 1,  2,  3, 4 ]
#   N = [ 4, 16, 36, 64 ]
#   N = (4 d^2)
#   d = 0 + sqrt(1/4 * $n + 0)
#
# wider==3
# base from bottom-right corner
#   d = [ 1,  2,  3 ]
#   N = [ 5, 19, 41 ]
#   N = (4 d^2 + 2 d - 1)
#   d = -1/4 + sqrt(1/4 * $n + 5/16)
#
# N = 4*d^2 + (-4+2*w)*d + (2-w)
#   = 4*$d*$d + (-4+2*$w)*$d + (2-$w)
# d = 1/2-w/4 + sqrt(1/4*$n + b^2-4ac)
# (b^2-4ac)/(2a)^2 = [ (2w-4)^2 - 4*4*(2-w) ] / 64
#                  = [ 4w^2 - 16w + 16 - 32 + 16w ] / 64
#                  = [ 4w^2 - 16 ] / 64
#                  = [ w^2 - 4 ] / 16
# d = 1/2-w/4 + sqrt(1/4*$n + (w^2 - 4) / 16)
#   = 1/4 * (2-w + sqrt(4*$n + w^2 - 4))
#   = 0.25 * (2-$w + sqrt(4*$n + $w*$w - 4))
#
# then offset the base by +4*$d+$w-1 for top left corner for +/- remainder
# rem = $n - (4*$d*$d + (-4+2*$w)*$d + (2-$w) + 4*$d + $w - 1)
#     = $n - (4*$d*$d + (-4+2*$w)*$d + 2 - $w + 4*$d + $w - 1)
#     = $n - (4*$d*$d + (-4+2*$w)*$d + 1 - $w + 4*$d + $w)
#     = $n - (4*$d*$d + (-4+2*$w)*$d + 1 + 4*$d)
#     = $n - (4*$d*$d + (2*$w)*$d + 1)
#     = $n - ((4*$d + 2*$w)*$d + 1)
#

sub n_to_xy {
  my ($self, $n) = @_;
  #### OctagramSpiral n_to_xy: $n
  if ($n <= 2) {
    if ($n < 1) {
      return;
    } else {
      return ($n-1, 0);
    }
  }

  my $d = int (sqrt(.125 * $n + 0.06640625) + 0.4375);
  #### d frac: (sqrt(.125 * $n + 0.06640625) + 0.4375)
  #### $d

  #### base: ((8*$d - 7)*$d + 1)
  $n -= ((8*$d - 7)*$d + 1);
  #### remainder: $n

  if ($n < $d) {
    return ($d + $n, $n);
  }
  $n -= 2*$d;
  if ($n < $d) {
    return ($d - min(0,$n), $d + max(0,$n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$n, $d+abs($n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d - max(0,$n), $d - min(0,$n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d-abs($n), -$n);
  }
  $n -= 2*$d;

  if ($n < $d) {
    return (-$d + min(0,$n), -$d - max(0,$n));
  }
  $n -= 2*$d;

  if ($n < $d) {
    return ($n, -$d - abs($n));
  }
  $n -= 2*$d;

  if ($n < $d+1) {
    return ($d + max(0,$n), -$d + min(0,$n));
  }

  # $n >= $d+1 through to 2*$d+1
  return (3*$d+2 - $n, -2*$d-1 + $n);
}

         #         29             25
         #          |  \         /  |
         #         30  28      26  24      ...-56--55       
         #          |     \   /     |            /
         # 33--32--31   7  27   5  23--22--21  54          2
         #   \          | \   / |         /  /
         #     34   9-- 8   6   4-- 3  20  53              1
         #       \   \            /   /  /
         #         35  10   1---2  19  52             <- y=0
         #       /   /                \   \  
         #     36  11--12  14  16--17--18  51             -1
         #   /          | /   \ |            \
         # 37--38--39  13  43  15  47--48--49--50         -2
         #          |    /   \      |
         #         40  42      44  46
         #          | /          \  |
         #         41              45
         # 
         #                  ^
         #     -3  -2  -1  x=0  1   2   3

sub xy_to_n {
  my ($self, $x, $y) = @_;
  return undef;

  # $x = floor ($x + 0.5);
  # $y = floor ($y + 0.5);
  # ### xy_to_n: "x=$x, y=$y"
  # 
  # my $d;
  # if (($d = $x) > abs($y)) {
  #   ### right vertical
  #   ### $d
  #   #
  #   # base bottom right per above
  #   ### BR: 4*$d*$d + (-4+2*$w)*$d + (2-$w)
  #   # then +$d-1 for the y=0 point
  #   # N_Y0  = 4*$d*$d + (-4+2*$w)*$d + (2-$w) + $d-1
  #   #       = 4*$d*$d + (-3+2*$w)*$d + (2-$w) + -1
  #   #       = 4*$d*$d + (-3+2*$w)*$d +  1-$w
  #   ### N_Y0: (4*$d + -3 + 2*$w)*$d + 1-$w
  #   #
  #   return (4*$d + -3)*$d + 1 + $y;
  # }
  # 
  # if (($d = -$x) > abs($y)) {
  #   ### left vertical
  #   ### $d
  #   #
  #   # top left per above
  #   ### TL: 4*$d*$d + (2*$w)*$d + 1
  #   # then +$d for the y=0 point
  #   # N_Y0  = 4*$d*$d + (2*$w)*$d + 1 + $d
  #   #       = 4*$d*$d + (1 + 2*$w)*$d + 1
  #   ### N_Y0: (4*$d + 1 + 2*$w)*$d + 1
  #   #
  #   return (4*$d + 1)*$d + 1 - $y;
  # }
  # 
  # $d = abs($y);
  # if ($y > 0) {
  #   ### top horizontal
  #   ### $d
  #   #
  #   # top left per above
  #   ### TL: 4*$d*$d + (2*$w)*$d + 1
  #   # then -($d) for the x=0 point
  #   # N_X0  = 4*$d*$d + (2*$w)*$d + 1 + -($d)
  #   #       = 4*$d*$d + (-1 + 2*$w)*$d + 1
  #   ### N_Y0: (4*$d - 1 + 2*$w)*$d + 1
  #   #
  #   return (4*$d - 1)*$d + 1 - $x;
  # }
  # 
  # ### bottom horizontal, and centre y=0
  # ### $d
  # #
  # # top left per above
  # ### TL: 4*$d*$d + (2*$w)*$d + 1
  # # then +2*$d to bottom left, +$d for the x=0 point
  # # N_X0  = 4*$d*$d + (2*$w)*$d + 1 + 2*$d + $d)
  # #       = 4*$d*$d + (3 + 2*$w)*$d + 1
  # ### N_Y0: (4*$d + 3 + 2*$w)*$d + 1
  # #
  # return (4*$d + 3)*$d + 1 + $x;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  my $d = 1 + max (1,
                   floor(0.5 + max(abs($y1),abs($y2))),
                   (map {$_ = floor(0.5 + $_);
                         max ($_,
                              -$_)}
                    ($x1, $x2)));
  ### $s
  ### is: $s*$s

  # ENHANCE-ME: find actual minimum if rect doesn't cover 0,0
  return (1,
          (4*$d + -4)*$d + 2);  # bottom-right
}

1;
__END__

=for stopwords Ulam OctagramSpiral pronic PlanePath Ryde Math-PlanePath Ulam's VogelFloret PyramidSides PyramidRows PyramidSpiral Honaker's decagonal octagram

=head1 NAME

App::MathImage::PlanePath::OctagramSpiral -- integer points drawn around a square (or rectangle)

=head1 SYNOPSIS

 use App::MathImage::PlanePath::OctagramSpiral;
 my $path = App::MathImage::PlanePath::OctagramSpiral->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a spiral around an octagram (8-pointed star),

            29             25                       4
             |  \         /  |
            30  28      26  24      ...-56--55      3       
             |     \   /     |            /
    33--32--31   7  27   5  23--22--21  54          2
      \          | \   / |         /  /
        34   9-- 8   6   4-- 3  20  53              1
          \   \            /   /  /
            35  10   1---2  19  52             <- y=0
          /   /                \   \  
        36  11--12  14  16--17--18  51             -1
      /          | /   \ |            \
    37--38--39  13  43  15  47--48--49--50         -2
             |    /   \      |
            40  42      44  46                     -3
             | /          \  |
            41              45                     -4

                     ^
    -4  -3  -2  -1  x=0  1   2   3   4   5  ...

This path is well known from Stanislaw Ulam finding interesting straight
lines plotting the prime numbers on it.  See F<examples/ulam-spiral-xpm.pl>
in the sources for a program generating that, or see L<math-image> using
this OctagramSpiral to draw Ulam's pattern and more.

=head2 Straight Lines

The perfect squares 1,4,9,16,25 fall on diagonals with the even perfect
squares going to the upper left and the odd ones to the lower right.  The
pronic numbers 2,6,12,20,30,42 etc k^2+k half way between the squares fall
on similar diagonals to the upper right and lower left.  The decagonal
numbers 10,27,52,85 etc 4*k^2-3*k go horizontally to the right at y=-1.

In general straight lines and diagonals are 4*k^2 + b*k + c.  b=0 is the
even perfect squares up to the left, then b is an eighth turn
counter-clockwise, or clockwise if negative.  So b=1 is horizontally to the
left, b=2 diagonally down to the left, b=3 down vertically, etc.

Honaker's prime-generating polynomial 4*k^2 + 4*k + 59 goes down to the
right, after the first 30 or so values loop around a bit.

=head2 Wider

An optional C<wider> parameter makes the path wider, becoming a rectangle
spiral instead of a square.  For example

    $path = App::MathImage::PlanePath::OctagramSpiral->new (wider => 3);

gives

    29--28--27--26--25--24--23--22        2
     |                           |
    30  11--10-- 9-- 8-- 7-- 6  21        1
     |   |                   |   |
    31  12   1-- 2-- 3-- 4-- 5  20   <- y=0
     |   |                       |
    32  13--14--15--16--17--18--19       -1
     |
    33--34--35--36-...                   -2

                     ^
    -4  -3  -2  -1  x=0  1   2   3

The centre horizontal 1 to 2 is extended by C<wider> many further places,
then the path loops around that shape.  The starting point 1 is shifted to
the left by wider/2 places (rounded up to an integer) to keep the spiral
centred on the origin x=0,y=0.

Widening doesn't change the nature of the straight lines which arise, it
just rotates them around.  For example in this wider=3 example the perfect
squares are still on diagonals, but the even squares go towards the bottom
left (instead of top left when wider=0) and the odd squares to the top right
(instead of the bottom right).

Each loop is still 8 longer than the previous, as the widening is basically
a constant amount added into each loop.

=head2 Corners

Other spirals can be formed by cutting the corners of the square so as to go
around faster.  See the following modules,

    Corners Cut    Class
    -----------    -----
         1        HeptSpiralSkewed
         2        HexSpiralSkewed
         3        PentSpiralSkewed
         4        DiamondSpiral

The PyramidSpiral is a re-shaped OctagramSpiral looping at the same rate.

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::OctagramSpiral-E<gt>new ()>

=item C<$path = App::MathImage::PlanePath::OctagramSpiral-E<gt>new (wider =E<gt> $w)>

Create and return a new square spiral object.  An optional C<wider>
parameter widens the spiral path, it defaults to 0 which is no widening.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the x,y coordinates of point number C<$n> on the path.

For C<$n < 1> the return is an empty list, it being considered the path
starts at 1.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are
each rounded to the nearest integer, which has the effect of treating each N
in the path as centred in a square of side 1, so the entire plane is
covered.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PyramidSpiral>

L<Math::PlanePath::DiamondSpiral>,
L<Math::PlanePath::PentSpiralSkewed>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::HeptSpiralSkewed>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-planepath/index.html

=head1 LICENSE

Math-PlanePath is Copyright 2010, 2011 Kevin Ryde

Math-PlanePath is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-PlanePath is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

=cut
