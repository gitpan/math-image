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

package App::MathImage::NumSeq::Base::Digits;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 53;

sub is_type {
  my ($self, $type) = @_;
  return ($type eq 'radix' || $self->SUPER::is_type($type));
}
use constant values_min => 0;
sub values_max {
  my ($self) = @_;
  return $self->{'radix'} - 1;
}

use constant parameter_common_radix =>
  { name    => 'radix',
    type    => 'integer',
    display => __('Radix'),
    default => 10,
    minimum => 2,
    width   => 4,
    description => __('Radix, ie. base, for the values calculation.  Default is decimal (base 10).'),
  };
use constant parameter_list => (parameter_common_radix);
