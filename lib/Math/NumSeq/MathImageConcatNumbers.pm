# Copyright 2011, 2012 Kevin Ryde

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


package Math::NumSeq::MathImageConcatNumbers;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 95;
use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

use Math::NumSeq::NumAronson 8; # new in v.8
*_round_down_pow = \&Math::NumSeq::NumAronson::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description =>
  Math::NumSeq::__('Concatenate i and i+1, eg. 99100.');
use Math::NumSeq::Base::Digits;
*parameter_info_array = \&Math::NumSeq::Base::Digits::parameter_info_array;

# cf A033308 - concatenate primes
#    A127421 - decimal but starting n=1 for value 1, 12, 23 etc off by 1
#
my @oeis_anum;
$oeis_anum[1]->[10] = 'A001704'; # starting i=1
# OEIS-Catalogue: A001704 i_start=1
#

sub oeis_anum {
  my ($self) = @_;
  ### $self
  return $oeis_anum[$self->i_start]->[$self->{'radix'}];
}

sub ith {
  my ($self, $i) = @_;
  ### ConcatNumbers ith(): $i
  if ($i < 0) {
    return undef;
  }
  if (_is_infinite($i)) {
    return $i;
  }

  my $radix = $self->{'radix'};
  my ($pow, $exp) = _round_down_pow ($i+1, $radix);
  return ($i * $pow * $radix) + $i+1;
}

1;
__END__

L<Math::NumSeq::All>,
L<Math::NumSeq::AllDigits>
