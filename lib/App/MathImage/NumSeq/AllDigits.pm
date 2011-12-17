# endian => 'high'
# endian => 'low'

# endian => 'big'
# endian => 'little'



# Copyright 2011 Kevin Ryde

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

package App::MathImage::NumSeq::AllDigits;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 85;
use Math::NumSeq::Base::Digits;
@ISA = ('Math::NumSeq::Base::Digits');

use Math::NumSeq 7; # v.7 for _is_infinite()
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Digits of all the integers.');

use constant parameter_info_array =>
  [
   Math::NumSeq::Base::Digits->parameter_info_list,
   {
    name    => 'endian',
    type    => 'enum',
    default => 'big',
    choices => ['big','little'],
    description => Math::NumSeq::__('Endianness for the digits, big is high to low, little is low to high.'),
   },
  ];

# cf A030303 - base 2 positions of 1s, start 1
#    A030309 - positions of 0 in reverse
#    A030310 - positions of 1 in reverse
#    A030305 - base 2 lengths of runs of 0s
#    A030306 - base 2 lengths of runs of 1s
#
#    A054637 - base 3 partial sums digits, start i=0 value=0
#
#    A054632 - decimal partial sums
#
#    A136414 - decimal 2 digits at a time, start i=1 value=1
#    A193431 - decimal 3 digits at a time
#    A193492 - decimal 4 digits at a time
#    A193493 - decimal 5 digits at a time
#
#    A033308 - concatenate primes digits
#
my %oeis_anum;

$oeis_anum{'big'}->[0]->[2] = 'A030190'; # base 2, start i=0 value=0
$oeis_anum{'big'}->[1]->[2] = 'A030302'; # base 2, start i=1 value=1
# OEIS-Catalogue: A030190 radix=2 i_start=0
# OEIS-Catalogue: A030302 radix=2 i_start=1
$oeis_anum{'little'}->[0]->[2] = 'A030308'; # base 2 LE start i=1 value=1
# OEIS-Catalogue: A030308 radix=2 endian=little i_start=0

$oeis_anum{'big'}->[0]->[3] = 'A054635'; # base 3, start i=0 value=0
$oeis_anum{'big'}->[1]->[3] = 'A003137'; # base 3, start i=1 value=1
$oeis_anum{'little'}->[0]->[3] = 'A030341'; # base 3, start i=0 value=0
# OEIS-Catalogue: A054635 radix=3 i_start=0
# OEIS-Catalogue: A003137 radix=3 i_start=1
# OEIS-Catalogue: A030341 radix=3 endian=little i_start=0

$oeis_anum{'big'}->[1]->[4] = 'A030373'; # base 4, start i=1 value=1
$oeis_anum{'little'}->[0]->[4] = 'A030386'; # base 4, start i=0 value=0
# OEIS-Catalogue: A030373 radix=4 i_start=1
# OEIS-Catalogue: A030386 radix=4 endian=little i_start=0

$oeis_anum{'big'}->[1]->[5] = 'A031219'; # base 5, start i=1 value=1
$oeis_anum{'little'}->[0]->[5] = 'A031235'; # base 4, start i=0 value=0
# OEIS-Catalogue: A031219 radix=5 i_start=1
# OEIS-Catalogue: A031235 radix=5 endian=little i_start=0

$oeis_anum{'big'}->[0]->[7] = 'A030998'; # base 7, start i=0 value=0
$oeis_anum{'little'}->[1]->[7] = 'A031007'; # base 7 LE start i=1 value=1
# OEIS-Catalogue: A030998 radix=7 i_start=0

$oeis_anum{'big'}->[0]->[8] = 'A054634'; # base 8, start i=0 value=0
$oeis_anum{'big'}->[1]->[8] = 'A031035'; # base 8, start i=1 value=1
# OEIS-Catalogue: A054634 radix=8 i_start=0
# OEIS-Catalogue: A031035 radix=8 i_start=1
$oeis_anum{'little'}->[1]->[8] = 'A031045'; # base 8 LE start i=1 value=1
# OEIS-Catalogue: A031045 radix=8 endian=little i_start=1

$oeis_anum{'big'}->[1]->[9] = 'A031076'; # base 9, start i=1 value=1
# OEIS-Catalogue: A031076 radix=9 i_start=1
$oeis_anum{'little'}->[1]->[9] = 'A031087'; # base 9 LE start i=1 value=1
# OEIS-Catalogue: A031087 radix=9 endian=little i_start=1

$oeis_anum{'big'}->[1]->[10] = 'A007376'; # base 10, start i=1 value=1
# OEIS-Catalogue: A007376 i_start=1
$oeis_anum{'little'}->[1]->[10] = 'A031298'; # base 9 LE start i=1 value=1
# OEIS-Catalogue: A031298 radix=10 endian=little i_start=1
#
# A033307 is the digits starting from 1 the same as A007376, but with
# offset=0 for that 1.


sub oeis_anum {
  my ($self) = @_;
  ### $self
  return $oeis_anum{$self->{'endian'}}->[$self->i_start]->[$self->{'radix'}];
}


sub rewind {
  my ($self) = @_;
  $self->{'pending'} = [ $self->{'n'} = $self->{'i'} = $self->i_start ];
}
sub next {
  my ($self) = @_;
  ### AllDigits next(): $self->{'i'}

  my $value;
  unless (defined ($value = shift @{$self->{'pending'}})) {
    my $pending = $self->{'pending'};
    my $radix = $self->{'radix'};
    my $n = ++$self->{'n'};
    while ($n) {
      push @$pending, $n % $radix;
      $n = int($n/$radix);
    }
    if ($self->{'endian'} eq 'big') {
      @$pending = reverse @$pending;
    }
    $value = shift @$pending;
  }
  return ($self->{'i'}++, $value);
}

# sub ith {
#   my ($self, $i) = @_;
#   ### AllDigits ith(): $i
#   if ($i < 0) {
#     return undef;
#   }
#   if (_is_infinite($i)) {
#     return $i;
#   }
# 
#   my $radix = $self->{'radix'};
#   my $power = 1;
#   my $len = 1;
#   my $n = 1;
#   while ($i >= $power) {
#     $i -= $power;
#     $power *= $radix;
#     $len++;
#     $n *= $radix;
#   }
# 
#   ### remainder: $i
#   ### $len
#   ### $n
# 
#   my $shift = $i % $len;
#   $n += int($i/$len);
# 
#   ### $shift
#   ### $n
# 
#   if ($self->{'endian'} eq 'big') {
#     $shift = $len-1 - $shift;
#   }
#   while ($shift-- > 0) {
#     $n = int($n/$radix);
#   }
#   return $n % $radix;
# }

1;
__END__

L<Math::NumSeq::SqrtDigits>
