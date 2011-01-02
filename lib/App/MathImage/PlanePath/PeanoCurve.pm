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


# http://www.cut-the-knot.org/Curriculum/Geometry/PeanoComplete.shtml
#     Java applet, directions in 9 sub-parts
#

package App::MathImage::PlanePath::PeanoCurve;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 38;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### PeanoCurve n_to_xy(): $n
  return if $n < 0;

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $x = 0;
  my $y = 0;
  my $comp = 0;
  my $power = 1;
  for (;;) {
    ### $n
    ### $power
    {
      my $digit = $n % 3;
      if ($digit & 1) {
        $y = $comp - $y;
      }
      $x += $power * $digit;
    }
    $n = int($n/3) || last;
    $comp = (3*$comp + 2);
    {
      my $digit = $n % 3;
      if ($digit & 1) {
        $x = $comp - $x;
      }
      $y += $power * $digit;
    }
    $n = int($n/3) || last;
    $power *= 3;
  }
  return ($x, $y);


  # my (@n);
  # while ($n) {
  #   push @n, $n % 3; $n = int($n/3);
  #   push @n, $n % 3; $n = int($n/3);
  # }
  #
  # my $x = 0;
  # my $y = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@n) {
  #   {
  #     my $digit = pop @n;
  #     $xk ^= $digit;
  #     $y = 3*$y + ($yk & 1 ? 2-$digit : $digit);
  #   }
  #   {
  #     my $digit = pop @n;
  #     $yk ^= $digit;
  #     $x = 3*$x + ($xk & 1 ? 2-$digit : $digit);
  #   }
  # }
  #
  # ### is: "$x,$y"
  # return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### PeanoCurve xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }

  my $power = 1;
  my $comp = 0;
  my $xn = my $yn = ($x & 0); # inherit
  while ($x || $y) {
    {
      my $digit = $x % 3;
      if ($digit & 1) {
        $yn = $comp - $yn;
      }
      $xn += $power * $digit;
      $x = int($x/3);
    }
    $comp = (3*$comp + 2);
    {
      my $digit = $y % 3;
      if ($digit & 1) {
        $xn = $comp - $xn;
      }
      $yn += $power * $digit;
      $y = int($y/3);
    }
    $power *= 3;
  }

  my $n = ($x & 0); # inherit
  $power = 1;
  while ($xn || $yn) {
    $n += ($xn % 3) * $power;
    $power *= 3;
    $n += ($yn % 3) * $power;
    $power *= 3;
    $xn = int($xn/3);
    $yn = int($yn/3);
  }
  return $n;




  # my $pos = 0;
  # my @x;
  # my @y;
  # while ($x || $y) {
  #   push @x, $x % 3; $x = int($x/3);
  #   push @y, $y % 3; $y = int($y/3);
  # }
  # 
  # my $i = 0;
  # my $xk = 0;
  # my $yk = 0;
  # while (@x) {
  #   {
  #     my $digit = pop @y;
  #     $xk ^= $digit;
  #     if ($yk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 3) + $digit;
  #   }
  #   {
  #     my $digit = pop @x;
  #     $yk ^= $digit;
  #     if ($xk & 1) {
  #       $digit = 2 - $digit;
  #     }
  #     $n = ($n * 3) + $digit;
  #   }
  # }
  # 
  # return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  if ($x2 < 0 || $y2 < 0) {
    return (-1, 0);
  }

  my $ret = 9;
  while ($x2) {
    $ret *= 3;
    $x2 = int($x2 / 3);
  }
  while ($y2) {
    $ret *= 3;
    $y2 = int($y2 / 3);
  }
  return (0, $ret);
}

1;
__END__

=for stopwords Guiseppe Peano Peano's there'll HilbertCurve eg Sur une courbe qui remplit toute aire Mathematische Annalen Ryde OEIS trit-twiddling ZOrderCurve ie bignums

=head1 NAME

App::MathImage::PlanePath::PeanoCurve -- self-similar quadrant traversal

=head1 SYNOPSIS

 use App::MathImage::PlanePath::PeanoCurve;
 my $path = App::MathImage::PlanePath::PeanoCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the curve described by Guiseppe Peano for
a unit square.  The path traverses a quadrant of the plane one step at a
time in a self-similar 3x3 pattern,

      y=8   60--61--62--63--64--65  78--79--80--...
             |                   |   |
      y=7   59--58--57  68--67--66  77--76--75
                     |   |                   |
      y=6   54--55--56  69--70--71--72--73--74
             |
      y=5   53--52--51  38--37--36--35--34--33
                     |   |                   |
      y=4   48--49--50  39--40--41  30--31--32
             |                   |   |
      y=3   47--46--45--44--43--42  29--28--27
                                             |
      y=2    6---7---8---9--10--11  24--25--26
             |                   |   |
      y=1    5---4---3  14--13--12  23--22--21
                     |   |                   |
      y=0    0---1---2  15--16--17--18--19--20

           x=0   1   2   3   4   5   6   7   8   9 ...

The start is an S shape of points 0 to 8, and then nine of those are put
together in the same configuration, with sub-parts flipped horizontally
and/or vertically to make the starts and ends adjacent (8 next to 9, 17 next
to 18, etc),

    60,61,62 --- 63,64,65     78,79,80
    59,58,57     68,67,55     77,76,75
    54,55,56     69,70,71 --- 72,73,74
     |  
     |  
    53,52,51     38,37,36 --- 35,34,33
    48,49,50     39,40,41     30,31,32
    47,46,45 --- 44,43,42     29,28,27
                                     |
                                     |
     6,7,8  ----  9,10,11     24,25,26
     3,4,5       12,13,14     23,22,21
     0,1,2       15,16,17 --- 18,19,20

The process repeats, tripling each time.

Within a power-of-3 square 3x3, 9x9, 27x27, 81x81 etc (3^k)x(3^k), all the N
values 0 to 3^(2*k)-1 are within the square.  The top right corner 8, 80,
728, etc is the 3^(2*k)-1 maximum.

=head2 Unit Square

Peano's form is based on filling a unit square by mapping a number T in the
range 0E<lt>TE<lt>1 to a pair of X,Y coordinates 0E<lt>XE<lt>1 and
0E<lt>YE<lt>1.  The curve is continuous and every X,Y is reached so it fills
the unit square.  A unit cube can be filled by developing three coordinates
X,Y,Z similarly.  (Georg Cantor had shown a line is equivalent to a surface,
Peano's mapping is a continuous mapping doing that.)

The code here can be pressed into service for a fractional T to X,Y by
multiplying up by a power of 9 to desired precision then dividing X,Y back
by the same power of 3, perhaps transposing X,Y for which one you want to
have the first digit.  If T is floating point then a power of 3 division
will be rounded off since a division by 3 is not exactly representable in
binary, in general.  (See HilbertCurve or ZOrderCurve for binary based
paths.)

=head1 OEIS

This path is in Sloane's OEIS in several forms, eg.

    http://www.oeis.org/A163528

    A163528    X coordinate
    A163529    Y coordinate
    A163530    coordinate sum X+Y
    A163531    square of distance from origin (X^2+Y^2)
    A163532    X change -1,0,1
    A163533    Y change -1,0,1
    A163534    absolute direction of each step (up,down,left,right)
    A163535    absolute direction, transpose X,Y
    A163536    relative direction (ahead,left,right)
    A163537    relative direction, transpose X,Y
    A163342    diagonals summed
    A163343    central diagonal  0,4,8,44,40,36,etc
    A163344    central diagonal divided by 4
    A163480    row at X=0
    A163481    column at Y=0

And taking squares of the plane in diagonals sequence, each value the N of
the Peano curve at those positions.

    A163334    numbering by diagonals, from same axis as first step
    A163336    numbering by diagonals, from opposite axis
    A163338    one-based, ie. A163334 + 1

C<Math::PlanePath::Diagonals> numbers from the Y axis down, which is the
opposite axis to the Peano curve first step along the X axis, which means
Diagonals+PeanoCurve is the "opposite axis" A163336 sequence.

The sequences are in each case permutations of the integers since all X,Y
positions are reached eventually.  The inverses are as follows.  They can be
thought of taking X,Y positions in the Peano curve order and then asking
what N the diagonals would put there.

    A163335    inverse of A163334
    A163337    inverse of A163336
    A163339    inverse of A163338

=head2 FORMULAS

Peano's calculation is based on splitting the base-3 digits of N alternately
between X and Y.  Starting from the high end of N a digit is appended to X
then the next appended to Y, arranging for the last to go to X.  At each
stage a "complement" state is maintained for X and Y.  When complemented the
digit is reversed to S<2 - digit>, so 0,1,2 becomes 2,1,0.  The represents
the reverse for points like N=12,13,14 shown above.

The complement is calculated by adding up the N digits which went to the
other of X or Y.  So the X complement is the sum of digits which have been
appended to Y so far, and conversely Y complement is the sum of digits
applied to X.  If the sum is odd then the reversal is done.  The odd/even is
not changed by the reversal itself, so it doesn't matter if the digit is
taken before or after.  An XOR can be used instead of a sum, that too
maintaining the desired odd/even.

It also works to take the base-3 digits of N from low to high, applying
digits to the high end of X and Y successively.  When an odd digit, ie. a 1,
is put onto X then the digits of Y so far must be complemented as 22..22 -
Y, the 22..22 value being all 2s in base 3.  Conversely if a digit 1 is
added to Y then X must be complemented.  With this approach the high digits
of N don't have to be found, instead just peeled off the low end, but the
full subtract for the complement would be more work if using bignums.

The X,Y to N calculation can be done by an inverse of either method, putting
digits alternately from X and Y onto N, with complement as necessary.  For
the low to high approach complementing just the X digits in the constructed
N isn't easy.  The X and Y digits to go into N can be built up separately
then interleaved to make the final N.  The complementing is the equivalent
of an XOR in binary.  On a ternary machine some trit-twidding could no doubt
do it.

In the current code C<n_to_xy> and C<xy_to_n> both go low to high as that
seems a bit easier than finding the high ternary digits of the inputs.

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::PeanoCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square an C<$x,$y> within that square
returns N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::HilbertCurve>
L<Math::PlanePath::ZOrderCurve>

Guiseppe Peano, "Sur une courbe, qui remplit toute une aire plane",
Mathematische Annalen, volume 36, number 1, 1890, p157-160

    DOI 10.1007/BF01199438
    http://www.springerlink.com/content/w232301n53960133/

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2010, 2011 Kevin Ryde

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
