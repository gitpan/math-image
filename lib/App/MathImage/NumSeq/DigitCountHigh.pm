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

package App::MathImage::NumSeq::DigitCountHigh;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 78;

use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant name => Math::NumSeq::__('Digit Count High');
use constant description => Math::NumSeq::__('How many of a given digit at the high end of a number, in a given radix.');
use constant values_min => 0;
use constant characteristic_monotonic => 0;
use constant characteristic_count => 1;

use Math::NumSeq::DigitCount 4;
*parameter_info_array = \&Math::NumSeq::DigitCount::parameter_info_array;

# cf
# 
my @oeis_anum;

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
  $i = abs($i);
  if (_is_infinite($i)) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  if ($digit == -1) { $digit = $radix - 1; }

  my $count = 0;
  if ($radix == 2) {
    while ($i) {
      if (($i & 1) == $digit) {
        $count++;
      } else {
        $count = 0;
      }
      $i >>= 1;
    }
  } else {
    while ($i) {
      if (($i % $radix) == $digit) {
        $count++;
      } else {
        $count = 0;
      }
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

