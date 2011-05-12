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

package App::MathImage::NumSeq::Sequence::TwinPrimes;
use 5.004;
use strict;
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Array';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 56;

use constant name => __('Twin Primes');
use constant description => __('The twin primes, 3, 5, 7, 11, 13, being numbers where both K and K+2 are primes.');
use constant values_min => 3;
use constant parameter_list => (App::MathImage::NumSeq::Sequence->parameter_common_pairs);

my %oeis = (first  => 'A001359',
            second => 'A006512',
            both   => 'A001097', # both, without repetition
            #         'A077800'  # both, with repetition
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $pairs = (ref $class_or_self
               ? $class_or_self->{'pairs'}
               : $class_or_self->parameter_default('pairs'));
  return $oeis{$pairs};
}
# OeisCatalogue: A001359 pairs=first
# OeisCatalogue: A006512 pairs=second,
# OeisCatalogue: A001097 pairs=both
# cf A077800 both, with repetition

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max ($lo, 3);  # start from 3
  my $pairs = $options{'pairs'} || $class->parameter_default('pairs');

  my $primes_lo = $lo - ($pairs eq 'second' ? 2 : 0);
  require App::MathImage::NumSeq::Sequence::Primes;
  my @array = App::MathImage::NumSeq::Sequence::Primes::_my_primes_list
    ($primes_lo, $hi+2);

  my $to = 0;
  my $offset = ($pairs eq 'second');
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
        $array[$to++] = $array[$i+$offset];
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
