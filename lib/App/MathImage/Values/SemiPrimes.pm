# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::SemiPrimes;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 29;

use constant name => __('Semi-Primes');
use constant description => __('The semi-primes, or bi-primes, 4, 6, 9, 10, 14 15, etc, being numbers with just two prime factors P*Q, including P==Q squares of primes.');

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max ($lo, 3);  # start from 3

  my @array;
  if ($hi >= $lo) {
    my $prime_base = ($options{'odd_only'} ? 3 : 2);
    my $primes_lo = $prime_base;
    my $primes_hi = int($hi/$prime_base);

    require Bit::Vector;
    my $vec = Bit::Vector->new($hi+1);

    require Math::Prime::XS;
    Math::Prime::XS->VERSION (0.022); # version 0.22 for lo==hi
    my @primes = Math::Prime::XS::sieve_primes ($primes_lo, $primes_hi);
    ### @primes

    foreach my $i (0 .. $#primes) {
      my $p1 = $primes[$i];
      # $i==$j includes the prime squares
      foreach my $j ($i .. $#primes) {
        if ((my $prod = $p1 * $primes[$j]) <= $hi) {
          $vec->Bit_On($prod);
        } else {
          last;
        }
      }
    }
    @array = $vec->Index_List_Read;
    ### @array
  }
  return $class->SUPER::new (%options,
                             array => \@array);
}

1;
__END__
