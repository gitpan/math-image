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


# A026140 maybe
#     A026225 -- N positions of left turns
#     A026179 -- N positions of right turns
# A038502(n) mod 3. is 1/2 turn


package Math::PlanePath::MathImageTerdragonCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 82;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::SierpinskiArrowhead;
*_round_up_pow2 = \&Math::PlanePath::SierpinskiArrowhead::_round_up_pow2;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array => [ { name      => 'arms',
                                         share_key => 'arms_6',
                                         type      => 'integer',
                                         minimum   => 1,
                                         maximum   => 6,
                                         default   => 1,
                                         width     => 1,
                                         description => 'Arms',
                                       } ];
sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 6) { $arms = 6; }
  $self->{'arms'} = $arms;
  return $self;
}

my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageTerdragonCurve n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n, $n); }

  my $frac;
  {
    my $int = int($n);
    $frac = $n - $int;  # inherit possible BigFloat
    $n = $int;          # BigFloat int() gives BigInt, use that
  }

  my $zero = ($n * 0);  # inherit bignum 0

  # initial rotation from arm number $n mod $arms
  my $arms = $self->{'arms'};
  my $rot = $n % $arms;
  $n = int($n/$arms);

  my @digits;
  my @si;
  my @sj;
  my @sk;
  {
    my $si = $zero + 1; # inherit bignum 1
    my $sj = $zero;     # inherit bignum 0
    my $sk = $zero;     # inherit bignum 0

    while ($n) {
      push @digits, ($n % 3);
      $n = int($n/3);
      push @si, $si;
      push @sj, $sj;
      push @sk, $sk;
      ### push: "digit $digits[-1]   $si,$sj,$sk"

      # straight + rot120 + straight
      ($si,$sj,$sk) = (2*$si - $sj,
                       2*$sj - $sk,
                       2*$sk + $si);
    }
  }
  ### @digits

  my $rev = 0;
  my $i = $zero;
  my $j = $zero;
  my $k = $zero;
  while (defined (my $digit = pop @digits)) {
    my $si = pop @si;
    my $sj = pop @sj;
    my $sk = pop @sk;
    ### at: "$i,$j,$k  $digit   side $si,$sj,$sk"
    ### $rot

    $rot %= 6;
    if ($rot == 1)    { ($si,$sj,$sk) = (-$sk,$si,$sj); }
    elsif ($rot == 2) { ($si,$sj,$sk) = (-$sj,-$sk,$si); }
    elsif ($rot == 3) { ($si,$sj,$sk) = (-$si,-$sj,-$sk); }
    elsif ($rot == 4) { ($si,$sj,$sk) = ($sk,-$si,-$sj); }
    elsif ($rot == 5) { ($si,$sj,$sk) = ($sj,$sk,-$si); }

    # if ($rev) {
    # if ($digit) {
    #   $x -= $sy;
    #   $y += $sx;
    #   ### rev add to: "$x,$y next is still rev"
    # } else {
    #   $rot ++;
    #   $rev = 0;
    # }

    if ($digit) {
      $i += $si;
      $j += $sj;
      $k += $sk;
      if ($digit == 2) {
        $i -= $sj;
        $j -= $sk;
        $k += $si;
      } else {
        $rot += 2;
      }
    }
  }

  # $rot %= 6;
  # $x = $frac * $rot_to_sx[$rot] + $x;
  # $y = $frac * $rot_to_sy[$rot] + $y;

  ### final: "$i,$j,$k"
  return (2*$i + $j - $k, $j+$k);
}

# point N=2^(2k) at XorY=+/-2^k  radius 2^k
#       N=2^(2k-1) at X=Y=+/-2^(k-1) radius sqrt(2)*2^(k-1)
# radius = sqrt(2^level)
# R(l)-R(l-1) = sqrt(2^level) - sqrt(2^(level-1))
#             = sqrt(2^level) * (1 - 1/sqrt(2))
# about 0.29289
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DragonMidpoint xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  return undef;

  # max(|x|,|y|), or maybe hypot, or ...
  my ($pow,$exp) = _round_up_pow2(abs($x)+abs($y));
  my $level_limit = 2*$exp + 5;
  if (_is_infinite($level_limit)) {
    return $level_limit;  # infinity
  }

  my $arms = $self->{'arms'};
  my @hypot = (5);
  for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 4 ? 3 : 4) * $hypot[$top];  # little faster than 2^lev

    # start from digits=1 but subtract 1 so that n=0,1,...,$arms-1 are tried
    # too
  ARM: foreach my $arm (-$arms .. 0) {
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

# sub xy_to_n {
#   my ($self, $x, $y) = @_;
#   ### MathImageTerdragonCurve xy_to_n(): "$x, $y"
#
#   $x = _round_nearest($x);
#   $y = _round_nearest($y);
#
#   my ($pow,$exp) = _round_up_pow2(max(abs($x),abs($y)));
#   my $level_limit = 2*$exp+5;
#   if (_is_infinite($level_limit)) {
#     return $level_limit;
#   }
#   ### $level_limit
#
#   my $top = 0;
#   my $i = 0;
#   my @digits = (0);
#   my @sx = (1);
#   my @sy = (0);
#   my @hypot = (3);
#   for (;;) {
#     my $n = 0;
#     foreach my $digit (reverse @digits) { # high to low
#       $n = 2*$n + $digit;
#     }
#     ### consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"
#     my ($nx,$ny) = $self->n_to_xy($n);
#
#     if ($i == 0 && $x == $nx && $y == $ny) {
#       ### found
#       return $n;
#     }
#
#     if ($i == 0
#         || ($x-$nx)**2 + ($y-$ny)**2 > $hypot[$i]) {
#       ### too far away: "$nx,$ny target $x,$y    ".(($x-$nx)**2 + ($y-$ny)**2).' vs '.$hypot[$i]
#
#       while (++$digits[$i] > 1) {
#         $digits[$i] = 0;
#         if (++$i <= $top) {
#           ### backtrack up
#
#         } else {
#           ### backtrack extend top
#           if ($i > $level_limit) {
#             ### not found below level limit, outside curve ...
#             return undef;
#           }
#           $digits[$i] = 0;
#           $sx[$i] = ($sx[$top] - $sy[$top]);
#           $sy[$i] = ($sx[$top] + $sy[$top]);
#           $hypot[$i] = ($i % 4 ? 2 : 3) * $hypot[$top];
#           ### assert: $hypot[$i]**2 >= $sx[$i]**2 + $sy[$i]**2
#           $top++;
#         }
#       }
#
#     } else {
#       ### descend
#       ### assert: $i > 0
#       $i--;
#       $digits[$i] = 0;
#     }
#   }
# }

# f = (1 - 1/sqrt(2) = .292
# 1/f = 3.41
# N = 2^level
# Rend = sqrt(2)^level
# Rmin = Rend / 2  maybe
# Rmin^2 = (2^level)/4
# N = 4 * Rmin^2
#
# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageTerdragonCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int($x1 > $x2 ? $x1 : $x2);
  my $ymax = int($y1 > $y2 ? $y1 : $y2);
  return (0,
          $self->{'arms'} * ($xmax*$xmax + $ymax*$ymax + 1) * 7);
}

1;
__END__

=for stopwords eg Ryde Dragon Math-PlanePath Nlevel Knuth et al vertices doublings OEIS Online terdragon

=head1 NAME

Math::PlanePath::MathImageTerdragonCurve -- triangular dragon curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageTerdragonCurve;
 my $path = Math::PlanePath::MathImageTerdragonCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress ...>

This is the terdragon curve by Davis and Knuth,


              30                28                                  7
           /       \         /       \
     31/34          26/29/32            27                          6
          \        /         \
           24/33/42            22/25                                5
          /        \         /       \
  40/43/46          20/23/44          12/21           10            4
           \       /        \        /      \      /       \
              18/45 -------- 13/16/19        8/11/14 -------- 9     3
                    \       /       \      /      \
                       17              6/15 --------- 4/7           2
                                            \       /     \
                                               2/5 ---------  3     1
                                                   \
                                         0 ----------- 1        <- Y=0

       ^       ^        ^        ^       ^      ^      ^      ^
      -4      -3       -2       -1      X=0     1      2      3

The curve visits "inside" X,Y points three times.  The first of these is
X=1,Y=3 which is N=8, N=11 and N=14.  The corners N=7,8,9, N=10,11,12 and
N=13,14,15 have touched, but the path doesn't cross itself.  The tripled
vertices are all like this, touching but not crossing, and no edges
repeating.

The first step N=1 is to the right along the X axis and the path then slowly
spirals counter-clockwise and progressively fatter.  The end of each
replication is N=3^level which is level*30 degrees around,

    N       X,Y     angle
   ----    -----    -----
     1      1,0        0
     3      3,1       30
     9      3,3       60
    27      0,6       90
    81     -9,9      120
   243    -27,9      150
   729    -54,0      180

Here's points N=0 to N=3^6=729 with the N=0 origin at "o" and N=729 end at
the "+".  It's gone half-circle around to 180 degrees,

                               * *               * *
                            * * * *           * * * *
                           * * * *           * * * *
                            * * * * *   * *   * * * * *   * *
                         * * * * * * * * * * * * * * * * * * *
                        * * * * * * * * * * * * * * * * * * *
                         * * * * * * * * * * * * * * * * * * * *
                            * * * * * * * * * * * * * * * * * * *
                           * * * * * * * * * * * *   * *   * * *
                      * *   * * * * * * * * * * * *           * *
     * +           * * * * * * * * * * * * * * * *           o *
    * *           * * * * * * * * * * * *   * *
     * * *   * *   * * * * * * * * * * * *
    * * * * * * * * * * * * * * * * * * *
     * * * * * * * * * * * * * * * * * * * *
        * * * * * * * * * * * * * * * * * * *
       * * * * * * * * * * * * * * * * * * *
        * *   * * * * *   * *   * * * * *
                 * * * *           * * * *
                * * * *           * * * *
                 * *               * *

=head2 Turns

At each point N the curve always turns 120 degrees either to the left or
right, it never goes straight ahead.  The ternary digit above the lowest 1
in N gives the turn direction.  

...

For example at N=11 shown above the curve
has just gone downwards from N=11.  N=12 is binary 0b1100, the lowest 1 bit
is the 0b.1.. and the bit above that is a 1, which means turn to the right.
Whereas later at N=18 which has gone downwards from N=17 it's N=18 in binary
0b10010, the lowest 1 is 0b...1., and the bit above that is 0, so turn left.

...

The bits also give turn after the next by taking the bit above the lowest 0.
For example at N=12 the lowest 0 is the least significant bit, and above
that is a 0 too, so after going to N=13 the next turn is then to the left to
go to N=14.  Or for N=18 the lowest 0 is again the least significant bit,
but above that is a 1 too, so after going to N=19 the next turn is to the
right to go to N=20.

=head2 Arms

The curve fills a quarter of the plane and six copies mesh together
perfectly when rotated by 60, 120, 180, 240 and 300 degrees.  The C<arms>
parameter can choose 1 to 6 curve arms, successively advancing.

For example C<arms =E<gt> 6> begins as follows, with N=0,6,12,18,etc being
one arm, N=1,7,13,19 the second, N=2,8,14,20 the third, etc.

     17 --- 13/6 --- 0/1/2/3 --- 4/15 --- 19

With four arms every X,Y point is visited twice (except the origin 0,0 where
all four begin) and every edge between the points is traversed once.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageTerdragonCurve-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageTerdragonCurve-E<gt>new (arms =E<gt> 2)>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

The optional C<arms> parameter can trace 1 to 4 copies of the curve, each
arm successively advancing.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve visits an C<$x,$y> twice for various points (all the "inside"
points).  In the current code the smaller of the two N values is returned.
Is that the best way?

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 OEIS

The terdragon is in Sloane's Online Encyclopedia of Integer Sequences as the
turn at each line segment,

    http://oeis.org/A080846  etc

    A080846 -- turn 0=left, 1=right
    A060236 -- turn 1=left, 2=right
    A026225 -- N positions of left turns
    A026179 -- N positions of right turns

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>

=cut

# Local variables:
# compile-command: "math-image --path=MathImageTerdragonCurve --lines --scale=20"
# End:
#
# math-image --path=MathImageTerdragonCurve --all --scale=10
#

