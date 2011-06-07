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

package App::MathImage::NumSeq::Sequence::Base4Without3;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 59;

use constant name => __('Base 4 Without 3');
use constant description => __('The integers without any 3 digits when written out in base 4.');
use constant values_min => 0;
use constant oeis_anum => 'A023717'; # no 3s in base 4

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;

  my $lo = $options{'lo'} || 0;
  my $n = abs($lo);

  # look at the base 4 digits, form $i by treating them as binary, increment
  # any "3" digits to go to the next without 3s
  my $i = 0;
  my $power = 1;
  while ($n) {
    my $rem = $n & 3;
    if ($rem == 3) {
      $n++;
    } else {
      $i += $rem * $power;
    }
    $n >>= 2;
    $power *= 3;
  }

  if ($lo < 0) {
    $i = -$i;
    if ($n == $lo) {
      $i--;
    }
  }
  return bless { i => $i,
               }, $class;
}
sub next {
  my ($self) = @_;
  ### Base4Without3 next(): $self->{'i'}

  # $i converted to ternary digits, built back up as base 4
  my $i = $self->{'i'}++;
  my $shift = 0;
  my $ret = 0;
  while ($i) {
    $ret += ($i % 3) << $shift;
    $i = int($i/3);
    $shift += 2;
  }
  return ($self->{'ith'}++, $ret);

  # return $base4->from_base ($ternary->to_base ($self->{'i'}++));
  # my $i = $self->{'i'}++;
  # my $mask = 3;
  # while ($mask <= $i) {
  #   if (($i & $mask) == $mask) {
  #     $i += $mask/3;
  #   }
  #   $mask <<= 2;
  # }
  # return (($self->{'i'} = $i),
  #         1);
}
sub pred {
  my ($self, $n) = @_;
  ### Base4Without3 pred(): $n
  # 0011   3
  # 0111   7
  # 1011   b
  # 1100   c
  # 1101   d
  # 1110   e
  # 1111   f
  return (sprintf('%x',$n) !~ /[37bcdef]/);
}

1;
__END__
