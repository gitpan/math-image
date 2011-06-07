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

package App::MathImage::NumSeq::Sequence::Pell;
use 5.004;
use strict;
use List::Util 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Sparse';

use vars '$VERSION';
$VERSION = 59;

use constant name => __('Pell Numbers');
use constant description => __('The Pell numbers 0, 1, 2, 5, 12, 29, 70, etc, being P(k)=2*P(k-1)+P(k-2) starting from 0.');
use constant values_min => 0;
use constant oeis_anum => 'A000129'; # pell

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  ### Pell new(): \%options
  $self->{'i'} = 0;
  $self->{'f0'} = 0;
  $self->{'f1'} = 1;
}
sub next {
  my ($self) = @_;
  (my $ret,
   $self->{'f0'},
   $self->{'f1'})
   = ($self->{'f0'},
      $self->{'f1'},
      $self->{'f0'} + 2*$self->{'f1'});
  return ($self->{'i'}++, $ret);
}

1;
__END__
