# FIXME: cache _totient() or this is too slow


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

package App::MathImage::NumSeq::Sequence::TotientSteps;
use 5.004;
use strict;
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Sequence::TotientSum;

use vars '$VERSION';
$VERSION = 60;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => __('Number of steps to reach 1 applying the totient function.');
use constant characteristic_count => 1;
use constant values_min => 1;
use constant i_start => 1;

use constant oeis_anum => 'A003434';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

sub ith {
  my ($self, $i) = @_;
  ### TotientSteps ith(): $i
  my $count = 0;
  for (;;) {
    if ($i <= 1) {
      return $count;
    }
    $i = App::MathImage::NumSeq::Sequence::TotientSum::_totient($i);
    $count++;
  }
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 1);
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
