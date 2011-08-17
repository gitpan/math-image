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

package App::MathImage::NumSeq::TwinPrimes;
use 5.004;
use strict;
use List::Util 'min', 'max';

use Math::NumSeq;
use base 'Math::NumSeq::Base::Array';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 67;

use constant name => Math::NumSeq::__('Twin Primes');
use constant description => Math::NumSeq::__('The twin primes, 3, 5, 7, 11, 13, being numbers where both K and K+2 are primes.');
use constant values_min => 3;
use constant characteristic_monotonic => 2;
use constant parameter_info_array => [ { name    => 'pairs',
                                         display => Math::NumSeq::__('Pairs'),
                                         type    => 'enum',
                                         default => 'first',
                                         choices => ['first','second','both','average'],
                                         choices_display => [Math::NumSeq::__('First'),
                                                             Math::NumSeq::__('Second'),
                                                             Math::NumSeq::__('Both'),
                                                             Math::NumSeq::__('Average')],
                                         description => Math::NumSeq::__('Which of a pair of values to show.'),
                                       } ];

my %oeis = (
            # OEIS-Catalogue: A001359 pairs=first
            first  => 'A001359',

            # OEIS-Catalogue: A006512 pairs=second,
            second => 'A006512',

            # OEIS-Catalogue: A001097 pairs=both
            both   => 'A001097', # both, without repetition

            # OEIS-Catalogue: A014574 pairs=average
            average => 'A014574', # average

            # cf A077800 both, with repetition
            #      cf 'A077800'  # both, with repetition
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $pairs = (ref $class_or_self
               ? $class_or_self->{'pairs'}
               : $class_or_self->parameter_default('pairs'));
  return $oeis{$pairs};
}

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max ($lo, 3);  # start from 3
  my $pairs = $options{'pairs'} || $class->parameter_default('pairs');

  my $primes_lo = $lo - ($pairs eq 'second' ? 2 : 0);
  require App::MathImage::NumSeq::Primes;
  my @array = App::MathImage::NumSeq::Primes::_my_primes_list
    ($primes_lo, $hi+2);

  my $to = 0;
  my $offset = ($pairs eq 'second');
  my $inc = ($pairs eq 'average');
  ### $pairs
  ### $offset

  for (my $i = 0; $i < $#array; $i++) {
    if ($array[$i]+2 == $array[$i+1]) {
      if ($pairs eq 'both') {
        $array[$to++] = $array[$i];  # first of pair
        do {
          $array[$to++] = $array[++$i];
        } while ($i < $#array && $array[$i]+2 == $array[$i+1]);
      } else {
        $array[$to++] = $array[$i+$offset] + $inc;
      }
    }
  }
  while ($to > 0 && $array[$to-1] > $hi) {
    $to--;
  }
  $#array = $to - 1;

  return $class->SUPER::new (%options,
                             array => \@array);
}

1;
__END__
