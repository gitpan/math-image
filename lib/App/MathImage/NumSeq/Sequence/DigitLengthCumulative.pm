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

package App::MathImage::NumSeq::Sequence::DigitLengthCumulative;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 54;

use constant name => __('Digit Length Cumulative');
use constant description => __('Cumulative length of numbers 0,1,2,3,etc written out in the given radix.  For example binary 1,2,4,6,9,12,15,18,22,etc, 2 steps by 2, then 4 steps by 3, then 8 steps by 4, then 16 steps by 5, etc.');
use constant values_min => 1;

my @oeis = (undef,
            undef,
            'A083652', # 2 binary
            undef,   # 3 ternary
            undef,   # 4
            undef,   # 5
            undef,   # 6
            undef,   # 7
            undef,   # 8
            undef,   # 9
            'A064223',  # 10 decimal
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}
# OeisCatalogue: A083652 radix=2
#
# cf A117804 - natural position of n in 012345678910111213
#

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'length'} = 1;
  $self->{'limit'} = $self->{'radix'};
  $self->{'total'} = 0;
}
sub next {
  my ($self) = @_;
  ### DigitLengthCumulative next(): $self
  ### count: $self->{'count'}
  ### bits: $self->{'bits'}

  my $i = $self->{'i'}++;
  if ($i >= $self->{'limit'}) {
    $self->{'limit'} *= $self->{'radix'};
    $self->{'length'}++;
    ### step to
    ### length: $self->{'length'}
    ### remaining: $self->{'limit'}
  }
  return ($i, ($self->{'total'} += $self->{'length'}));
}

sub ith {
  my ($self, $i) = @_;
  ### DigitLengthCumulative ith(): $i
  if ($i == $i-1) {
    return $i;  # don't loop forever if $i is +infinity
  }
  my $ret = 1;
  my $length = 1;
  my $radix = $self->{'radix'};
  my $power = 1;
  for (;;) {
    ### $ret
    ### $length
    ### $power
    my $next_power = $power * $radix;
    if ($i < $next_power) {
      ### final extra: $length * ($i - $power + 1)
      return $ret + $length * ($i - $power + 1);
    }
    ### add: $length * $next_power
    $ret += $length++ * ($next_power - $power);
    $power = $next_power;
  }
}

# sub pred {
#   my ($self, $value) = @_;
#   if ($value < 2) { return $value; }
# 
#   my $base = 2;
#   my $bits_each = 2;
#   my $valueums = 2;
#   for (;;) {
#     my $next_base = $base + $valueums*$bits_each;
#     last if ($next_base > $value);
#     $base = $next_base;
#     $bits_each++;
#     $valueums <<= 1;
#   }
#   $value -= $base;
#   ### offset: $value
#   my $pos = (-1-$value) % $bits_each;
#   $value = int($value / $bits_each) + $valueums;
#   ### $base
#   ### $bits_each
#   ### $valueums
#   ### $pos
#   ### val: sprintf('%#X',$value)
#   return (($value >> $pos) & 1);
# }

1;
__END__

