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

package App::MathImage::NumSeq::GolayRudinShapiro;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 82;

use Math::NumSeq;
use Math::NumSeq::Base::IteratePred;
@ISA = ('Math::NumSeq::Base::IteratePred',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


# cf A014081 - count of 11 bit pairs
#    A020985 - 1 and -1
#    A020986 - cumulative 1,-1, always positive?
#    A020987 - 0 and 1
#    A020990 - sum grs*k something ...
#    A020991 - highest occurrance of N in the partial sums.
#    
#
use constant description => Math::NumSeq::__('Golay/Rudin/Shapiro sequence -1 positions, being 3,6,11,12,13,15,etc numbers which have an odd number of "11" bit pairs in binary.');
use constant values_min => 3;
use constant oeis_anum => 'A022155';  # positions of -1s

sub pred {
  my ($self, $value) = @_;
  if ($value < 0) { return 0; }

  # N & Nshift leaves bits with a 1 below them, then parity of bit count
  $value &= ($value >> 1);
  return (1 & unpack('%32b*', pack('I', $value)));
}

1;
__END__

