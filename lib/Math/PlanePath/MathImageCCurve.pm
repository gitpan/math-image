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


package Math::PlanePath::MathImageCCurve;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 88;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;

my @rot_to_sx = (1,0,-1,0);
my @rot_to_sy = (0,1,0,-1);

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageCCurve n_to_xy(): $n

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
  my $rot = 0;

  my @digits;
  my @sx;
  my @sy;
  {
    my $sy = $zero;
    my $sx = $zero + 1; # bignum 1
    ### $sx
    ### $sy

    while ($n) {
      push @digits, ($n % 2);
      $n = int($n/2);
      push @sx, $sx;
      push @sy, $sy;

      # (sx,sy) + rot+90(sx,sy)
      ($sx,$sy) = ($sx - $sy,
                   $sy + $sx);
    }
  }

  ### @digits
  my $rev = 0;
  my $x = $zero;
  my $y = $zero;
  while (defined (my $digit = pop @digits)) {
    my $sx = pop @sx;
    my $sy = pop @sy;
    ### at: "$x,$y  $digit   side $sx,$sy"
    ### $rot

    if ($digit) {
      if ($rot & 2) {
        ($sx,$sy) = (-$sx,-$sy);
      }
      if ($rot & 1) {
        ($sx,$sy) = (-$sy,$sx);
      }
      $x += $sx;
      $y += $sy;
      $rot ++;
    }
  }

  ### digits to: "$x,$y"

  $rot &= 3;
  $x = $frac * $rot_to_sx[$rot] + $x;
  $y = $frac * $rot_to_sy[$rot] + $y;

  ### final with frac: "$x,$y"
  return ($x,$y);
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
  ### CCurve xy_to_n(): "$x, $y"

  $x = _round_nearest($x);
  $y = _round_nearest($y);

  # max(|x|,|y|), or maybe hypot, or ...
  my ($power,$level_limit) = _round_down_pow (abs($x)+abs($y),
                                             2);
  $level_limit = 2*$level_limit + 6;
  if (_is_infinite($level_limit)) {
    return $level_limit;  # infinity
  }

  my @hypot = (5);
 OUTER: for (my $top = 0; $top < $level_limit; $top++) {
    push @hypot, ($top % 4 ? 2 : 3) * $hypot[$top];  # little faster than 2^lev

    my @digits = (((0) x $top), 1);
    my $i = $top;
    for (;;) {
      my $n = 0;
      foreach my $digit (reverse @digits) { # high to low
        $n = 2*$n + $digit;
      }
      ### consider: "i=$i  digits=".join(',',reverse @digits)."  is n=$n"

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
            next OUTER;
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
  ### not found below level limit
  return undef;
}

# f = (1 - 1/sqrt(2) = .292
# 1/f = 3.41
# N = 2^level
# Rend = sqrt(2)^level
# Rmin = Rend / 2  maybe
# Rmin^2 = (2^level)/4
# N = 4 * Rmin^2
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageCCurve rect_to_n_range(): "$x1,$y1  $x2,$y2"
  $x1 = abs($x1);
  $x2 = abs($x2);
  $y1 = abs($y1);
  $y2 = abs($y2);
  my $xmax = int($x1 > $x2 ? $x1 : $x2);
  my $ymax = int($y1 > $y2 ? $y1 : $y2);
  return (0,
          ($xmax*$xmax + $ymax*$ymax + 1) * 7);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageCCurve -- Levy C curve

=head1 SYNOPSIS

 use Math::PlanePath::MathImageCCurve;
 my $path = Math::PlanePath::MathImageCCurve->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is ...


                            11-----10-----9/7-----6------5
                             |             |             |
                     13-----12             8             4------3
                      |                                         |
              19---14/18----17                                  2
               |      |      |                                  |
       21-----20     15-----16                           0------1
        |
       22
        |
      25/23---24
        |
       26     35-----34-----33
        |      |             |
      27/37--28/36          32
        |      |             |
       38     29-----30-----31
        |
    39/41-----40
        |
       42                                              ...
        |                                                |
       43-----44     49-----48                          64-----63
               |      |      |                                  |
              45---46/50----47                                 62
                      |                                         |
                     51-----52            56            60-----61
                             |             |             |
                            53-----54----55/57---58-----59

                                                         ^
       -7     -6     -5     -4     -3     -2     -1     X=0     1

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageCCurve-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  If there's nothing at
C<$x,$y> then return C<undef>.

The curve visits an C<$x,$y> twice for various points (all the "inside"
points).  In the current code the smaller of the two N values is returned.
Is that the best way?

=item C<$n = $path-E<gt>n_start()>

Return 0, the first N in the path.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::DragonCurve>,
L<Math::PlanePath::ComplexMinus>

=cut

# Local variables:
# compile-command: "math-image --path=MathImageCCurve --lines --scale=20"
# End:
#
# math-image --path=MathImageCCurve --output=numbers_dash
