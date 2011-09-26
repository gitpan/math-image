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



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 


package App::MathImage::NumSeq::TotientSum;
use 5.004;
use strict;
use List::Util 'min', 'max';

use Math::NumSeq;
use base 'Math::NumSeq';

use App::MathImage::NumSeq::Totient;
*_totient_by_sieve = \&App::MathImage::NumSeq::Totient::_totient_by_sieve;

use vars '$VERSION';
$VERSION = 72;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Sum of totient(1..n).');
use constant characteristic_monotonic => 2;
use constant values_min => 0;
use constant i_start => 0;

use constant oeis_anum => 'A002088';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'sum'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->{'sum'} += _totient_by_sieve($self,$i));
}

sub ith {
  my ($self, $i) = @_;
  ### TotientSum ith(): $i
  my $sum = 0;
  foreach my $n (1 .. $i) {
    $sum += _totient($n);
  }
  return $sum;
}
sub pred {
  my ($self, $value) = @_;
  ### TotientSum pred(): $value
  my $sum = 0;
  for (my $n = 0; ; $n++) {
    if ($sum == $value) {
      return 1;
    }
    if ($sum > $value) {
      return 0;
    }
    $sum += _totient_by_sieve($self,$n);
  }
}

1;
__END__
