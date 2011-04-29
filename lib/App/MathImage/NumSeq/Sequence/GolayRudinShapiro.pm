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

package App::MathImage::NumSeq::Sequence::GolayRudinShapiro;
use 5.004;
use strict;
use List::Util 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 54;

# uncomment this to run the ### lines
#use Smart::Comments;

# http://oeis.org/A020985
#     1 and -1
# http://oeis.org/A022155
#     Positions where negative.
#
# http://oeis.org/A020986
#     Nth partial sums of 1 and -1, variously up and down
# http://oeis.org/A020991
#     Highest occurrance of N in the partial sums.
#
#
#
use constant name => __('Golay Rudin Shapiro');
use constant description => __('Numbers which have an odd number of "11" bit pairs in binary.');
use constant values_min => 3;
use constant oeis_anum => 'A022155';  # positions of -1s

use constant PHI => (1 + sqrt(5)) / 2;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'value'} = 0;
}
sub next {
  my ($self) = @_;
  for (;;) {
    if ($self->pred (my $value = $self->{'value'}++)) {
      return ($self->{'i'}++, $value);
    }
  }
}

sub pred {
  my ($self, $n) = @_;
  if ($n < 0) { return 0; }
  $n &= ($n >> 1);
  return (1 & unpack('%32b*', pack('I', $n)));
}

1;
__END__

