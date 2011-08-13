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


# math-image --path=MathImageSierpinskiCurve --lines --scale=10
# math-image --path=MathImageSierpinskiCurve --all --output=numbers_dash


package Math::PlanePath::MathImageSierpinskiCurve;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 66;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

sub n_to_xy {
  my ($self, $n) = @_;
  ### SierpinskiCurve n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $x = ($n % 2);
  $n = int($n/2);
  my $y = 0;
  if ($x == 0) {
    $x = $frac;
    $frac = 0;
  }

  my $len = 2;
  while ($n) {
    my $digit = $n % 4;
    $n = int($n/4);
    ### at: "$x,$y"
    ### $digit

    if ($digit == 0) {
      $x += $frac;
      $y += $frac;
      $frac = 0;

    } elsif ($digit == 1) {
      ($x,$y) = (-$y + $len + $frac,   # rotate +90
                 $x  + 1);
      $frac = 0;

    } elsif ($digit == 2) {
      ($x,$y) = ($y  + $len+1 + $frac,   # rotate -90
                 -$x + $len   - $frac);
      $frac = 0;

    } else {
      $x += $len + 2;
    }
    $len = 2*$len+2;
  }

  ### final: "$x,$y"
  return ($x+$frac,$y+$frac);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### SierpinskiPeaks xy_to_n(): "$x, $y"

  return undef;

  $x = _round_nearest($x);
  $y = _round_nearest($y);
  if ($y < 0 || $x < 0 || (($x ^ $y) & 1)) {
    ### neg y or parity different ...
    return undef;
  }
  my ($len,$level) = _round_down_pow3(($x/2)||1);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 4;
    ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
    if ($x < 3*$len) {
      if ($x < 2*$len) {
        ### digit 0 ...
      } else {
        ### digit 1 ...
        $x -= 2*$len;
        ($x,$y) = (($x+3*$y)/2,   # rotate -60
                   ($y-$x)/2);
        $n++;
      }
    } else {
      $x -= 4*$len;
      ### digit 2 or 3 to: "x=$x"
      if ($x < $y) {   # before diagonal
        ### digit 2...
        $x += $len;
        $y -= $len;
        ($x,$y) = (($x-3*$y)/2,     # rotate +60
                   ($x+$y)/2);
        $n += 2;
      } else {
        #### digit 3...
        $n += 3;
      }
    }
    $len /= 3;
  }
  ### end at: "x=$x,y=$y   n=$n"
  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# level extends to x= 2*3^level
#                  level = log3(x/2)
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### SierpinskiCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  #            x2
  # y2 +-------+      *
  #    |       |    *
  # y1 +-------+  *
  #             *
  #           *
  #         *
  #       ------------------
  #
  if ($y2 < 0  || $x2 < $y1) {
    ### outside first octant
    return (1,0);
  }
  if (_is_infinite($x2)) {
    return (0, $x2);
  }

  my $n_lo = 1;
  my $w = 2;
  while ($w < $x1) {
    $n_lo *= 4;
    $w = 2*$w + 2;
  }

  my $n_hi = 1;
  $w = 0;
  while ($w < $x2) {
    $n_hi *= 4;
    $w = 2*$w + 2;
  }

  return ($n_lo-1, $n_hi);
}

1;
__END__

=for stopwords eg Ryde Sierpinski Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::MathImageSierpinskiCurve -- Sierpinski octant curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSierpinskiCurve;
 my $path = Math::PlanePath::MathImageSierpinskiCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is an integer version of the self-similar curve by Sierpinski
going along the X axis and making triangular excursions.


                                             63-64            14
                                              |  |
                                             62 65            13
                                            /     \
                                       60-61       66-67      12
                                        |              |
                                       59-58       69-68      11
                                            \     /
                                 51-52       57 70            10
                                  |  |        |  |
                                 50 53       56 71       ...   9
                                /     \     /     \     /
                           48-49       54-55       72-73       8
                            |
                           47-46       41-40                   7
                                \     /     \
                     15-16       45 42       39                6
                      |  |        |  |        |
                     14 17       44-43       38                5
                    /     \                 /
               12-13       18-19       36-37                   4
                |              |        |
               11-10       21-20       35-34                   3
                    \     /                 \
          3--4        9 22       27-28       33                2
          |  |        |  |        |  |        |
          2  5        8 23       26 29       32                1
        /     \     /     \     /     \     /
    0--1        6--7       24-25       30-31                 Y=0

    ^
   X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 ...

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageSierpinskiCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

=cut
