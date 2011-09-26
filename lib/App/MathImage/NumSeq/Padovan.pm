# start at 1,1,1 or like oeis 1,0,0 ?



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

package App::MathImage::NumSeq::Padovan;
use 5.004;
use strict;

use Math::NumSeq;
use base 'Math::NumSeq::Base::Sparse';

use vars '$VERSION';
$VERSION = 72;

# use constant name => Math::NumSeq::__('Padovan Numbers');
use constant description => Math::NumSeq::__('Padovan numbers 1, 1, 1, 2, 2, 3, 4, 5, 7, 9, etc, being P(i) = P(i-2) + P(i-3) starting from 1,1,1.');
use constant characteristic_monotonic => 2;
use constant characteristic_monotonic_from_i => 5;
use constant values_min => 1;

# cf A100891 - prime padovans
#    A112882 - index position of those prime padovans
#    A133034 - first differences of padovans
#    A078027 - expansion (1-x)/(1-x^2-x^3), starts 1,-1,0
#    A096231 - triangles generation starting 1,3,5
#    A145462,A146973 - eisentriangle row sums value at left is padovan 
#    A134816 - starting 1,1,1 spiral sides
#    A000931 - starting 1,0,0
# use constant oeis_anum => 'A000931'; # padovan, but starting 1,0,0

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'f0'} = 1;
  $self->{'f1'} = 1;
  $self->{'f2'} = 1;
}
sub next {
  my ($self) = @_;
  ### Padovan next(): "$self->{'f0'} $self->{'f1'} $self->{'f2'}"
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
# sub pred {
#   my ($self, $n) = @_;
#   return (($n >= 0)
#           && do {
#             $n = sqrt($n);
#             $n == int($n)
#           });
# }

1;
__END__
