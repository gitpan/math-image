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


package App::MathImage::PlanePath::ReplicatingSquares;
use 5.004;
use strict;
use warnings;
use List::Util qw(min max);
use POSIX qw(floor ceil);

use Math::PlanePath;

use vars '$VERSION', '@ISA';
$VERSION = 24;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### ReplicatingSquares n_to_xy(): $n

  return if $n < 1;
  $n = floor ($n - 0.5);

  my $x = 0;
  my $y = 0;
  if (my $xmod = $self->{'wider'}) {

    $xmod += 2;
    ### $xmod

    my $xbit = 1;
    my $ybit = 1;
    while ($n) {
      ### $x
      ### $y
      ### $n
      ### $xbit
      ### $ybit
      $x += ($n % $xmod) * $xbit;
      $n = floor ($n / $xmod);
      $xbit *= $xmod;

      if ($n & 1) {
        $y += $ybit;
      }
      $n >>= 1;
      $ybit <<= 1;
    }
  } else {
    my $bit = 1;
    while ($n) {
      ### $x
      ### $y
      ### $n
      ### $bit
      if ($n & 1) {
        $x += $bit;
      }
      if ($n & 2) {
        $y += $bit;
      }
      $n >>= 2;
      $bit <<= 1;
    }
  }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ReplicatingSquares xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  return if ($x < 0 || $y < 0);

  my $xmod = 2 + ($self->{'wider'} || 0);

  my $n = 0;
  my $npos = 1;
  while ($x || $y) {
    $n += ($x % $xmod) * $npos;
    $x = int ($x / $xmod);
    $npos *= $xmod;

    if ($y & 1) {
      $n += $npos;
    }
    $y >>= 1;
    $npos <<= 1;
  }
  return ($n+1);
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  # monotonic increasing in $x and $y directions
  return ($self->xy_to_n (max(0,min($x1,$x2)), max(0,min($y1,$y2))),
          $self->xy_to_n (max($x1,$x2,0), max($y1,$y2,0)));
}

1;
__END__

=for stopwords Ryde Math-Image

=head1 NAME

App::MathImage::PlanePath::ReplicatingSquares -- replicating L shapes

=head1 SYNOPSIS

 use App::MathImage::PlanePath::ReplicatingSquares;
 my $path = App::MathImage::PlanePath::ReplicatingSquares->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points in a pattern of replicating squares

      7  | 43  44  47  48  59  60  63  64
      6  | 41  42  45  46  57  58  61  62
      5  | 35  36  39  40  51  52  55  56
      4  | 33  34  37  38  49  50  53  54
      3  | 11  12  15  16  27  28  31  32
      2  |  9  10  13  14  25  26  29  30
      1  |  3   4   7   8  19  20  23  24
     y=0 |  1   2   5   6  17  18  21  22  ...
         |
         +--------------------------------
          x=0   1   2   3   4   5   6   7

The start is the 2x2 square 1,2,3,4.  That layout is then replicated to make
a 4x4 square out of 2x2 parts, and so on doubling in size.

  |
  +--------+--------+
  | 11  12 | 15  16 |
  |  9  10 | 13  14 |
  +--------+--------+
  |  3   4 |  7   8 |
  |  1   2 |  5   6 |
  +--------+--------+-

The coordinate calculation is simple.  X and Y are simply every second bit
of N-1.  So if N-1 = binary 101010 then X=000 and Y=111 in binary, which is
the N=43 shown above at X=0,Y=7.

Within a 2x2, 4x4, 8x8, 16x16 etc 2^(2^k) size square square all the N
values 1 to 2^(2*(2^k)) fall within the square, so they're just a certain
arrangement within that area.  The top left corner 4, 16, 64, 256 etc is the
2^(2*(2^k)) maximum in each.

=head1 Wider

An optional C<wider> parameter extends the squares horizontally to make
rectangles.

=head1 FUNCTIONS

=over 4

=item C<$path = App::MathImage::PlanePath::ReplicatingSquares-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 1> then the return is an empty list.

Currently there are no fractional positions between then integer positions
and in the current code C<$n> is rounded to the nearest integer.  Perhaps
this will change, maybe something like unit diagonals through each square.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return an integer point number for coordinates C<$x,$y>.  Each integer N is
considered the centre of a unit square an C<$x,$y> within that square
returns N.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::Diagonals>

=cut
