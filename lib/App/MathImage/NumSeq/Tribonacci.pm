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

package App::MathImage::NumSeq::Tribonacci;
use 5.004;
use strict;

use Math::NumSeq;
use base 'Math::NumSeq::Base::Sparse';

use vars '$VERSION';
$VERSION = 69;

# uncomment this to run the ### lines
#use Smart::Comments;

# use constant name => Math::NumSeq::__('Tribonacci Numbers');
use constant description => Math::NumSeq::__('Tribonacci numbers 0, 0, 1, 1, 2, 4, 7, 13, 24, being T(i) = T(i-1) + T(i-2) + T(i-3) starting from 0,0,1.');
use constant characteristic_monotonic => 2;
use constant characteristic_monotonic_from_i => 3;
use constant values_min => 1;
use constant oeis_anum => 'A000073'; # tribonacci

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'f0'} = 0;
  $self->{'f1'} = 0;
  $self->{'f2'} = 1;
}
sub next {
  my ($self) = @_;
  ### Tribonacci next(): "$self->{'f0'} $self->{'f1'} $self->{'f2'}"
  (my $ret,
   $self->{'f0'},
   $self->{'f1'},
   $self->{'f2'})
   = ($self->{'f0'},
      $self->{'f1'},
      $self->{'f2'},
      $self->{'f0'}+$self->{'f1'}+$self->{'f2'});
  return ($self->{'i'}++, $ret);
}

1;
__END__
