# FIXME: cache _totient() or this is a bit slow, esp pred()


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

package App::MathImage::Values::Sequence::TotientSum;
use 5.004;
use strict;
use List::Util 'min', 'max';

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';

use vars '$VERSION';
$VERSION = 64;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => __('Sum of totient(1..n).');
use constant characteristic_monotonic => 1;
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
  return ($i, $self->{'sum'} += _totient($i));
}

sub ith {
  my ($self, $i) = @_;
  ### TotientSteps ith(): $i
  my $sum = 0;
  foreach my $n (1 .. $i) {
    $sum += _totient($n);
  }
  return $sum;
}
sub pred {
  my ($self, $value) = @_;
  ### TotientSteps ith(): $i
  my $sum = 0;
  for (my $n = 0; ; $n++) {
    if ($sum == $value) {
      return 1;
    }
    if ($sum > $value) {
      return 0;
    }
    $sum += _totient($n);
  }
}

sub _totient {
  my ($x) = @_;
  my $count = (($x >= 1)                    # y=1 always
               + ($x > 2 && ($x&1))         # y=2 if $x odd
               + ($x > 3 && ($x % 3) != 0)  # y=3
               + ($x > 4 && ($x&1))         # y=4 if $x odd
              );
  for (my $y = 5; $y < $x; $y++) {
    $count += _coprime($x,$y);
  }
  return $count;
}
sub _coprime {
  my ($x, $y) = @_;
  #### _coprime(): "$x,$y"
  if ($y > $x) {
    return 0;
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
