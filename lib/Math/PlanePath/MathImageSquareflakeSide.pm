# up or down first ?




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


# math-image --path=MathImageSquareflakeSide --lines --scale=10
# math-image --path=MathImageSquareflakeSide --all --output=numbers_dash --size=80x50

package Math::PlanePath::MathImageSquareflakeSide;
use 5.004;
use strict;
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

# return ($pow, $exp) with $pow = 4**$exp <= $n, the next power of 4 at or
# below $n
# shared with PythagoreanTree ...
sub _round_down_pow4 {
  my ($n) = @_;
  my $exp = int(log($n)/log(4));
  my $pow = 4**$exp;

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log(4)
  if ($pow > $n) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
    $pow = 4**$exp;
  } elsif (4*$pow <= $n) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
    $pow *= 4;
  }
  return ($pow, $exp);
}

#         5---6
#         |   |
# 0---1   4   7---8
#     |   |
#     2---3
#
sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageSquareflakeSide n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $x;
  my $y = 0;
  {
    my $int = int($n);
    $x = $n - $int;  # frac
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  my $len = 1;
  while ($n) {
    my $digit = $n % 8;
    $n = int($n/8);
    ### at: "$x,$y"
    ### $digit

    if ($digit == 0) {

    } elsif ($digit == 1) {
      ($x,$y) = ($y + $len,     # rotate -90 and offset
                 -$x);

    } elsif ($digit == 2) {
      $x += $len;    # offset
      $y -= $len;

    } elsif ($digit == 3) {
      ($x,$y) = (-$y + 2*$len,     # rotate +90 and offset
                 $x  - $len);

    } elsif ($digit == 4) {
      ($x,$y) = (-$y + 2*$len,     # rotate +90 and offset
                 $x);

    } elsif ($digit == 5) {
      $x += 2*$len;    # offset
      $y += $len;

    } elsif ($digit == 6) {
      ($x,$y) = ($y + 3*$len,     # rotate -90 and offset
                 -$x + $len);

    } elsif ($digit == 7) {
      ### assert: $digit==7
      $x += 3*$len;    # offset
    }
    $len *= 4;
  }

  ### final: "$x,$y"
  return ($x,$y);
}


#         8
#         |
#     6---7
#     |
#     5---4---3
#             |
#         1---2
#         |
#         0
#
#         *
#       /   \
#     /   5---6
#   /     |   | \
# 0---1   4   7---8
#   \ |   |     / |
#     2---3  10---9
#      \    / |
#         *
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageSquareflakeSide xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0) {
    ### neg x ...
    return undef;
  }
  my ($len,$level) = _round_down_pow4(($x+abs($y)) || 1);
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }

  my $diamond_p = sub {
    ### diamond_p(): "$x,$y  len=$len  is ".(($x == 0 && $y == 0) || ($y < $x && $y >= -$x && $y <= $len-$x && $y > $x-$len))
    return (($x == 0 && $y == 0)
            || ($y < $x
                && $y >= -$x
                && $y <= $len-$x
                && $y > $x-$len));
  };

  my $n = 0;
  foreach (0 .. $level) {
    $n *= 8;
    ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
    if (&$diamond_p()) {
      # digit 0 ...
    } else {
      ($x,$y) = (-$y, $x-$len);   # shift and rotate +90

      if (&$diamond_p()) {
        # digit 1 ...
        $n += 1;
      } else {
        ($x,$y) = ($y, $len-$x);  # shift and rotate -90

        if (&$diamond_p()) {
          # digit 2 ...
          $n += 2;
        } else {
          ($x,$y) = ($y, $len-$x);  # shift and rotate -90

          if (&$diamond_p()) {
            # digit 3 ...
            $n += 3;
          } else {
            $x -= $len;

            if (&$diamond_p()) {
              # digit 4 ...
              $n += 4;
            } else {
              ($x,$y) = (-$y, $x-$len);   # shift and rotate +90

              if (&$diamond_p()) {
                # digit 5 ...
                $n += 5;
              } else {
                ($x,$y) = (-$y, $x-$len);   # shift and rotate +90

                if (&$diamond_p()) {
                  # digit 6 ...
                  $n += 6;
                } else {
                  ($x,$y) = ($y, $len-$x);   # shift and rotate -90

                  if (&$diamond_p()) {
                    # digit 7 ...
                    $n += 7;

                  } else {
                    return undef;
                  }
                }
              }
            }
          }
        }
      }
    }
    $len /= 4;
  }
  ### end at: "x=$x,y=$y   n=$n"
  if ($x != 0 || $y != 0) {
    return undef;
  }
  return $n;
}

# level extends to x= 4^level
#                  level = log4(x)
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageSquareflakeSide rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  if ($x2 < $x1) {
    $x2 = $x1;   # x2 bigger
  }
  if ($x2 < 0) {
    return (1,0);  # rect all x negative, no points
  }

  $y1 = abs (_round_nearest ($y1));
  $y2 = abs (_round_nearest ($y2));
  if ($y2 < $y1) {
    $y2 = $y1;   # y2 bigger
  }

  my $level = ceil (log($x2+$y2+1) / log(4));
  ### $level
  return (0, 8**$level);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageSquareflakeSide -- zig-zag of eight segments

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSquareflakeSide;
 my $path = Math::PlanePath::MathImageSquareflakeSide->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path is a self-similar zig-zag of eight segments,

                                 45-46                         5
                                  |  |
                           40-41 44 47-48                      4
                            |  |  |     |
                        38-39 42-43 50-49                      3
                         |           |
                        37-36-35    51-52-53                   2
                               |           |
          5--6             33-34       55-54 61-62             1
          |  |              |           |     |  |
    0--1  4  7--8          32          56-57 60 63-64      <- Y=0
       |  |     |           |              |  |     |
       2--3 10--9       30-31             58-59    ...        -1
             |           |
            11-12-13    29-28-27                              -2
                   |           |
               15-14 21-22 25-26                              -3
                |     |  |  |
               16-17 20 23-24                                 -4
                   |  |
                  18-19                                       -5
    ^
   X=0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

The base shape is the initial N=0 to N=8 section,

              5---6
              |   |
      0---1   4   7---8
          |   |
          2---3

It then repeats, with sections turned to follow the edges, so N=8 to N=16 is
the same shape going downwards, then N=16 to N=24 across, N=24 to N=32
upwards, etc.

The result is the base figure at ever greater scale, extending to the right,
and with wiggly lines making up the segments.  The wiggles don't overlap.

A given replication extends to

    Nlevel = 8^level
    X = 4^level
    Y = 0

    Ymax = 4^0 + 4^1 + ... + 4^level   # 11...11 in base 4
         = (4^(level+1) - 1) / 3
    Ymin = - Ymax

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageSquareflakeSide-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

L<Math::Fractal::Curve> -- its F<examples/generator4.pl> is this curve

=cut



                    0   1   2   3   4   5   6   7   8
                                             
    8                                               @
                                                    |
    7                                               +---+
                                                        |
    6                                           +---+---+
                                                |       
    5                                           +---+
                                                    |
    4                                               @---+   +   +---@
                                                                    |
    3           +---+                                               +
                |   |                                                
    2       @---+   +   +---@                                       +
                    |   |   |                                        
    1               +---+   +---+       +---+                       +
                                |       |   |                        
    0                   +---+---+   @---+   +   +---@---+   +   +---@
                        |           |       |   |
                +---+   +---+       +       +---+
                |   |       |        
            @---+   +   +---@       +
                    |   |            
                    +---+           +
                                    |
                                    @---+   +   +---@
                                                    |
                                                    +
                                                     
                                                    +
                                                     
                                                    +
                                                    |
                                                    @
