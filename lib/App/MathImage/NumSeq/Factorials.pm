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

package App::MathImage::NumSeq::Factorials;
use 5.004;
use strict;

use App::MathImage::NumSeq '__';
use base 'App::MathImage::NumSeq::Base::Sparse';

use vars '$VERSION';
$VERSION = 65;

use constant name => __('Factorials');
use constant description => __('The factorials 1, 2, 6, 24, 120, etc, 1*2*...*N.');
use constant values_min => 1;
use constant oeis_anum => 'A000142'; # factorials 1,1,2,6,24, including 0!==1

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  ### Factorials rewind()
  $self->{'i'} = 0;
  $self->{'f'} = 1;
}
sub next {
  my ($self) = @_;
  ### Factorials next()
  my $i = $self->{'i'}++;
  return ($i, $self->{'f'} *= ($i||1));
}

1;
__END__
