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


# too sparse to be worth seeing ?

                    # [ 'Base4Only01', 0,
                    #   [ 0x00, 0x01,    # 0,1
                    #     0x04, 0x05,    # 10,11,
                    #     0x10, 0x11,    # 100,101
                    #     ] ],
                    # [ 'Base4Only01', 0,
                    #   [ 0, 1, 4, 5, 16, 17, 20, 21, 64, 65, 68, 69, 80, 81,
                    #     84, 85, 256, 257, 260, 261, 272, 273, 276, 277, 320,
                    #     321, 324, 325, 336, 337, 340, 341, 1024, 1025, 1028,
                    #     1029, 1040, 1041, 1044, 1045, 1088, 1089, 1092,
                    #     1093, 1104, 1105, 1108, 1109, 1280, 1281, 1284, 1285,
                    #   ] ],
                    


package App::MathImage::NumSeq::Sequence::Base4Only01;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 60;

# http://oeis.org/A000695
#    Moser-de Bruijn sequence, sums of distinct powers of 4

# Cf.
#
# http://oeis.org/A001196
#    Double-bitters, only even length runs in binary, which is digits 0,3 in
#    base 4.  Being 3* the Only01 values.

use constant name => __('Base 4 only digits 0,1');
use constant description => __('The integers with only digits 0 and 1 when written out in base 4.');
use constant oeis_anum => 'A000695';

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => -1,
               }, $class;
}

# ENHANCE-ME: binary with interleaved 0 bits
sub next {
  my ($self) = @_;
  ### Base4Only01 next()
  my $i = $self->{'i'} + 1;
  my $mask = 3;
  my $two = 2;
  while ($two <= $i) {
    ### i: sprintf '%b', $i
    ### mask: sprintf '%b', $mask
    ### two: sprintf '%b', $two
    if (($i & $mask) >= $two) {
      $i += 2*$two - ($i & $mask);
    }
    $mask <<= 2;
    $two <<= 2;
  }
  ### ret: sprintf '%b', $i
  return ($self->{'i'} = $i);
}
sub pred {
  my ($class_or_self, $n) = @_;
  while ($n) {
    if (($n & 3) >= 2) {
      return 0;
    }
    $n >>= 2;
  }
  return 1;
}

1;
__END__
