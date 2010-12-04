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

package App::MathImage::Values::Primes;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

use vars '$VERSION';
$VERSION = 35;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Prime Numbers');
use constant description => __('The prime numbers 2, 3, 5, 7, 11, 13, 17, etc.');
use constant oeis => 'A000040';

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max (0, $lo);
  ### Primes: "$lo to $hi"

  my @array;
  if ($hi >= $lo) {
    require Math::Prime::XS;
    Math::Prime::XS->VERSION (0.022); # version 0.22 for lo==hi
    @array = Math::Prime::XS::sieve_primes ($lo, $hi);
  }
  return bless { %options,
                 array => \@array,
               }, $class;
}

1;
__END__
