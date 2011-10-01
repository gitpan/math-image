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


# math-image --values=Fibbinary

package App::MathImage::NumSeq::Fibbinary;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 73;
use Math::NumSeq;
use Math::NumSeq::Base::IteratePred;
@ISA = ('Math::NumSeq::Base::IteratePred',
        'Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

use constant values_min => 1;
use constant characteristic_monotonic => 1;
# use constant description => Math::NumSeq::__('');
use constant oeis_anum => 'A003714';

sub pred {
  my ($self, $value) = @_;
  return ($value ^ (2*$value)) == 3*$value;
}

1;
__END__

