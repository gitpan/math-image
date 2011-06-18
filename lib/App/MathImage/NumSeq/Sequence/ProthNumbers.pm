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

package App::MathImage::NumSeq::Sequence::ProthNumbers;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Base::Digits;

use vars '$VERSION';
$VERSION = 60;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('ProthNumbers');
use constant description => __('Proth numbers k*2^n+1 for odd k and k < 2^n.');
use constant values_min => 3;
use constant i_start => 1;

# cf A157892 - value of k
#    A157893 - value of n
#    A080076 - Proth primes
#    A134876 - how many Proth primes for given n
#
#    A002253
#    A002254
#    A032353
#    A002256
#
use constant oeis_anum => 'A080075';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  # ENHANCE-ME: keep the k and its increment
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

sub pred {
  my ($self, $value) = @_;
  ### ProthNumbers pred(): $value
  ($value >= 3 && $value & 1) or return 0;
  my $pow = 2;
  for (;;) {
    ### at: "$value   $pow"
    $value >>= 1;
    if ($value < $pow) {
      return 1;
    }
    if ($value & 1) {
      return ($value < $pow);
    }
    $pow <<= 1;
  }
}

sub ith {
  my ($self, $i) = @_;
  ### ProthNumbers ith(): $i
  if ($i == 1) {
    return 3;
  }
  $i += 1;
  my $exp = 0;
  my $rem = $i;
  while ($rem > 3) {
    $rem >>= 1;
    $exp++;
  }
  my $bit = 2**$exp;

  ### i: sprintf('0b%b', $i)
  ### bit: sprintf('0b%b', $bit)
  ### $rem
  ### high: sprintf('0b%b', ($i - $bit*($rem-1)))
  ### rem factor: ($rem - 1)
  ### so: sprintf('0b%b', ($i - $bit*($rem-1)) * $bit * ($rem - 1) + 1)
  ### assert: $rem==2 || $rem==3

  return ($i - $bit*($rem-1)) * 2 * $bit * ($rem - 1) + 1;
}

1;
__END__
