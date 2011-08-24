# Copyright 2010, 2011 Kevin Ryde

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

package App::MathImage::NumSeq::Primes;
use 5.004;
use strict;
use List::Util 'min', 'max';
use POSIX ();

use Math::NumSeq;
use base 'Math::NumSeq::Base::Array';

use vars '$VERSION';
$VERSION = 68;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Prime Numbers');
use constant description => Math::NumSeq::__('The prime numbers 2, 3, 5, 7, 11, 13, 17, etc.');
use constant characteristic_monotonic => 2;
use constant values_min => 2;

# cf A010051 - boolean 0 or 1 according as N is prime
#                      A051006 binary fraction, in decimal
#                      A051007 binary fraction, continued fraction
#    A000720 - pi(n) num primes <= n
#
use constant oeis_anum => 'A000040'; # primes

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  my @array = _my_primes_list ($lo, $hi);
  return $class->SUPER::new (%options,
                             array => \@array);
}

use constant MAX_PRIME_XS => POSIX::UINT_MAX() / 2;

sub _my_primes_list {
  my ($lo, $hi) = @_;
  ### _my_primes_list: "$lo to $hi"
  $lo = max (0, $lo);
  $hi = min ($hi, MAX_PRIME_XS);

  if ($hi < $lo) {
    # Math::Prime::XS errors out if hi<lo
    return;
  }

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.23); # version 0.23 fix 1928099
  return Math::Prime::XS::sieve_primes ($lo, $hi);
}

sub pred {
  my ($self, $value) = @_;
  return Math::Prime::XS::is_prime($value);
}

# sub ith {
#   my ($self, $i) = @_;
#   my $array = $self->{'array'};
#   if ($i > $#$array) {
#     my $hi = int ($i/log($i) * 2 + 5);
#     do {
#       $array = $self->{'array'} = [ undef, _my_primes_list (0, $hi) ];
#       $hi *= 2;
#     } while ($i > $#$array);
#   }
#   return $array->[$i];
# }

1;
__END__
