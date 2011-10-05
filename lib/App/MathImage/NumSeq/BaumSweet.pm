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

package App::MathImage::NumSeq::BaumSweet;
use 5.004;
use strict;

use vars '$VERSION','@ISA';
$VERSION = 75;
use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

use constant description => Math::NumSeq::__('...');
use constant values_min => 0;
use constant values_max => 1;
use constant characteristic_count => 1;
use constant characteristic_boolean => 1;
use constant oeis_anum => 'A086747';

sub ith {
  my ($self, $i) = @_;
  if (_is_infinite($i)) {
    return $i;
  }
  while ($i) {
    if (($i % 2) == 0) {
      my $odd = 1;
      do {
        $i /= 2;
        $odd ^= 1;
      } until ($i % 2);
      if ($odd) {
        return 0;
      }
    }
    $i = int($i/2);
  }
  return 1;
}

1;
__END__
