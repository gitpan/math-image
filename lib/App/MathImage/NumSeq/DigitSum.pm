# Copyright 2011 Kevin Ryde

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

package App::MathImage::NumSeq::DigitSum;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 66;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

use constant name => Math::NumSeq::__('Digit Sum');
use constant description => Math::NumSeq::__('Sum of the digits in the given radix.  For binary this is how many 1 bits.');
use constant values_min => 0;
use constant characteristic_monotonic => 0;
use constant characteristic_smaller => 1;

use Math::NumSeq::Base::Digits;
use constant parameter_info_array =>
  [ Math::NumSeq::Base::Digits::parameter_common_radix() ];

my @oeis = (undef,
            undef,
            'A000120', # 2 binary, number of 1s, cf DigitCount

            'A053735', # 3 ternary
            # OEIS-Catalogue: A053735 radix=3

            'A053737', # 4
            # OEIS-Catalogue: A053737 radix=4

            'A053824', # 5
            # OEIS-Catalogue: A053824 radix=5

            'A053827', # 6
            # OEIS-Catalogue: A053827 radix=6

            'A053828', # 7
            # OEIS-Catalogue: A053828 radix=7

            'A053829', # 8
            # OEIS-Catalogue: A053829 radix=8

            'A053830', # 9
            # OEIS-Catalogue: A053830 radix=9

            'A007953', # 10 decimal
            # OEIS-Catalogue: A007953 radix=10

            'A053831', # 11
            # OEIS-Catalogue: A053831 radix=11

            'A053832', # 12
            # OEIS-Catalogue: A053832 radix=12

            'A053833', # 13
            # OEIS-Catalogue: A053833 radix=13

            'A053834', # 14
            # OEIS-Catalogue: A053834 radix=14

            'A053835', # 15
            # OEIS-Catalogue: A053835 radix=15

            'A053836', # 16
            # OEIS-Catalogue: A053836 radix=16
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}


# uncomment this to run the ### lines
#use Smart::Comments;

# ENHANCE-ME:
# next() is +1 mod m, except when xx09 wraps to xx10 which is +2,
# or when x099 to x100 then +3, etc extra is how many low 9s
#
# sub next {
#   my ($self) = @_;
#   my $radix = $self->{'radix'};
#   my $sum = $self->{'sum'} + 1;
#   if (++$self->{'digits'}->[0] >= $radix) {
#     $self->{'digits'}->[0] = 0;
#     my $i = 1;
#     for (;;) {
#       $sum++;
#       if (++$self->{'digits'}->[$i] < $radix) {
#         last;
#       }
#     }
#   }
#   return ($self->{'i'}++, ($self->{'sum'} = ($sum % $radix)));
# }
  
sub ith {
  my ($self, $i) = @_;
  my $radix = $self->{'radix'};
  my $sum = 0;
  while ($i) {
    $sum += ($i % $radix);
    $i = int($i/$radix)
  }
  return $sum;
}

1;
__END__
