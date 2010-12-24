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

package App::MathImage::Values::TwinPrimes;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 37;

use constant name => __('Twin Primes');
use constant description => __('The twin primes, 3, 5, 7, 11, 13, being numbers where both K and K+2 are primes.');
use constant oeis => 'A001097'; # both, without repetition
# use constant oeis => 'A077800'; # both, with repetition

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max ($lo, 3);  # start from 3

  require App::MathImage::Values::Primes;
  my @array = App::MathImage::Values::Primes::_my_primes_list ($lo-2, $hi+2);

  my $to = 0;
  for (my $i = 0; $i < $#array; $i++) {
    if ($array[$i]+2 == $array[$i+1]) {
      $array[$to++] = $array[$i];  # first of pair
      while (++$i < $#array && $array[$i]+2 == $array[$i+1]) {
        $array[$to++] = $array[$i];  # run of consecutive twin array
      }
      $array[$to++] = $array[$i];  # second of pair
    }
  }
  $#array = $to - 1;

  return $class->SUPER::new (%options,
                             array => \@array);
}

1;
__END__
