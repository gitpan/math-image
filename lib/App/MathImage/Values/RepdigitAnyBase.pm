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

package App::MathImage::Values::RepdigitAnyBase;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

use vars '$VERSION';
$VERSION = 40;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Repdigits In Any Base');
use constant description => __('Numbers which are a "repdigit" like 1111, 222, 999 etc of 3 or more digits in some number base (Sloane\'s A167782).');
use constant oeis => 'A053696';

# b^2 + b + 1 = k
# b^2+b+0.5 = k-0.5
# (b+0.5)^2 = (k-0.5)
# b = sqrt(k-0.5)-0.5;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  my %ret;
  foreach my $base (2 .. 1+int(sqrt($hi-0.5))) {
    my $n = ($base + 1) * $base + 1;
    while ($n <= $hi) {
      $ret{$n} = 1;
      foreach my $digit (2 .. $base-1) {
        if ((my $mult = $digit * $n) < $hi) {
          $ret{$mult} = 1;
        }
      }
      $n = $n * $base + 1;
    }
  }
  return bless { %options,
                 array => [ sort {$a <=> $b} keys %ret ],
               }, $class;
}

1;
__END__

  #   require Math::Prime::XS;
  #   my @upto;
  #   my $i = 1;
  #   my @primes = Math::Prime::XS::sieve_primes ($maxbase);
  #   return sub {
  #     for (;;) {
  #       $i++;
  #       my $base_limit = 1+int(sqrt($i/2));
  #       foreach my $base (@primes) {
  #         last if ($base > $base_limit);
  #         foreach my $digit (@primes) {
  #           last if ($digit >= $base);
  #           my $ref = \$upto[$base]->[$digit];
  #           $$ref ||= (($base * $digit) + $digit) * $base + $digit;
  #           while ($$ref < $i) {
  #             $$ref = $$ref * $base + $digit;
  #           }
  #           if ($$ref == $i) {
  #             return $i;
  #           }
  #         }
  #       }
  #     }
  #   };
