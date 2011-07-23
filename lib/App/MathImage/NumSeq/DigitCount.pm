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

package App::MathImage::NumSeq::DigitCount;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IterateIth;
@ISA = ('App::MathImage::NumSeq::Base::IterateIth',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Digit Count');
use constant description => __('How many of a given digit in each number, in a given radix, for example how many 1 bits in binary.');
use constant values_min => 1;
use constant characteristic_count => 1;
use constant parameter_list =>
  ({ name        => 'radix',
     share_key   => 'radix-2',
     type        => 'integer',
     display     => __('Radix'),
     default     => 2,
     minimum     => 2,
     width       => 3,
     description => __('Radix, ie. base, for the values calculation.  Default is binary (base 2).'),
   },
   { name        => 'digit',
     type        => 'integer',
     share_key   => 'digit-1',
     display     => __('Digit'),
     default     => 1,
     minimum     => 0,
     width       => 2,
     description => __('Digit to count.'),
   },
  );

# cf A008687 - count 1s in twos-complement -n
# 
my @oeis;
BEGIN {
  $oeis[2]->[0] = 'A080791'; # base 2 count 0s
  # OEIS-Catalogue: A080791 radix=2 digit=0
  # cf A023416 treating "0" as a single digit zero

  $oeis[2]->[1] = 'A000120'; # base 2 count 1s
  # OEIS-Catalogue: A000120 radix=2 digit=1

  $oeis[10]->[9] = 'A102683'; # base 10 count 9s
  # OEIS-Catalogue: A102683 radix=10 digit=9
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
      if (($i & 1) == $digit) {
        $count++;
      }
      $i >>= 1;
    }
  } else {
    while ($i) {
      if (($i % $radix) == $digit) {
        $count++;
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

