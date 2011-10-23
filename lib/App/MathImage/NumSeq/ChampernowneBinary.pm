# FIXME: parameter for endian instead of sep series?
# ENHANCE-ME: radix parameter instead of binary


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

package App::MathImage::NumSeq::ChampernowneBinary;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 78;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

# use constant name => Math::NumSeq::__('Champernowne Sequence');
use constant description => Math::NumSeq::__('Champernowne sequence 1 positions, 1,2,4,5,6,9,11,etc, being the 1 bit positions when the integers 1,2,3,4,5 etc are written out concatenated in binary 1 10 11 100 101 etc.');
use constant values_min => 1;
use constant characteristic_monotonic => 2;

# A030190 - Champernowne sequence in binary 1s and 0s, starting from 0
# A030302 - binary starting from 1
# A030303 - positions of 1 in starting from 1
# A030308 - binary reverse starting from 1
# A030309 - positions of 0 in reverse
# A030310 - positions of 1 in reverse

#
# 0 1 10  11 100 101  110 111
#   1 2  4,5 6   9,11 12,13 15,16,17,
#    
# cf A007376 - decimal digits concatenated Barbier infinite word
#    A054632 -    partial sums of that series
#    A033307
#    A031298 - decimal reverse to LSB digit first
#    A031035 - octal starting from 1
#    A054634 - octal starting from 0
#    A031045 - octal reverse
#    A031076 - base 9
#    A031087 - base 9 reversed
#    A030998 - base 7
#    A031007 - base 7 reversed
#    A003137 - ternary starting 1
#    A054635 - ternary starting 0
#    A054637 -    ternary partial sums
#
#    A136414 - decimal 2 digits at a time
#    A193431 - decimal 3 digits at a time
#    A193492 - decimal 4 digits at a time
#    A193493 - decimal 5 digits at a time
#    A001704, A127421 - concatenate n,n+1
#
# sub oeis_anum {
#   my ($class_or_self) = @_;
#   if (! ref $class_or_self ||
#       $class_or_self->{'radix'} == 2) {
#     return 'A030303';
#   }
#   return undef;
# }
#
use constant oeis_anum => 'A030303';


sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'n'} = 0;
  $self->{'val'} = 0;
  $self->{'bitmask'} = 0;
}
sub next {
  my ($self) = @_;
  ### ChampernowneBinary next(): $self

  my $bitmask = $self->{'bitmask'};
  for (;;) {
    if ($bitmask == 0) {
      $self->{'val'}++;
      $bitmask = 1;
      while ($bitmask <= $self->{'val'}) {
        $bitmask <<= 1;
      }
      $bitmask >>= 1;
      ### next val: sprintf('%#X',$self->{'val'})
      ### bitmask: sprintf('%#X',$bitmask)
    }
    $self->{'n'}++;
    if ($bitmask & $self->{'val'}) {
      $self->{'bitmask'} = $bitmask >> 1;
      ### result: $self->{'n'}
      return ($self->{'i'}++, $self->{'n'});
    }
    $bitmask >>= 1;
  }
}

# ENHANCE-ME: msb 1 bit position determines next lower (k+1)*2^k.
#
# 0   0 1
# 2   10 11
# 6   100 101 110 111
#
sub pred {
  my ($self, $n) = @_;
  ### ChampernowneBinary pred(): $n
  if ($n < 2) { return $n; }

  my $base = 2;
  my $bits_each = 2;
  my $nums = 2;
  for (;;) {
    my $next_base = $base + $nums*$bits_each;
    last if ($next_base > $n);
    $base = $next_base;
    $bits_each++;
    $nums <<= 1;
  }
  $n -= $base;
  ### offset: $n
  my $pos = (-1-$n) % $bits_each;
  $n = int($n / $bits_each) + $nums;
  ### $base
  ### $bits_each
  ### $nums
  ### $pos
  ### val: sprintf('%#X',$n)
  return (($n >> $pos) & 1);
}

1;
__END__

