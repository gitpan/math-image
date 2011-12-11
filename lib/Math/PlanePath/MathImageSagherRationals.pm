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


# prime factors q1,..qk of n
# f(m/n) = m^2*n^2/ (q1q2...qk)


# http://blog.computationalcomplexity.org/2004/03/counting-rationals-quickly.html
# cf
#
# Let p(i,j) = i + j(j-1)/2. The function p is an easily computable and
# invertible bijection from pairs (i,j) with 1<=i<=j to the positive
# integers. We define our 1-1 mapping from the positive integers to the
# positive rationals by the following algorithm.
# 
#    1. Input: n
#    2. Find i and j such that n = p(i,j).
#    3. Let g = gcd(i,j) (easily computable via Euclid's algorithm)
#    4. Let u = i/g and v=j/g.
#    5. Output: g-1+u/v 
# 
# Since 1<=i<=j we have 1<=u<=v making the output unique and the function easily
# invertible.



package Math::PlanePath::MathImageSagherRationals;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 84;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant x_negative => 0;
use constant y_negative => 0;
use constant n_start => 1;

sub n_to_xy {
  my ($self, $n) = @_;
  ### SagherRationals n_to_xy(): "$n"

  if ($n < 1) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  # FIXME: what to do for fractional $n?
  {
    my $int = int($n);
    if ($n != $int) {
      ### frac ...
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      ### x1,y1: "$x1, $y1"
      ### x2,y2: "$x2, $y2"
      ### dx,dy: "$dx, $dy"
      ### result: ($frac*$dx + $x1).', '.($frac*$dy + $y1)
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;
  }

  my $x = my $y = ($n * 0) + 1;  # inherit bignum 1
  my $prime = 2;
  my $limit = int(sqrt($n));

  while ($prime <= $limit) {
    if (($n % $prime) == 0) {
      my $count = 0;
      for (;;) {
        $count++;
        $n /= $prime;
        if ($n % $prime) {
          ### odd, denominator ...
          $y *= $prime ** $count;
          last;
        }
        $n /= $prime;
        if ($n % $prime) {
          ### even, numerator ...
          $x *= $prime ** $count;
          last;
        }
      }
      $limit = int(sqrt($n));
    }
    $prime += 1 + ($prime&1);
  }
  return ($x, $y*$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### SagherRationals xy_to_n(): "$x,$y"

  if (_is_infinite($x)) {  # ($x == 0 && $y == 0)
    return $x;
  }
  if (_is_infinite($y)) {
    return $y;
  }
  if ($x < 1 || $y < 1) {
    return undef;
  }

  my $prime = 2;
  my $n = 1;
  my $limit = int(sqrt(_max($x,$y)));
  while ($prime <= $limit) {
    if (($x % $prime) == 0) {
      ### numerator: $prime
      if (($y % $prime) == 0) {
        return undef; # common factor $prime
      }
      my $p2 = $prime*$prime;
      do {
        $x /= $prime;
        $n *= $p2;
      } until ($x % $prime);
      $limit = int(sqrt(_max($x,$y)));
    } elsif (($y % $prime) == 0) {
      ### denominator: $prime
      $n *= $prime;
      $y /= $prime;
      unless ($y % $prime) {
        my $p2 = $prime*$prime;
        do {
          $y /= $prime;
          $n *= $p2;
        } until ($y % $prime);
      }
      $limit = int(sqrt(_max($x,$y)));
    }
    $prime += 1 + ($prime&1);
  }

  if ($x > 1 && $x == $y) {
    return undef;
  }
  # $x and $y now primes
  ### final: "n=$n x=$x y=$y"

  return $n * $x*$x*$y;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  return (1,
          $x2*$y2*_max($x2,$y2));
}

1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageSagherRationals -- rationals by prime factorization

=head1 SYNOPSIS

 use Math::PlanePath::MathImageSagherRationals;
 my $path = Math::PlanePath::MathImageSagherRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates rationals X/Y with no common factor using a method by
Yoram Sagher based on the prime factors in numerator and denominator.

    15  |      15   60       240            735  960           1815      
    14  |      14       126       350                1134      1694      
    13  |      13   52  117  208  325  468  637  832 1053 1300 1573 1872 
    12  |      24                 600      1176                2904      
    11  |      11   44   99  176  275  396  539  704  891 1100      1584 
    10  |      10        90                 490       810      1210      
     9  |      27  108       432  675      1323 1728      2700 3267      
     8  |      32       288       800      1568      2592      3872
     7  |       7   28   63  112  175  252       448  567  700  847 1008 
     6  |       6                 150       294                 726      
     5  |       5   20   45   80       180  245  320  405       605  720 
     4  |       8        72       200       392       648       968      
     3  |       3   12        48   75       147  192       300  363      
     2  |       2        18        50        98       162       242      
     1  |       1    4    9   16   25   36   49   64   81  100  121  144 
    Y=0 |
         ---------------------------------------------------------------
          X=0   1    2    3    4    5    6    7    8    9   10   11   12

Since X and Y have no common factor, a prime p appears in the factorization
of X or Y but not both.  If X has p^k then it's represented in N as p^2k, or
if Y has p^k then in N as p^(2k-1).  In N the odd/evenness of the power of p
indicates whether it belongs in the numerator or denominator, and halving is
the power there.  This is a one-to-one mapping between rationals X/Y and
integers N.

Fractions 1/K are at X=1,Y=K in the left column at X=1.  Primes 1/P are
there as N=P directly, or 1/P^2 as N=P^3, and in general 1/P^k as
N==P^(2k-1).  So the N values in that column are the primes and all integers
whose prime factors all have odd powers.

Integer primes P/1 are in the bottom row at Y=1, as X=P^2,Y=1.  In general
any X/1 is N=X^2, so that row is all the perfect squares.

=head1 OEIS

This path is in Sloane's Online Encyclopedia of Integer Sequences in the
following forms

    http://oeis.org/A071974   (etc)

    A071974 - numerators
    A071975 - denominators
    A060837 - permutation Cantor diagonal -> Sagher
    A071970 - permutation CW/Stern -> Sagher

A071970 takes fractions in the Stern diatomic sequence stern[i]/stern[i+1],
which is the order of the Calkin-Wilf tree read by rows (see
L<Math::PlanePath::RationalsTree/Calkin-Wilf Tree>).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over

=item C<$path = Math::PlanePath::MathImageSagherRationals-E<gt>new ()>

Create and return a new path object.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>

=cut


# Local variables:
# compile-command: "math-image --path=MathImageSagherRationals --all --scale=10"
# End:
#
# math-image --path=MathImageSagherRationals --all --output=numbers
