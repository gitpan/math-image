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

package App::MathImage::NumSeq::Sequence::SafePrimes;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence::SophieGermainPrimes';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 58;

use constant name => __('Safe Primes');
use constant description => __('The safe primes 5,7,11,23,47, being primes where (P-1)/2 is also prime (those are the Sophie Germain primes).');
use constant values_min => 5;
use constant oeis_anum => 'A005385';

sub new {
  my $class = shift;
  return $class->SUPER::new (safe_primes => 1, @_);
}

1;
__END__
