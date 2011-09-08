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

package App::MathImage::NumSeq::All;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('All Integers');
use constant description => Math::NumSeq::__('All integers 0,1,2,3,etc.');
use constant values_min => 1;
use constant characteristic_monotonic => 1;

# cf A000027 natural numbers starting 1
#
use constant oeis_anum => 'A001477';   # non-negatives, starting 0

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->{'lo'} || 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $i);
}

use constant pred => 1;
sub ith {
  my ($self, $i) = @_;
  return $i;
}

1;
__END__
