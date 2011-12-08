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

package App::MathImage::NumSeq::Perrin;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 83;
use Math::NumSeq::Base::Sparse;
@ISA = ('Math::NumSeq::Base::Sparse');


# uncomment this to run the ### lines
#use Smart::Comments;

# use constant name => Math::NumSeq::__('Perrin Numbers');
use constant description => Math::NumSeq::__('Perrin numbers 3, 0, 2, 3, 2, 5, 5, 7, 10, etc, being P(i) = P(i-2) + P(i-3) starting from 3,0,2.');
use constant characteristic_monotonic => 2;
use constant characteristic_monotonic_from_i => 1;
use constant values_min => 0;
use constant oeis_anum => 'A001608'; # perrin

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'f0'} = 3;
  $self->{'f1'} = 0;
  $self->{'f2'} = 2;
}
sub next {
  my ($self) = @_;
  ### Perrin next(): "i=$self->{'i'}  $self->{'f0'} $self->{'f1'} $self->{'f2'}"
  (my $ret,
   $self->{'f0'},
   $self->{'f1'},
   $self->{'f2'})
   = ($self->{'f0'},
      $self->{'f1'},
      $self->{'f2'},
      $self->{'f0'}+$self->{'f1'});
  return ($self->{'i'}++, $ret);
}

1;
__END__
