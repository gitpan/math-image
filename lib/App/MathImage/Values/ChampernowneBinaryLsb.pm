# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::ChampernowneBinaryLsb;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 36;

use constant name => __('Champernowne Sequence LSB First');
use constant description => __('The 1 bit positions when the integers 1,2,3,4,5 etc are written out concatenated in binary, least significant bit first, 1 01 11 001 101 etc.');

# uncomment this to run the ### lines
#use Smart::Comments;

# Champernowne sequence in binary 1s and 0s
#   http://www.research.att.com/~njas/sequences/A030190
#
# as integer positions
#   http://www.research.att.com/~njas/sequences/A030310
#   http://www.research.att.com/~njas/sequences/A030303
#
# 1 10  11 100 101  110 111
# 1 2  4,5 6   9,11 12,13 15,16,17,
#

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { n => 0,
                 val => 0,
                 bitmask => 1,
               }, $class;
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
      return $self->{'n'};
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

