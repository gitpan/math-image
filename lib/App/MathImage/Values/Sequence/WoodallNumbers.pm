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

package App::MathImage::Values::Sequence::WoodallNumbers;
use 5.004;
use strict;

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';
use App::MathImage::Values::Base::Digits;

use vars '$VERSION';
$VERSION = 64;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('WoodallNumbers');
use constant description => __('Woodall numbers n*2^n-1.');
use constant values_min => 1;
use constant i_start => 1; # from 1*2^1-1==1

# cf A002234 - Woodall primes
#    A050918 - n for the Woodall primes
#    A056821 - totient(woodall)
use constant oeis_anum => 'A003261';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub pred {
  my ($self, $value) = @_;
  ### WoodallNumbers pred(): $value
  ($value >= 1 && $value & 1) or return 0;
  my $exp = 0;
  $value += 1;  # now seeking $value == $exp * 2**$exp
  for (;;) {
    if ($value <= $exp || $value & 1) {
      return ($value == $exp);
    }
    $value >>= 1;
    $exp++;
  }
}
sub ith {
  my ($self, $i) = @_;
  return $i * 2**$i - 1;
}

1;
__END__
