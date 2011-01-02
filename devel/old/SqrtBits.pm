# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::SqrtBits;
use 5.004;
use strict;
use warnings;
use Carp;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 38;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Square Root Bits');
use constant description => __('The square root of a given number written out in binary.');

# A004539 - sqrt2 binary bits
# A002193 - sqrt2 decimal
#
# A002194 - sqrt3 decimal
# A002163 - sqrt5 decimal
# A010470 - sqrt13 decimal

sub new {
  my ($class, %options) = @_;
  ### SqrtBits new()
  my $lo = $options{'lo'} || 0;

  my $str = '';
  my $sqrt = 2;
  if (defined $options{'sqrt'}) {
    if ($options{'sqrt'} =~ m{^\s*(\d*)\s*$}) {
      if ($1 ne '') {
        $sqrt = $1;
      }
    } else {
      croak "Unrecognised SqrtBits parameter: $options{'sqrt'}";
    }
  }

  unless (Math::BigInt->can('new')) {
    require Math::BigInt;
    Math::BigInt->import (try => 'GMP');
  }
  my $calcbits = int(2*$options{'hi'} + 32);
  $sqrt = Math::BigInt->new($sqrt);
  $sqrt->blsft ($calcbits);
  $sqrt->bsqrt();

  $str = $sqrt->as_bin;
  $str = substr ($str, 2); # trim 0b
  ### SqrtBits string: $str

  return bless { i      => $lo-1,
                 string => $str,
               }, $class;
}
sub next {
  my ($self) = @_;
  ### SqrtBits next(): $self->{'i'}+1
  for (;;) {
    my $i = ++$self->{'i'};
    if ($i >= length($self->{'string'})) {
      return;
    }
    if (substr ($self->{'string'},$i,1)) {
      return $i;
    }
  }
}
sub pred {
  my ($self, $n) = @_;
  return substr ($self->{'string'},$n,1);
}

1;
__END__
