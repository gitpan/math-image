# Copyright 2010 Kevin Ryde

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


package App::MathImage::PlanePath::Staircase;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use POSIX 'floor';

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 38;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

# start from 0.5 back
# d = [ 0, 1,  2, 3 ]
# n = [ 1.5, 6.5, 15.5 ]
# n = ((2*$d - 1)*$d + 0.5)
# d = 1/4 + sqrt(1/2 * $n + -3/16)
#
sub n_to_xy {
  my ($self, $n) = @_;
  #### Staircase n_to_xy: $n
  if ($n < .5) { return; }

  my $d = int ((1 + sqrt(8*$n -3)) * .25);
  #### $d
  #### d frac: ((1 + sqrt(8*$n -3)) * .25)
  #### base: ((2*$d - 1)*$d + 0.5)

  $n -= (2*$d - 1)*$d;
  ### rem: $n

  my $i = floor($n);
  my $if = $n - $i;
  my $r = int($i/2);
  if ($i & 1) {
    ### down
    return ($r, 2*$d - $r - $if);
  } else {
    ### across
    return ($r-1+$if, 2*$d - $r);
  }
}

# d = [ 1  2, 3, 4 ]
# N = [ 2, 7, 16, 29 ]
# N = (2 d^2 - d + 1)
# and add 2*$d
# base = 2*d^2 - d + 1 + 2*d
#      = 2*d^2 + d + 1
#      = (2*$d + 1)*$d + 1
#
sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = floor ($x + 0.5);
  $y = floor ($y + 0.5);
  if ($x < 0 || $y < 0) {
    return undef;
  }
  my $d = int(($x + $y + 1) / 2);
  return (2*$d + 1)*$d + 1 - $y + $x;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### Staircase xy_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = max (0, $x1);
  $y1 = max (0, $y1);
  $x2 = max (0, $x2);
  $y2 = max (0, $y2);
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }
  my $y_min = $y1;

  if ((($x1 ^ $y1) & 1) && $y1 < $y2) {  # y2==y_max
    $y1++;
    ### y1 inc: $y1
  }
  if (! (($x2 ^ $y2) & 1) && $y2 > $y_min) {
    $y2--;
    ### y2 dec: $y2
  }
  return ($self->xy_to_n($x1,$y1), $self->xy_to_n($x2,$y2));
}

1;
__END__

=for stopwords SquareSpiral eg Staircase PlanePath Ryde Math-Image HexSpiralSkewed ascii

=head1 NAME

App::MathImage::PlanePath::Staircase -- integer points in a diamond shape

=head1 SYNOPSIS

 use App::MathImage::PlanePath::Staircase;
 my $path = App::MathImage::PlanePath::Staircase->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path makes a staircase pattern of steps down from the Y axis to the X,

     8      29
             |
     7      30---31
                  |
     6      16   32---33
             |         |
     5      17---18   34---...
                  |
     4       7   19---20
             |         |
     3       8--- 9   21---22 
                  |         |
     2       2   10---11   23---24
             |         |         |
     1       3--- 4   12---13   25---26
                  |         |         |
    y=0 ->   1    5--- 6   14---15   27---28

             ^   
            x=0   1    2    3    4    5    6

The 1,6,15,28,etc last of each staircase along the X axis are the hexagonal
numbers k*(2*k-1).  The diagonal 3,10,21,36,etc up to the right from x=0,y=1
is the second hexagonal numbers k*(2*k+1), as obtained by extending the
hexagonal numbers to negative k.  The two together are the triangular
numbers k*(k+1)/2.

Legendre's prime generating polynomial 2*k^2+29 bounces around for some low
values then makes a steep diagonal upwards from x=19,y=1, at a slope 3 up
for 1 across, but only 2 of each 3 drawn.

=head1 FORMULAS

Within each row increasing X is increasing N, and each column increasing Y
is increasing N pairs.  On that basis in a rectangle for C<rect_to_n_range>
the lower left corner pair is the minimum N and the upper right pair is the
maximum N.

A given X,Y is the larger of an N pair when ((X^Y)&1)==1.  If that happens
at the lower left corner then X,Y+1 is the smallest N in the rectangle, when
Y+1 is also in the rectangle.  Conversely at the top right if ((X^Y)&1)==0
then it's the smaller of a pair and X,Y-1 is the bigger N, when Y-1 is in
the rectangle too.

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::Staircase-E<gt>new ()>

Create and return a new Staircase spiral object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::SquareSpiral>,
L<Math::PlanePath::HexSpiralSkewed>,
L<Math::PlanePath::PyramidSides>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2010 Kevin Ryde

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
