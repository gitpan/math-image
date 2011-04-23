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

package App::MathImage::NumSeq::Sequence::RepdigitAnyBase;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Array';

use vars '$VERSION';
$VERSION = 52;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Repdigits In Any Base');
use constant description => __('Numbers which are a "repdigit" like 1111, 222, 999 etc of 3 or more digits in some number base (Sloane\'s A167782).');
use constant values_min => 1;
use constant oeis_anum => 'A167782';

# b^2 + b + 1 = k
# b^2+b+0.5 = k-0.5
# (b+0.5)^2 = (k-0.5)
# b = sqrt(k-0.5)-0.5;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  ### bases to: 2+int(sqrt($hi-0.5))
  my %ret = (0 => 1); # zero considered 000...
  foreach my $base (2 .. 1+int(sqrt($hi-0.5))) {
    my $n = ($base + 1) * $base + 1;
    while ($n <= $hi) {
      $ret{$n} = 1;
      foreach my $digit (2 .. $base-1) {
        if ((my $mult = $digit * $n) <= $hi) {
          $ret{$mult} = 1;
        }
      }
      $n = $n * $base + 1;
    }
  }
  return $class->SUPER::new (%options,
                             array => [ sort {$a <=> $b} keys %ret ]);
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