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

package App::MathImage::NumSeq::Sequence::BinaryLengths;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 47;

use constant name => __('Binary Lengths');
use constant description => __('Cumulative length of numbers 1,2,3,etc written out in binary, giving, 1,2,4,6,9,12,15,18,22,etc.  There\'s 2 steps by 2, then 4 steps by 3, then 8 steps by 4, then 16 steps by 5, etc.');
use constant values_min => 0;
use constant oeis => 'A083652';
# OeisCatalogue: A083652

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => 0,
                 count => 3,
                 bits => 1,
               }, $class;
}
sub next {
  my ($self) = @_;
  ### BinaryLengths next(): $self
  ### count: $self->{'count'}
  ### bits: $self->{'bits'}

  if (--$self->{'count'} <= 0) {
    $self->{'count'} = 1 << ($self->{'bits'}++);
    ### step to
    ### count: $self->{'count'}
    ### bits: $self->{'bits'}
  }
  return ($self->{'i'} += $self->{'bits'});
}

# sub pred {
#   my ($self, $n) = @_;
#   if ($n < 2) { return $n; }
# 
#   my $base = 2;
#   my $bits_each = 2;
#   my $nums = 2;
#   for (;;) {
#     my $next_base = $base + $nums*$bits_each;
#     last if ($next_base > $n);
#     $base = $next_base;
#     $bits_each++;
#     $nums <<= 1;
#   }
#   $n -= $base;
#   ### offset: $n
#   my $pos = (-1-$n) % $bits_each;
#   $n = int($n / $bits_each) + $nums;
#   ### $base
#   ### $bits_each
#   ### $nums
#   ### $pos
#   ### val: sprintf('%#X',$n)
#   return (($n >> $pos) & 1);
# }

1;
__END__

