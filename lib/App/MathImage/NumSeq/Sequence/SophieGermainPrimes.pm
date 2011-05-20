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

package App::MathImage::NumSeq::Sequence::SophieGermainPrimes;
use 5.004;
use strict;
use List::Util 'max';
use POSIX ();

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Array';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 57;


# cf. A007700 n,2n+1,4n+3 all primes

use constant name => __('Sophie Germain Primes');
use constant description => __('The Sophie Germain primes 3,5,7,11,23,29, being primes where 2*P+1 is also prime (those being the "safe" primes).');
use constant values_min => 3;
use constant oeis_anum => 'A005384';

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  my $safe_primes = $options{'safe_primes'};
  $lo = max (0, $lo);

  ### SophieGermainPrimes: "array $lo to ".(2*$hi+1)
  require App::MathImage::NumSeq::Sequence::Primes;
  my @array = App::MathImage::NumSeq::Sequence::Primes::_my_primes_list ($lo, 2*$hi+1);

  my $to = 0;
  my $p = 0;
  for (my $i = 0; $i < @array; $i++) {
    my $prime = $array[$i];
    last if $prime > $hi;

    my $target = 2*$prime+1;
    for (;;) {
      if ($p <= $#array) {
        if ($array[$p] < $target) {
          $p++;
          next;
        }
        if ($array[$p] == $target) {
          $array[$to++] = ($safe_primes ? 2*$prime+1 : $prime);
          $p++;
        }
      }
      last;
    }
  }
  $#array = $to - 1;
  return $class->SUPER::new (%options,
                             array => \@array,
                             i     => 0);
}

1;
__END__
