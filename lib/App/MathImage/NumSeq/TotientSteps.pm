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

package App::MathImage::NumSeq::TotientSteps;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 77;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

use App::MathImage::NumSeq::Totient;
*_totient_by_sieve = \&App::MathImage::NumSeq::Totient::_totient_by_sieve;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Number of repeated applications of the totient function to reach 1.');
use constant characteristic_count => 1;
use constant characteristic_monotonic => 0;
use constant values_min => 1;
use constant i_start => 1;
use constant oeis_anum => 'A003434';

sub ith {
  my ($self, $i) = @_;
  ### TotientSteps ith(): $i
  my $count = 0;
  for (;;) {
    if ($i <= 1) {
      return $count;
    }
    $i = _totient_by_sieve($self,$i);
    $count++;
  }
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 1);
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
