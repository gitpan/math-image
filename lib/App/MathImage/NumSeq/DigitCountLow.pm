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
$VERSION = 79;

use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant name => Math::NumSeq::__('Digit Count Low');
use constant description => Math::NumSeq::__('How many of a given digit at the low end of a number, in a given radix.');
use constant values_min => 0;
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;

use Math::NumSeq::DigitCount 4;
*parameter_info_array = \&Math::NumSeq::DigitCount::parameter_info_array;

# cf A006519 - highest k s.t. 2^k+1 divides n
#
my @oeis_anum;
BEGIN {
  # starts from i=1
  # $oeis_anum[2]->[0] = 'A007814'; # base 2 low 0s
  # # OEIS-Catalogue: A007814 radix=2 digit=0
  # # cf A001511 low 0s in 2*n, ie +1
  # # cf A070940 low 0s pos counting from the left

  # starts from i=1
  # $oeis_anum[3]->[0] = 'A007949'; # base 3 low 0s
  # # OEIS-Catalogue: A007949 radix=3 digit=0
  # # cf A051064 low 0s of 3*n in ternary, ie +1

  # starts from i=1
  # $oeis_anum[5]->[0] = 'A112765'; # base 5 low 0s
  # # OEIS-Catalogue: A112765 radix=5 digit=0

  # starts from i=1
  # $oeis_anum[6]->[0] = 'A122841'; # base 6 low 0s
  # # OEIS-Catalogue: A122841 radix=6 digit=0

  # starts from i=1
  # $oeis_anum[10]->[0] = 'A122840'; # base 10 low 0s
  # # OEIS-Catalogue: A122840 radix=10 digit=0
  # # cf A160094 low zeros in 10 counting from the right from 1
  # # cf A160093 low zeros in 10 counting from the left
}
sub oeis_anum {
  my ($self) = @_;
  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  if ($digit == -1) {
    $digit = $radix-1;
  }
  return $oeis_anum[$radix]->[$digit];
}

sub ith {
  my ($self, $i) = @_;
  ### DigitCountLow ith(): $i

  $i = abs($i);
  if (_is_infinite($i)) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  if ($digit == -1) { $digit = $radix - 1; }

  my $count = 0;
  if ($radix == 2) {
    ### binary ...
    while ($i) {
      last unless (($i & 1) == $digit);
      $count++;
      $i >>= 1;
    }
  } else {
    ### general radix: $radix
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
