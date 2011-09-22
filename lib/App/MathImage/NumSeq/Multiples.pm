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

package App::MathImage::NumSeq::Multiples;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use Math::NumSeq;
use base 'Math::NumSeq';

use vars '$VERSION';
$VERSION = 71;

use constant name => Math::NumSeq::__('Multiples of a given K');
use constant description => Math::NumSeq::__('The multiples K, 2*K, 3*K, 4*K, etc of a given number.');
use constant values_min => 0;
sub characteristic_monotonic {
  my ($self) = @_;
  # strictly monotonic if multiples of 1 or more
  return 1 + ($self->{'multiples'} >= 1);
}
use constant parameter_info_array => [ { name => 'multiples',
                                         type => 'float',
                                         width => 10,
                                         decimals => 4,
                                         page_increment => 10,
                                         step_increment => 1,
                                         minimum => 0,
                                         default => 29,
                                         description => Math::NumSeq::__('Display multiples of this number.  For example 6 means show 6,12,18,24,30,etc.'),
                                       },
                                     ];

# cf A017173 9n+1

sub rewind {
  my ($self) = @_;
  $self->{'i'} = ($self->{'multiples'}
                  && ceil ($self->{'lo'} / abs($self->{'multiples'})));
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $i * $self->{'multiples'});
}
sub pred {
  my ($self, $n) = @_;
  return (($n % $self->{'multiples'}) == 0);
}
sub ith {
  my ($self, $i) = @_;
  return $i * $self->{'multiples'};
}

1;
__END__
