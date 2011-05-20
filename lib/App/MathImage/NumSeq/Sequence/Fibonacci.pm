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

package App::MathImage::NumSeq::Sequence::Fibonacci;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Sparse';

use vars '$VERSION';
$VERSION = 57;

use constant name => __('Fibonacci Numbers');
use constant description => __('The Fibonacci numbers 1,1,2,3,5,8,13,21, etc, each F(n) = F(n-1) + F(n-2), starting from 1,1.');
use constant values_min => 0;
use constant oeis_anum => 'A000045'; # fibonacci

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  ### Fibonacci rewind()
  $self->{'f0'} = 0;
  $self->{'f1'} = 1;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  ### Fibonacci next(): "f0=$self->{'f0'}, f1=$self->{'f1'}"
  (my $ret, $self->{'f0'}, $self->{'f1'})
   = ($self->{'f0'}, $self->{'f1'}, $self->{'f0'}+$self->{'f1'});
  ### $ret
  return ($self->{'i'}++, $ret);
}

1;
__END__
