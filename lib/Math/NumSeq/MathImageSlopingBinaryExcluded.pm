# triangular with some skipping ...



# Copyright 2012 Kevin Ryde

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

package Math::NumSeq::MathImageSlopingBinaryExcluded;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 95;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('Integers not occurring as sloping binary.');
use constant characteristic_increasing => 1;
use constant values_min => 1;
use constant default_i_start => 1;

# cf A102371 sloping binary
#
# 1,2,7,12,29,62,123,248,505,...
use constant oeis_anum => 'A102371';

# i-k = 0 mod 2^k
# always i itself counts +2^i
# others i<2^k
#
# n=2 start -2
# 2-1 mod 2 = 1
# 2-2 mod 4 = 0 count +4 total 4-2=2
#
# n=3 start -3
# 3-1 mod 2 = 0 count +2
# 3-2 mod 4 = 1
# 3-3 mod 8 = 0 count +8 total 8+2-3=7
#
# n=4 start -4
# 4-1 mod 2 = 1
# 4-2 mod 4 = 2
# 4-3 mod 8 = 1
# 4-4 mod 16 = 0 count +16 total 16-4=13

sub ith {
  my ($self, $i) = @_;

  if (_is_infinite($i)) {
    return $i;
  }
  my $one = ($i >= 30
              ? Math::NumSeq::_bigint()->new(1)
              : 1);
  my $value = ($one << $i) - $i;
  my $k = 1;
  my $mask = 1;
  while ($mask < $i) {
    if ((($i-$k) & $mask) == 0) {
      $value += $mask + 1;
    }
    $k++;
    $mask = ($mask << 1) + 1;
  }
  return $value;
}

1;
__END__
