# Copyright 2012 Kevin Ryde

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


package Math::PlanePath::MathImagePixelRingsFill;
use 5.004;
use strict;
use List::Util qw(min max);
use Math::Libm 'hypot';
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 92;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


# cf A000328 number of points on circle radius n
#    A051132 num points <= circle radius n
#    A046109 num points < circle radius n
#
# N(r) = 1 + 4*sum  floor(r^2/(4i+1)) - floor(r^2/(4i+3))
#
# N(r+1) - N(r)
#   = 1 + 4*sum  floor((r+1)^2/(4i+1)) - floor((r+1)^2/(4i+3))
#     - 1 + 4*sum  floor(r^2/(4i+1)) - floor(r^2/(4i+3))
#   = 4*sum  floor(((r+1)^2-r^2)/(4i+1)) - floor(((r+1)^2-r^2)/(4i+3))
#   = 4*sum  floor((2r+1)/(4i+1)) - floor((2r+1)/(4i+3))
#
# _cumul[0] index=0 is r=1/2
#  r = index+1/2
#  2r+1 = 2(index+1/2)+1
#       = 2*index+1+1
#       = 2*index+2
#
#  2r+1 >= 4i+1
#  2r >= 4i
#  i <= (2*index+2)/2
#  i <= index+1
#
#  r=3.5
#  sqrt(3*3+3*3) = 4.24 out
#  sqrt(3*3+2*2) = 3.60 out
#  sqrt(3*3+1*1) = 3.16 in
#
#      * * *  
#    * * * * *  
#  * * * * * * *
#  * * * o * * *   3+5+7+7+7+5+3 = 37
#  * * * * * * *
#    * * * * *  
#      * * *   
#
# N(r) = 1 + 4*( floor(12.25/1)-floor(12.25/3) + floor(12.25/5)-floor(12.25/7)  + floor(12.25/9)-floor(12.25/11) )
#      = 37
#
# (index+1/2)^2 = index^2 + index + 1/4
#               >= index*(index+1)
# (end+1 + 1/2)^2
#   = (end+3/2)^2
#   = end^2 + 3*end + 9/4
#   = end*(end+3) + 2 + 1/4
#
# (r+1/2)^2 = r^2+r+1/4  floor=r*(r+1)
# (r-1/2)^2 = r^2-r+1/4  ceil=r*(r-1)+1

use vars '@_cumul';
@_cumul = (2);

sub _cumul_extend {
  ### _cumul_extend() ...
  my $r2 = ($#_cumul + 3) * $#_cumul + 2;
  my $c = 0;
  for (my $d = 1; $d <= $r2; $d += 4) {
    $c += int($r2/$d) - int($r2/($d+2));
  }
  push @_cumul, 4*$c + 2;
  ### @_cumul
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImagePixelRingsFill n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  if ($n < 2) {
    return ($n-1, 0);
  }
  # if ($n < 6) {
  #   $n -= 2;
  #   my $frac = $n - int($n);
  #   my $x = 1 - $frac;
  #   my $y = $frac;
  #   if ($n & 2) {
  #     $x = -$x;
  #     $y = -$y;
  #   }
  #   if ($n & 1) {
  #     ($x,$y) = (-$y, $x);
  #   }
  #   return ($x,$y);
  # }

  ### search cumul for: "n=$n"
  my $r = 1;
  for (;;) {
    if ($r > $#_cumul) {
      _cumul_extend ();
    }
    if ($_cumul[$r] > $n) {
      last;
    }
    $r++;
  }
  ### $r

  $n -= $_cumul[$r-1];
  my $len = $_cumul[$r] - $_cumul[$r-1];   # length of this ring

  ### cumul: "$_cumul[$r-1] to $_cumul[$r]"
  ### $len
  ### n rem: $n

  $len /= 4;     # length of a quadrant of this ring
  my $quadrant = $n / $len;   # 0 <= q < 4
  $n %= $len;

  ### len of quadrant: $len
  ### $quadrant
  ### n into quadrant: $n

  my $rev;
  if ($rev = ($n > $len/2)) {
    $n = $len - $n;
  }
  ### $rev
  ### $n

  my $rhi = ($r+1)*$r;
  my $rlo = ($r-1)*$r+1;
  my $x = $r;
  my $y = 0;
  while ($n > 0) {
    ### at: "$x,$y n=$n"

    $y++;
    ### inc y to: $y

    if ($x*$x + $y*$y > $rhi) {
      $x--;
      ### dec x to: $x
      ### assert: $x*$x + $y*$y <= $rhi
      ### assert: $x*$x + $y*$y >= $rlo
    }
    $n--;
    last if $n <= 0;

    if (($x-1)*($x-1) + $y*$y >= $rlo) {
      ### another dec x to: $x
      $x--;
      $n--;
      last if $n <= 0;
    }
  }

  if ($rev) {
    ($x,$y) = ($y,$x);
  }
  if ($quadrant & 2) {
    $x = -$x;
    $y = -$y;
  }
  if ($quadrant & 1) {
    ($x,$y) = (-$y, $x);
  }
  ### return: "$x, $y"
  return ($x, $y);
}


# h=x^2+y^2
# h >= (r-1/2)^2
# sqrt(h) >= r-1/2
# sqrt(h)+1/2 >= r
# r = int (sqrt(h)+1/2)
#   = int( (2*sqrt(h)+1)/2 }
#   = int( (sqrt(4*h) + 1)/2 }

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImagePixelRingsFill xy_to_n(): "$x, $y"
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);

  if ($x == 0 && $y == 0) {
    return 1;
  }

  my $r = int ((sqrt(4*($x*$x+$y*$y)) + 1) / 2);
  ### $r
  if (_is_infinite($r)) {
    return undef;
  }

  while ($#_cumul < $r) {
    _cumul_extend ();
  }
  my $n = $_cumul[$r-1];
  ### n base: $n

  my $len = $_cumul[$r] - $n;
  ### $len
  $len /= 4;
  ### len/4: $len

  if ($y < 0) {
    ### y neg, rotate 180
    $y = -$y;
    $x = -$x;
    $n += 2*$len;
  }

  if ($x < 0) {
    $n += $len;
    ($x,$y) = ($y,-$x);
    ### neg x, rotate 90
    ### n base now: $n
  }

  ### assert: $x >= 0
  ### assert: $y >= 0

  my $rev;
  if ($rev = ($x < $y)) {
    ### top octant, reverse: "x=$x len/4=".($len/4)." gives ".($len/4 - $x)
    ($x,$y) = ($y,$x);
  }

  my $offset = 0;
  my $rhi = ($r+1)*$r;
  my $rlo = ($r-1)*$r+1;
  ### assert: $x*$x + $y*$y <= $rhi
  ### assert: $x*$x + $y*$y >= $rlo

  my $tx = $r;
  my $ty = 0;
  while ($ty < $y) {
    ### at: "$tx,$ty offset=$offset"

    $ty++;
    ### inc ty to: $ty
    if ($tx*$tx + $ty*$ty > $rhi) {
      $tx--;
      ### dec tx to: $tx
      ### assert: $tx*$tx + $ty*$ty <= $rhi
      ### assert: $tx*$tx + $ty*$ty >= $rlo
    }
    $offset++;
    last if $x == $tx && $y == $ty;

    if (($tx-1)*($tx-1) + $ty*$ty >= $rlo) {
      ### another dec tx to: "tx=$tx"
      $tx--;
      $offset++;
      last if $y == $ty;
    }
  }

  if ($rev) {
    return $n + $len - $offset;
  } else {
    return $n + $offset;
  }
}

use constant 1.02 _PI => 4*atan2(1,1);  # similar to Math::Complex

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImagePixelRingsFill rect_to_n_range(): "$x1,$y1 $x2,$y2"

  my ($r_min, $r_max) = _rect_to_radius_range ($x1,$y1, $x2,$y2);
  $r_min = _max($r_min-1.5,0);
  $r_max += 1.5;
  return (_max (1, int (_PI * $r_min*$r_min)),
          int (_PI * $r_max*$r_max + 1));
}

#------------------------------------------------------------------------------
# generic - cf SacksSpiral

# return ($rlo,$rhi) which is the radial distance range found in the rectangle
sub _rect_to_radius_range {
  my ($x1,$y1, $x2,$y2) = @_;

  # if opposite sign then origin x=0 covered, similarly y=0
  my $x_origin_covered = ($x1<0) != ($x2<0);
  my $y_origin_covered = ($y1<0) != ($y2<0);

  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);

  return (hypot ($x_origin_covered ? 0 : min($x1,$x2),
                 $y_origin_covered ? 0 : min($y1,$y2)),
          hypot (max($x1,$x2),
                 max($y1,$y2)));
}

1;
__END__

=for stopwords Ryde pixellated Math-PlanePath

=head1 NAME

Math::PlanePath::MathImagePixelRingsFill -- pixellated concentric filled rings

=head1 SYNOPSIS

 use Math::PlanePath::MathImagePixelRingsFill;
 my $path = Math::PlanePath::MathImagePixelRingsFill->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path puts points on the pixels of filled circles of width 1 unit each.
This is the algorithm of the X11 drawing operations.

                                                       5
   
                                                       4
   
                                                       3
   
                                                       2
   
                                                       1
   
                                                     y=0
   
                                                      -1
   
                                                      -2
   
                                                      -3
   
                                                      -4
   
                                                      -5

    -5  -4  -3  -2  -1  x=0  1   2   3   4   5

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImagePixelRingsFill-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

For C<$n < 1> the return is an empty list, it being considered there are no
negative points.

The behaviour for fractional C<$n> is not settled yet.  A position on the
line segment between the integer N's might make sense, but perhaps pointing
17.99 towards the "6" position to make a ring instead of towards the "18".

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PixelRings>,
L<Math::PlanePath::Hypot>,
L<Math::PlanePath::MultipleRings>

=cut
