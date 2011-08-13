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


# math-image --path=MathImageDragonRounded --lines --scale=10
# math-image --path=MathImageDragonRounded,arms=4 --all --output=numbers_dash
#
# A014577 dragon rotation steps, 0=left, 1=right
# A005811 total rotation
#
# cf
#    A175337 r5 dragon turns
#    A176405 r7 dragon turns



package Math::PlanePath::MathImageDragonRounded;
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
*_floor = \&Math::PlanePath::_floor;


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 4) { $arms = 4; }
  $self->{'arms'} = $arms;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DragonRounded n_to_xy(): $n

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;
    $n = $int; # BigFloat int() gives BigInt, use that
  }
  ### $frac

  $n -= 1;
  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my $x_offset = ($n % 2);
  $n = int($n/2);

  # ENHANCE-ME: sx,sy just from len,len
  my @digits;
  my @sx;
  my @sy;
  {
    my $sx = 3;
    my $sy = 0;
    while ($n) {
      push @digits, ($n % 2);
      push @sx, $sx;
      push @sy, $sy;
      $n = int($n/2);

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = 0;
  my $y = 0;
  my $above_low_zero = 0;

  for (my $i = $#digits; $i >= 0; $i--) {     # high to low
    my $digit = $digits[$i];
    my $sx = $sx[$i];
    my $sy = $sy[$i];
    ### at: "$x,$y  $digit   side $sx,$sy"
    ### $rot

    if ($rot & 2) {
      ($sx,$sy) = (-$sx,-$sy);
    }
    if ($rot & 1) {
      ($sx,$sy) = (-$sy,$sx);
    }
    ### rotated side: "$sx,$sy"

    if ($rev) {
      if ($digit) {
        $x += -$sy;
        $y += $sx;
        ### rev add to: "$x,$y next is still rev"
      } else {
        $above_low_zero = $digits[$i+1];
        $rot ++;
        $rev = 0;
        ### rev rot, next is no rev ...
      }
    } else {
      if ($digit) {
        $rot ++;
        $x += $sx;
        $y += $sy;
        $rev = 1;
        ### plain add to: "$x,$y next is rev"
      } else {
        $above_low_zero = $digits[$i+1];
      }
    }
  }

  # Digit above the low zero is the direction of the next turn, 0 for left,
  # 1 for right, and that determines the y_offset to apply to go across
  # towards the next edge.  When original input $n is odd, which means
  # $x_offset 0 at this point, there's no y_offset as going along the edge
  # not across the vertex.
  #
  my $y_offset = ($x_offset ? ($above_low_zero ? -$frac : $frac)
                  : 0);
  $x_offset += $frac + 1;

  ### final: "$x,$y  rot=$rot  above_low_zero=$above_low_zero   offset=$x_offset,$y_offset"
  if ($rot & 2) {
    ($x_offset,$y_offset) = (-$x_offset,-$y_offset);  # rotate 180
  }
  if ($rot & 1) {
    ($x_offset,$y_offset) = (-$y_offset,$x_offset);  # rotate +90
  }
  $x += $x_offset;
  $y += $y_offset;
  ### rotated offset: "$x_offset,$y_offset   return $x,$y"
  return ($x,$y);
}

# point N>=2^18 have radius >= 2^17 or a bit less
# N = 2^level
#     r >= 2^(level-1)
#     h >= 4^(level-1)
#     level-1 <= log4(h)
#     level-1 <= 2*log2(h)
#     level <= 2*log2(h) + 1

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DragonRounded xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  {
    my $yrem = $y % 3;
    if ($x % 3) {
      # horizontal
      if ($yrem) {
        return undef;
      }
    } else {
      # vertical
      unless ($yrem) {
        return undef;
      }
    }
  }

  my ($pow,$exp) = _round_up_pow2(max(abs($x/3),abs($y/3)));
  my $level_limit = 2*$exp + 5;
  if (_is_infinite($level_limit)) {
    return $level_limit;
  }

  my $arms = $self->{'arms'};
  my @hypot = (10);
  for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 4 ? 2 : 3) * $hypot[$top];  # little faster than 2^lev

  ARM: foreach my $arm (0 .. $arms-1) {
      my @digits = (((0) x $top), 1);
      my $i = $top;
      for (;;) {
        my $n = 0;
        foreach my $digit (reverse @digits) { # high to low
          $n = 2*$n + $digit;
        }
        $n = $arms*$n + $arm;
        ### consider: "arm=$arm i=$i  digits=".join(',',reverse @digits)."  is n=$n"

        my ($nx,$ny) = $self->n_to_xy($n);
        ### at: "n $nx,$ny  cf hypot ".$hypot[$i]

        if ($i == 0 && $x == $nx && $y == $ny) {
          ### found
          return $n;
        }

        if ($i == 0 || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
          ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]

          while (++$digits[$i] > 1) {
            $digits[$i] = 0;
            if (++$i >= $top) {
              ### backtrack past top ...
              next ARM;
            }
            ### backtrack up
          }

        } else {
          ### descend
          ### assert: $i > 0
          $i--;
          $digits[$i] = 0;
        }
      }
    }
  }
  ### not found below level limit
  return undef;
}

# level 21  n=1048576 .. 2097152
#   min 1052677 0b100000001000000000101   at -1026,1  factor 1.99610706057474
#   n=2^20 min r^2=2^20 plus a bit
#   maybe ...
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DragonRounded rect_to_n_range(): "$x1,$y1  $x2,$y2  arms=$self->{'arms'}"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int(($x1 > $x2 ? $x1 : $x2) / 3);
  my $ymax = int(($y1 > $y2 ? $y1 : $y2) / 3);
  return (1,
          ($xmax*$xmax + $ymax*$ymax + 1) * $self->{'arms'} * 16);

  # use Math::PlanePath::SacksSpiral;
  # my ($r_lo, $r_hi) = Math::PlanePath::SacksSpiral::_rect_to_radius_range
  #   ($x1/3,$y1/3, $x2/3,$y2/3);
  # my $level_hi = ceil (log($r_hi+.1) * (3 * 1/log(2))) + 1;
  # return (1, (2**$level_hi + 2));
}

sub _round_up_pow2 {
  my ($x) = @_;
  my $exp = ceil (log(max(1, $x)) / log(2));
  my $pow = 2 ** $exp;
  if ($pow < $x) {
    return (2*$pow, $exp+1)
  } else {
    return ($pow, $exp);
  }
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel

=head1 NAME

Math::PlanePath::MathImageDragonRounded -- dragon curve with rounded corners

=head1 SYNOPSIS

 use Math::PlanePath::MathImageDragonRounded;
 my $path = Math::PlanePath::MathImageDragonRounded->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is a version of the dragon or paper folding curve by Heighway, Harter,
et al, done with two points per edge and skipping the vertices so as to make
rounded corners,

                         18-17             10--9                   6
                        /     \           /     \
                      19       16       11        8                5
                       |        |        |        |
                      20       15       12        7                4
                        \        \     /           \
                         21-22    14-13              6--5          3
                              \                          \
                               23                          4       2
                                |                          |
                               24                          3       1
                              /                          /
       34-33             26-25                    .  1--2      <- Y=0
      /     \           /
    35       32       27                                          -1
     |        |        |
    36       31       28                                          -2
      \        \     /
       37-38    30-29    45-46                                    -3
            \           /     \
             39       44       47                                 -4
              |        |        |
             40       43       48                                 -5
               \     /        /
                41-42    50-49                                    -6
                        /
                      51                                          -7
                       |
                      ...

     ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
   -15-14-13-12-11-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3 ...

Each edge of the curve is on an X or Y multiple of 3 and the two points on
the edge are in between at 1 mod 3 and 2 mod 3.  For example the N=19 and
N=20 are on the X=-9 edge (a multiple of 3), and at Y=4 and Y=5 (which are 1
and 2 mod 3).

The "rounding" of the corners ensures that for example N=15 and N=22 don't
touch as they approach X=-6,Y=3.  The curve never crosses itself, but the
vertices would touch everywhere it bends back towards itself if it wasn't
for the rounding.

=head2 Arms

The curve traverses a quarter of the plane and four copies mesh together
perfectly when rotated by 90, 180 and 270 degrees.  The C<arms> parameter
can choose 1 to 4 curve arms, successively advancing.  For example C<arms
=E<gt> 4> gives

                 37-33             60-...           6
                /     \           /
     ...      41       29       56                  5
      |        |        |        |
     57       45       25       52                  4
       \     /           \        \
        53-49    14-10    21-17    48-44            3
                /     \        \        \
              18        6       13       40         2
               |        |        |        |
              22        2        9       36         1
             /                 /        /
        30-26     7--3     1--5    28-32        <- Y=0
       /        /                 /
     34       11        4       24                 -1
      |        |        |        |
     38       15        8       20                 -2
       \        \        \     /
        42-46    19-23    12-16    51-55           -3
             \        \           /     \
              50       27       47       59        -4
               |        |        |        |
              54       31       43       ...       -5
             /           \     /
       ...-58             35-39                    -6

      ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^
     -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImageDragonRounded-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageDragonRounded-E<gt>new (arms =E<gt> $aa)>

Create and return a new path object.

The optional C<arms> parameter makes a multi-arm curve.  The default is 1
for just one arm.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 1 and if C<$n E<lt> 1> then the return is an empty list.

=item C<$n = $path-E<gt>n_start()>

Return 1, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::KochCurve>

=cut
