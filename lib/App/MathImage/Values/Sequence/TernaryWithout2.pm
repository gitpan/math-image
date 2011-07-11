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

package App::MathImage::Values::Sequence::TernaryWithout2;
use 5.004;
use strict;

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';

use vars '$VERSION';
$VERSION = 63;

use constant name => __('Ternary without 2s');
use constant description => __('The integers without any 2 digits when written out in ternary (base 3).');
use constant values_min => 1;
use constant oeis_anum => 'A005836';

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;

  my $lo = $options{'lo'} || 0;
  my $n = abs($lo);

  # look at the base 3 digits of $n, build $i by treating them as binary,
  # increment any "2" digits to go to the next without 2s
  my $i = 0;
  my $power = 1;
  while ($n) {
    my $rem = $n % 3;
    if ($rem == 2) {
      $n++;
    } else {
      $i += $rem * $power;
    }
    $n = int ($n / 3);
    $power <<= 1;
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

sub rewind {
  my ($self) = @_;
  $self->{'ith'} = 0;
}
sub next {
  my ($self) = @_;
  ### TernaryWithout2 next(): $self->{'i'}+1

  # $i converted to binary digits, built back up as ternary
  my $i = $self->{'i'}++;
  my $ret = 0;
  my $power = 1;
  do {
    if ($i & 1) {
      $ret += $power;
    }
    $power *= 3;
  } while ($i >>= 1);

  return ($self->{'ith'}++, $ret);

  # my $digit = 1;
  # my $x = $i;
  # while ($x) {
  #   ### x mod 3: $x%3
  #   if (($x % 3) == 2) {
  #     ### add: $digit
  #     $i += $digit;
  #     $x++;
  #   }
  #   $x = int($x/3);
  #   $digit *= 3;
  # }
  # return (($self->{'i'} = $i),
  #         1);
}

my @notwos = (1,   # 00 = 0
              1,   # 01 = 1
              0,   # 02 = 2
              1,   # 10 = 3
              1,   # 11 = 4
              0,   # 12 = 5
              0,   # 20 = 6
              0,   # 21 = 7
              0,   # 22 = 8
              1,   # 100 = 9
              1,   # 101 = 10
              0,   # 102 = 11
              1,   # 110 = 12
              1,   # 111 = 13
              # 0, # 112 = 14
              # 0, # 200 = 15
              # 0, # 201 = 16
              # 0, # 202 = 17
              #    # ...
             );
sub pred {
  my ($self, $n) = @_;
  while ($n) {
    unless ($notwos[$n % 27]) {
      return 0;
    }
    $n = int ($n / 27);
  }
  return 1;
}

1;
__END__
