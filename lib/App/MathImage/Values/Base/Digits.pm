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

package App::MathImage::Values::Base::Digits;
use 5.004;
use strict;

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';

use vars '$VERSION';
$VERSION = 64;

use constant characteristic_radix => 1;
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
    width   => 3,
    description => __('Radix, ie. base, for the values calculation.  Default is decimal (base 10).'),
  };
use constant parameter_list => (parameter_common_radix);
