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
$VERSION = 59;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('ProthNumbers');
use constant description => __('Proth numbers k*2^n+1 for odd k and k < 2^n.');
use constant values_min => 1;

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
  $self->{'i'} = 1;
  $self->{'value'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  my $value = $self->{'value'} + 1;
  while (! $self->pred($value)) {
    $value += 1;
  }
  ### $value
  return ($i, $self->{'value'} = $value);
}

sub pred {
  my ($self, $n) = @_;
  ### ProthNumbers pred(): $n
  ($n >= 3 && $n & 1) or return 0;
  my $pow = 2;
  for (;;) {
    ### at: "$n   $pow"
    $n >>= 1;
    if ($n < $pow) {
      return 1;
    }
    if ($n & 1) {
      return ($n < $pow);
    }
    $pow <<= 1;
  }
}

# sub ith {
#   my ($self, $i) = @_;
#   return ($radix ** $i - 1) / ($radix - 1) * $digit;
# }

1;
__END__
