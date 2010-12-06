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

package App::MathImage::Values::TwinPrimes1;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use POSIX ();
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 36;

use constant name => __('Twin Primes, first of each');
use constant description => __('The first of each pair of twin primes, 3, 5, 11, 17, 29, etc.');
use constant oeis => 'A001359'; # less of two

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max ($lo, 3);

  my $offset = $options{'twin_offset'} || 0;  # for TwinPrimes2
  ### $lo
  ### $offset

  require App::MathImage::Values::Primes;
  my @array = App::MathImage::Values::Primes::_my_primes_list ($lo-2, $hi+2);

  my $to = 0;
  foreach my $i (0 .. $#array - 1) {
    if ($array[$i]+2 == $array[$i+1] && $array[$i + $offset] >= $lo) {
      $array[$to++] = $array[$i + $offset];
    }
  }
  $#array = $to - 1;
  ### @array

  return $class->SUPER::new (%options,
                             array => \@array);
}

1;
__END__
