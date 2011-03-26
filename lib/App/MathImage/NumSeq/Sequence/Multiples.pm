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

package App::MathImage::NumSeq::Sequence::Multiples;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 49;

use constant name => __('Multiples of a given K');
use constant description => __('The multiples K, 2*K, 3*K, 4*K, etc of a given number.');
use constant values_min => 0;
sub is_type {
  my ($self, $type) = @_;
  return ($type eq 'monotonic' || $self->SUPER::is_type($type));
}
use constant parameter_list => ({ name => 'multiples',
                                  type => 'float',
                                  width => 10,
                                  decimals => 4,
                                  page_increment => 10,
                                  step_increment => 1,
                                  minimum => 0,
                                  default => 29,
                                  description => __('Display multiples of this number.  For example 6 means show 6,12,18,24,30,etc.'),
                                },
                               );

sub rewind {
  my ($self) = @_;
  $self->{'i'} = ceil ($self->{'lo'} / abs($self->{'multiples'}))
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
