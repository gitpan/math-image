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

package App::MathImage::NumSeq::Happy;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IteratePred;
@ISA = ('App::MathImage::NumSeq::Base::IteratePred',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Happy Numbers');
use constant description => __('Happy numbers, reaching 1 under iterating sum of squares of digits.');
use constant values_min => 1;
use constant i_start => 1;

use App::MathImage::NumSeq::Base::Digits;
use constant parameter_list =>
  (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

# cf A035497 happy primes
#
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return ($radix == 10
          ? 'A007770'
          : undef);
}
# OEIS-Catalogue: A007770 radix=10

# sub ith {
#   my ($self, $i) = @_;
#   return ...
# }

sub pred {
  my ($self, $value) = @_;
  ### Happy pred(): $value
  if ($value <= 0) {
    return 0;
  }
  my $radix = $self->{'radix'};
  my %seen;
  for (;;) {
    ### $value
    my $sum = 0;
    if ($value == 1) {
      return 1;
    }
    if ($seen{$value}) {
      return 0;  # inf loop
    }
    $seen{$value} = 1;
    while ($value) {
      my $digit = ($value % $radix);
      $sum += $digit * $digit;
      $value = int($value/$radix);
    }
    # if ($value == $sum) {
    #   return 0;
    # }
    $value = $sum;
  }
}

1;
__END__
