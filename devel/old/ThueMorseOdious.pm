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

package App::MathImage::NumSeq::Sequence::ThueMorseOdious;
use 5.004;
use strict;
use warnings;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence::ThueMorseEvil';

use vars '$VERSION';
$VERSION = 38;

# bit count per example in perlfunc unpack()

use constant name => __('Thue-Morse Odious Numbers');
use constant description => __('The Thue-Morse "odious" numbers, meaning numbers with an odd number of 1s in their binary form (the opposite of the "evil"s).');

use constant oeis_anum => 'A000069'; # odious
# A010060 - 0 or 1 bits

# uncomment this to run the ### lines
#use Smart::Comments;

sub pred {
  my ($self, $n) = @_;
  return (1 & unpack('%32b*', pack('I', $n)));
}
1;
__END__