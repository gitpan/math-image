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

package App::MathImage::NumSeq::ChampernowneBinaryLsb;
use 5.004;
use strict;

use App::MathImage::NumSeq '__';
use base 'App::MathImage::NumSeq';

use vars '$VERSION';
$VERSION = 65;

use constant name => __('Champernowne Sequence LSB First');
use constant description => __('The 1 bit positions when the integers 1,2,3,4,5 etc are written out concatenated in binary, least significant bit first, 1 01 11 001 101 etc.');
use constant values_min => 0;

# uncomment this to run the ### lines
#use Smart::Comments;

# Champernowne sequence in binary 1s and 0s
#   http://oeis.org/A030190
#
# as integer positions
#   http://oeis.org/A030310
#   http://oeis.org/A030303
#
# 1 10  11 100 101  110 111
# 1 2  4,5 6   9,11 12,13 15,16,17,
#

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'n'} = 0;
  $self->{'val'} = 0;
  $self->{'bitmask'} = 1;
}
sub next {
  my ($self) = @_;

  my $bitmask = $self->{'bitmask'};
  for (;;) {
    if ($bitmask > $self->{'val'}) {
      $self->{'val'}++;
      $bitmask = 1;
    }
    $self->{'n'}++;
    if ($bitmask & $self->{'val'}) {
      $self->{'bitmask'} = $bitmask << 1;
      return ($self->{'i'}++, $self->{'n'});
    }
    $bitmask <<= 1;
  }
}

# sub pred {
#   my ($self, $n) = @_;
#   return ($n & 1);
# }

1;
__END__

