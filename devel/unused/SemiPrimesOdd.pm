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

package App::MathImage::Values::SemiPrimesOdd;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values::SemiPrimes';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 28;

use constant name => __('Semi-Primes, Odd');
use constant description => __('The odd semi-primes, or bi-primes, 9, 15, 21, etc, being odd numbers with just two prime factors P*Q, including P==Q squares of primes.');

sub new {
  my ($class, %options) = @_;
  return $class->SUPER::new (%options,
                             odd_only => 1);
}

1;
__END__
