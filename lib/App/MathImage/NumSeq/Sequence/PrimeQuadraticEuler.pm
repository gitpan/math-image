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

package App::MathImage::NumSeq::Sequence::PrimeQuadraticEuler;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 53;

use constant name => __('Prime Generating Quadratic of Euler');
use constant description => __('The quadratic numbers 41, 43, 46, 51, etc, k^2 + k + 41.  The first 40 of these are primes.');
use constant values_min => 41;
# use constant oeis_anum => 'A005846'; # the prime ones

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, ($i + 1)*$i + 41);
}
sub ith {
  my ($self, $i) = @_;
  return ($i + 1)*$i + 41;
}
sub pred {
  my ($class_or_self, $n) = @_;
  return ($n >= 41
          && do {
            my $i = sqrt($n - 40.75) - 0.5;
            ($i==int($i))
          });
}

1;
__END__
