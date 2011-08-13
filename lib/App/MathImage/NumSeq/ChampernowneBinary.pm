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

use Math::NumSeq;
use base 'Math::NumSeq';

use vars '$VERSION';
$VERSION = 66;

# FIXME: parameter for endian instead of sep series?
# ENHANCE-ME: radix parameter instead of binary

# uncomment this to run the ### lines
#use Smart::Comments;

# use constant name => Math::NumSeq::__('Champernowne Sequence');
use constant description => Math::NumSeq::__('The 1 bit positions when the integers 1,2,3,4,5 etc are written out concatenated in binary 1 10 11 100 101 etc.');
use constant values_min => 0;
use constant characteristic_monotonic => 1;
use constant oeis_anum => 'A030303';

# # http://oeis.org/A030310  # binary 1 positions
# 
# sub oeis_anum {
#   my ($class_or_self) = @_;
#   if (! ref $class_or_self ||
#       $class_or_self->{'radix'} == 2) {
#     return 'A030303';
#   }
#   return undef;
# }

# Champernowne sequence in binary 1s and 0s
#   http://oeis.org/A030190
#
# as integer positions
#   http://oeis.org/A030310
#   http://oeis.org/A030303
#
# 0 1 10  11 100 101  110 111
#   1 2  4,5 6   9,11 12,13 15,16,17,
#

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

