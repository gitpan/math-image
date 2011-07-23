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


# separate modulus parameter ...


package App::MathImage::NumSeq::DigitProduct;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IterateIth;
@ISA = ('App::MathImage::NumSeq::Base::IterateIth',
        'App::MathImage::NumSeq');

use constant name => __('Digit Product');
use constant description => __('Product of the digits in the given radix.');
use constant values_min => 0;
use constant characteristic_count => 1;

use App::MathImage::NumSeq::Base::Digits;
use constant parameter_list => (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

my @oeis = (undef,
            undef,
            undef, # 2 binary
            undef, # 3 ternary
            undef, # 4
            undef, # 5
            undef, # 6
            undef, # 7
            undef, # 8
            undef, # 9

            # OEIS-Catalogue: A007954 radix=10
            'A007954', # 10 decimal
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}

sub ith {
  my ($self, $i) = @_;
  my $radix = $self->{'radix'};
  my $prod = ($i % $radix);
  for (;;) {
    $i = int($i/$radix) || last;
    ($prod *= ($i % $radix)) || last;
  }
  return $prod;
}

1;
__END__
