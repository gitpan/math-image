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

package App::MathImage::NumSeq::DigitCountLow;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 70;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Digit Count Low');
use constant description => Math::NumSeq::__('How many of a given digit at the low end of a number, in a given radix.');
use constant values_min => 1;
use constant characteristic_monotonic => 0;
use constant characteristic_count => 1;

use Math::NumSeq::DigitCount 4;
*parameter_info_array = \&Math::NumSeq::DigitCount::parameter_info_array;

# cf A006519 - highest k s.t. 2^k+1 divides n
#
my @oeis;
BEGIN {
  $oeis[2]->[0] = 'A007814'; # base 2 low 0s
  # OEIS-Catalogue: A102683 radix=2 digit=0
  # cf A001511 low 0s in 2*n, ie +1
  # cf A070940 low 0s pos counting from the left

  $oeis[3]->[0] = 'A007949'; # base 3 low 0s
  # OEIS-Catalogue: A007949 radix=3 digit=0
  # cf A051064 low 0s of 3*n in ternary, ie +1

  $oeis[5]->[0] = 'A112765'; # base 5 low 0s
  # OEIS-Catalogue: A112765 radix=5 digit=0

  $oeis[6]->[0] = 'A122841'; # base 6 low 0s
  # OEIS-Catalogue: A122841 radix=6 digit=0

  $oeis[10]->[0] = 'A122840'; # base 10 low 0s
  # OEIS-Catalogue: A122840 radix=10 digit=0
  # cf A160094 low zeros in 10 counting from the right from 1
  # cf A160093 low zeros in 10 counting from the left
}
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  my $digit = (ref $class_or_self
               ? $class_or_self->{'digit'}
               : $class_or_self->parameter_default('digit'));
  return $oeis[$radix]->[$digit];
}

sub ith {
  my ($self, $i) = @_;
  $i = abs($i);
  if ($i == $i-1) {
    return $i;  # don't loop forever if $i is +infinity
  }
  my $digit = $self->{'digit'};
  my $radix = $self->{'radix'};
  my $count = 0;
  if ($radix == 2) {
    while ($i) {
      last unless (($i & 1) == $digit);
      $count++;
      $i >>= 1;
    }
  } else {
    while ($i) {
      last unless (($i % $radix) == $digit);
      $count++;
      $i = int($i/$radix);
    }
  }
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__

