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


# David M. Bradley http://arxiv.org/abs/math/0509025
# 19 Yoram Sagher, Counting the rationals, AMM 1989
#
# earlier inverse
# 6 Gerald Freilich, A denumerability formula for the rationals AMM 1965
#
# prime powers
# 17 Kevin McCrimmon, Enumeration of the positive rationals AMM 1960
#
# prime factors q1,..qk of n
# f(m/n) = m^2*n^2/ (q1q2...qk)
#
# http://blog.computationalcomplexity.org/2004/03/counting-rationals-quickly.html


package Math::PlanePath::MathImagePowerRationals;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 85;

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
  ### PowerRationals n_to_xy(): "$n"

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
  my ($limit,$overflow) = _limit($n);
  ### $limit

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
      ($limit,$overflow) = _limit($n);
      ### $limit
    }
    $prime += 1 + ($prime&1);
  }
  if ($overflow) {
    ### n too big ...
    return;
  }
  return ($x, $y*$n);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  ### PowerRationals xy_to_n(): "$x,$y"

  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }

  if ($x < 1 || $y < 1 || ! _coprime($x,$y)) {
    return undef;
  }

  my $ychop = my $ymult = $y;
  unless ($ychop % 2) {
    $ymult /= 2;
    do {
      $ychop /= 2;
    } until ($ychop % 2);
  }
  my ($limit,$overflow) = _limit($ychop);
  for (my $prime = 3; $prime <= $limit; $prime += 2) {
    unless ($ychop % $prime) {
      $ymult /= $prime;
      do {
        $ychop /= $prime;
      } until ($ychop % $prime);
      ($limit,$overflow) = _limit($ychop);
    }
  }
  if ($overflow) {
    return undef; # too big
  }

  $ymult /= $ychop; # remainder is a prime
  return $x*$x * $y*$ymult;
}

sub _limit {
  my ($n) = @_;
  my $limit = int(sqrt($n));
  my $cap = _max (int(65536 * 10 / length($n)),
                  50);
  if ($limit > $cap) {
    return ($cap, 1);
  } else {
    return ($limit, 0);
  }
}

# X=2^10 -> N=2^20 is X*X
# Y=3 -> N=3
# Y=3^2 -> N=3^3
# Y=3^3 -> N=3^5
# Y=3^4 -> N=3^7
# Y*Y / distinct prime factors

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
          $x2*$x2 * $y2*$y2);
}

#------------------------------------------------------------------------------
# shared

sub _coprime {
  my ($x, $y) = @_;
  #### _coprime(): "$x,$y"
  if ($y > $x) {
    if ($x == 1) {
      ### result yes ...
      return 1;
    }
    $y %= $x;
  }
  for (;;) {
    if ($y <= 1) {
      ### result: ($y == 1)
      return ($y == 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

1;
__END__

=for stopwords eg Ryde OEIS ie Math-PlanePath Calkin-Wilf PowerRationals

=head1 NAME

Math::PlanePath::MathImagePowerRationals -- rationals by prime powers

=head1 SYNOPSIS

 use Math::PlanePath::MathImagePowerRationals;
 my $path = Math::PlanePath::MathImagePowerRationals->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path enumerates rationals X/Y, with no common factor, based on the
prime powers in numerator and denominator.  This idea might have been first
by Kevin McCrimmon and independently (was it?) by Gerald Freilich in reverse
and then Yoram Sagher.

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

An X,Y is mapped to N by

             X^2 * Y^2
    N = --------------------
        distinct primes in Y

The effect is to distinguish primes coming from the numerator or denominator
by making odd or even powers in N.

In a rational X/Y each prime p has an exponent p^s with s positive or
negative.  Positive is in the numerator X, negative in the denominator Y.
This is turned into a power p^k in N,

    k = /  2*s      if s >= 0
        \  1-2*s    if s < 0

This maps a signed exponent s to a positive exponent k,

     s          k
    -1    ->    1
     1    ->    2
    -2    ->    3
     2    ->    4
    etc

For example (and other primes multiply in similarly),

   N=3   ->  3^-1 = 1/3
   N=9   ->  3^1  = 3/1
   N=27  ->  3^-2 = 1/9
   N=81  ->  3^2  = 9/1

Thinking in terms of X and Y values the key is that since X and Y have no
common factor a prime p appears in the factorization of X or Y but not both.
The oddness/evenness of the p^k exponent in N can then encode which of the
two it appears in.

=head2 Values

The leftmost column X=1,Y=K is the square-free integers N.  That column is
the fractions 1/K so the s exponents of the primes there are all negative
and thus all exponents in N are odd, so N is square-free.

The bottom row X=K,Y=1 is the perfect squares.  That row is the integers K/1
so the s exponents there are all positive and thus in N become 2*s, giving
simply N=K^2.

As noted by David M. Bradley other mappings of signed E<lt>-E<gt> unsigned
powers could give other enumerations.  The alternate + and - as done here
keeps the growth of N down to X^2*Y^2 or thereabouts per the first N
formula.

=head1 OEIS

This enumeration of the rationals is in Sloane's Online Encyclopedia of
Integer Sequences in the following forms

    http://oeis.org/A071974   (etc)

    A071974 - numerators
    A071975 - denominators
    A060837 - permutation DiagonalRationals -> PowerRationals
    A071970 - permutation Stern/CW -> PowerRationals

The last A071970 is rationals taken in order of the Stern diatomic sequence
stern[i]/stern[i+1], which is the order of the Calkin-Wilf tree rows (see
L<Math::PlanePath::RationalsTree/Calkin-Wilf Tree>).

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over

=item C<$path = Math::PlanePath::MathImagePowerRationals-E<gt>new ()>

Create and return a new path object.

=back

=head1 BUGS

C<n_to_xy()> depends on factorizing C<$n> and C<xy_to_n()> depends on
factorizing C<$y>.  In the current code there's a limit on the amount of
factorizing attempted and above that the return is empty or C<undef>
(respectively).  Anything up to 2^32 is handled, and numbers bigger than
that entirely comprised of small factors, but not big numbers with big
factors.

Is this a good idea?  For large inputs there's no value disappearing into a
nearly-infinite loop.  But perhaps the limits could be configurable and/or
some factoring modules tried for a while if/when available.

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::GcdRationals>,
L<Math::PlanePath::RationalsTree>,
L<Math::PlanePath::CoprimeColumns>

David M. Bradley, "Counting the Positive Rationals: A Brief Survey",

    http://arxiv.org/abs/math/0509025

=cut


# Local variables:
# compile-command: "math-image --path=MathImagePowerRationals --all --scale=10"
# End:
#
# math-image --path=MathImagePowerRationals --all --output=numbers
