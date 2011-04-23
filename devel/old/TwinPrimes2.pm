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

package App::MathImage::NumSeq::Sequence::TwinPrimes2;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence::TwinPrimes1';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 38;

use constant name => __('Twin Primes, second of each');
use constant description => __('The second of each pair of twin primes, 5, 7, 13, 19, 31, etc.');
use constant oeis_anum => 'A006512'; # greater of two

sub new {
  my $class = shift;
  return $class->SUPER::new (twin_offset => 1, @_);
}

1;
__END__
