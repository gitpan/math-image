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

package App::MathImage::Values::SophieGermainPrimes;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 33;

use constant name => __('Sophie Germain Primes');
use constant description => __('The Sophie Germain primes 3,5,7,11,23,29, being primes where 2*P+1 is also prime (those being the "safe" primes).');

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  my $safe_primes = $options{'safe_primes'};
  $lo = max (0, $lo);

  my @array;
  if ($hi >= $lo) {
    my $primes_hi = 2*$hi+1;
    require Math::Prime::XS;
    Math::Prime::XS->VERSION (0.021); # version 0.21 for various fixes
    ### SophieGermainPrimes: "array $lo to $primes_hi"
    @array = Math::Prime::XS::sieve_primes ($lo, $primes_hi);

    my $to = 0;
    my $i = 0;
    my $p = $i;
  FILTER: for (;; $i++) {
      last if ($i > $#array);
      my $prime = $array[$i];
      last if $prime > $hi;

      my $target = 2*$prime+1;
      for (;;) {
        if ($p <= $#array) {
          if ($prime == 964049) {
            print "found $target with p=$p is $array[$p]\n";
          }
          if ($array[$p] < $target) {
            if ($prime == 964049) {
              print "p++\n";
            }
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
  }
  return bless { array => \@array,
                 i     => 0,
               }, $class;
}

1;
__END__
