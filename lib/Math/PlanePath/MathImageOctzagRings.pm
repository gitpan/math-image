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


# math-image --path=MathImageOctzagRings --lines --scale=10

# area approaches sqrt(48)/10


package Math::PlanePath::MathImageOctzagRings;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::PlanePath::MathImageOctzagCurve;

use vars '$VERSION', '@ISA';
$VERSION = 67;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;


sub _prevpow8 {
  my ($n) = @_;
  my $pow = 0;
  while (($n /= 8) >= 1) {
    $pow++;
  }
  return $pow;
}
### assert: _prevpow8(7) == 0
### assert: _prevpow8(8) == 1
### assert: _prevpow8(9) == 1
### assert: _prevpow8(63) == 1
### assert: _prevpow8(64) == 2
### assert: _prevpow8(65) == 2


# N=1 to 4      4 of, level=0
# N=5 to 36    12 of, level=1
# N=37 to ..   48 of, level=3
#
# each loop = 4*8^level
#
#     n_base = 1 + 4*8^0 + 4*8^1 + ... + 4*8^(level-1)
#            = 1 + 4*[ 8^0 + 8^1 + ... + 8^(level-1) ]
#            = 1 + 4*[ (8^level - 1)/7 ]
#            = 1 + 4*(8^level - 1)/7
#            = (4*8^level - 4 + 7)/7
#            = (4*8^level + 3)/7
#
#     n >= (4*8^level + 3)/7
#     7*n = 4*8^level + 3
#     (7*n - 3)/4 = 8^level
#
#    nbase(k+1)-nbase(k)
#       = (4*8^(k+1)+3  - (4*8^k+3)) / 7
#       = (4*8*8^k - 4*8^k) / 7
#       = (4*8-4) * 8^k / 7
#       = 28 * 8^k / 7
#       = 4 * 8^k
#
#    nbase(0) = (4*8^0 + 3)/7 = (4+3)/7 = 1
#    nbase(1) = (4*8^1 + 3)/7 = (4*8+3)/7 = (32+3)/7 = 35/7 = 5
#    nbase(2) = (4*8^2 + 3)/7 = (4*64+3)/7 = (256+3)/7 = 259/7 = 37
#
### loop 1: 4* 8**1
### loop 2: 4* 8**2
### loop 3: 4* 8**3

# sub _level_to_base {
#   my ($level) = @_;
#   return (4*8**$level + 3) / 7;
# }
# ### level_to_base(1): _level_to_base(1)
# ### level_to_base(2): _level_to_base(2)
# ### level_to_base(3): _level_to_base(3)

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageOctzagRings n_to_xy(): $n
  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  my $level = _prevpow8((7*$n - 3) / 4);
  my $base = (4 * 8**$level + 3)/7;

  ### $level
  ### $base
  ### next base would be: (4 * 8**($level+1) + 3)/7

  my $rem = $n - $base;
  ### $rem

  ### assert: $n >= $base
  ### assert: $n < 8**($level+1)
  ### assert: $rem>=0
  ### assert: $rem < 4 * 8 ** $level

  my $sidelen = 8**$level;
  my $side = int($rem / $sidelen);
  ### $sidelen
  ### $side
  ### $rem
  $rem -= $side*$sidelen;
  ### assert: $side >= 0 && $side < 4
  my ($x, $y) = Math::PlanePath::MathImageOctzagCurve->n_to_xy ($rem);

  my $pos = 4**$level / 2;
  ### side calc: "$x,$y   for pos $pos"

  if ($side < 1) {
    ### horizontal rightwards
    return ($x - $pos,
            $y - $pos);
  } elsif ($side < 2) {
    ### right vertical upwards
    return ($pos - $y,     # rotate +90, offset
            $x - $pos);
  } elsif ($side < 3) {
    ### horizontal leftwards
    return ($pos - $x,     # rotate 180, offset
            $pos - $y)
  } else {
    ### left vertical downwards
    return ($y - $pos,     # rotate -90, offset
            $pos - $x);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageOctzagRings xy_to_n(): "$x, $y"

  $x = floor($x + 0.5);
  if (abs($x) <= 1) {
    if ($x == 0) {
      if ($y >= 1/6 && $y < 1.5) {  # up to 1+1/2, not just 1+1/6
        return 3;
      }
    } else {
      if ($y >= -.5 && $y < 0.5) {
        return 1 + ($x > 0);
      }
    }
  }

  $y = floor($y + 0.5);
  if (($x ^ $y) & 1) {
    ### diff parity...
    return undef;
  }

  my $high;
  if ($x > 0 && $x >= -3*$y) {
    ### right upper third n=2 ...
    ($x,$y) = ((3*$y-$x)/2,   # rotate -120 and flip vert
               ($x+$y)/2);
    $high = 2;
  } elsif ($x <= 0 && 3*$y > $x) {
    ### left upper third n=3 ...
    ($x,$y) = (($x+3*$y)/-2,             # rotate +120 and flip vert
               ($y-$x)/2);
    $high = 3;
  } else {
    ### lower third n=1 ...
    $y = -$y;  # flip vert
    $high = 1;
  }
  ### rotate/flip to: "$x,$y"
  if ($y <= 0) {
    return undef;
  }

  my ($len,$level) = Math::PlanePath::MathImageOctzagCurve::_round_down_pow4($y);
  $level += 1;
  ### $level
  ### $len
  if (_is_infinite($level)) {
    return $level;
  }
  my $n = Math::PlanePath::KochCurve->xy_to_n($x+3*$len, $y-$len);
  ### plain curve on: ($x+3*$len).",".($y-$len)."  n=".(defined $n && $n)
  ### $high
  ### high: (8**$level)*$high
  if (defined $n) {
    return (8**$level)*$high + $n;
  } else {
    return undef;
  }




  # if ($y < 0) {
  #   return undef;
  # }
  #
  # ### assert: 3*$y <= $x && 3*$y < -$x
  # ### add ylen: "$len to $x,$y"
  # ### $level
  #
  # while ($level-- >= 0) {
  #   $n *= 4;
  #   ### at: "level=$level len=$len   x=$x,y=$y  n=$n"
  #   if ($x < 0) {
  #     if ($x < -$len) {
  #       ### digit 0, x add: 2*$len
  #       $x += 2*$len;
  #     } else {
  #       ### digit 1...
  #       $x += $len;
  #       ($x,$y) = (($x-3*$y)/2 - $len,     # rotate +60
  #                  ($x+$y)/2);
  #       $n++;
  #     }
  #   } else {
  #     if ($x <= $len && $y != 0) {
  #       ### digit 2...
  #       $y += $len;
  #       ($x,$y) = (($x+3*$y)/2 - $len,   # rotate -60
  #                  ($y-$x)/2);
  #       $n += 2;
  #     } else {
  #       #### digit 3...
  #       $x -= 2*$len;
  #       $n += 3;
  #     }
  #   }
  #   $len /= 3;
  # }
  # ### end at: "x=$x,y=$y"
  # if ($x != -1 || $y != 0) {
  #   return undef;
  # }
  # return $n;
}

# level extends to x= +/- 3^level
#                  y= +/- 2*3^(level-1)
#                   =     2/3 * 3^level
#                  1.5*y = 3^level
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageOctzagRings rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);

  ### ymul: max(1,abs($y1)*1.5,abs($y2)*1.5)
  ### ylog: log(max(1,abs($y1)*1.5,abs($y2)*1.5))/log(3)
  my $level = ceil (log (max(1,
                             abs($x1), abs($x2),
                             abs($y1)*1.5, abs($y2)*1.5))
                    / log(3));
  ### $level
  # end of $level is 1 before base of $level+1
  return (1, 8**($level+1) - 1);
}

1;
__END__

=for stopwords eg Ryde ie SVG Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageOctzagRings -- Koch snowflakes as concentric rings

=head1 SYNOPSIS

 use Math::PlanePath::MathImageOctzagRings;
 my $path = Math::PlanePath::MathImageOctzagRings->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is concentric Octzag curves making the sides of a square.

                                ^
    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The initial figure is the square N=1,2,3,4 then for the next level each
straight side expands to 4x longer and a zigzag like N=4 through N=12,

                                *---*
                                |   |
      *---*     becomes     *---*   *   *---*
                                    |   |
                                    *---*

=head2 Level Ranges

Counting the innermost square as level 0, each ring is

    Nstart = 8^level
    length = 4*(8^level)   many points

For example the outer ring shown above is level 2 starting N=8^2=16 and
having length=3*4^2=48 points (through to N=63 inclusive).

The X range at a given level is ...

     Xlo = -(4^level) - ...
     Xhi = +(4^level) + ...

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageOctzagRings-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::GosperIslands>,
L<Math::PlanePath::KochSnowflakes>

=cut
