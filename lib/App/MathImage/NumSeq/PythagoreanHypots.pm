# use prime factorization/sieve

# option for A or B ?



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

package App::MathImage::NumSeq::PythagoreanHypots;
use 5.004;
use strict;

use Math::NumSeq;
use base 'App::MathImage::NumSeq::SumTwoSquares';

use vars '$VERSION';
$VERSION = 78;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Pythagorean Triangle Hypotenuses');
use constant description => Math::NumSeq::__('The hypotenuses of Pythagorean triples, ie. integer h for which x^2+y^2=h^2, for some integers x>=1,y>=1.');
use constant characteristic_monotonic => 2;
use constant values_min => 5;

# cf A002144 - primes 4n+1, the primitive elements of hypots x!=y
#              -1 is a quadratic residue ...
#    A002365 - the "y" of prime "c" ??
#    A002366 - the "x" of prime "c" ??
#    A046083 - the "a" smaller number, ordered by "c"
#    A046084 - the "b" second number, ordered by "c"
#
#    A008846 - primitive hypots, x,y no common factor
#    A004613 - all prime factors are 4n+1
#
#    A009000 - A009003 hypots with repetitions
#    A009012 - "b" second number, ordered by "b", with repetitions
#
use constant oeis_anum => 'A009003'; # hypots, distinct non-zero x,y, inc multiples


sub new {
  my $class = shift;
  return $class->SUPER::new (distinct => 1,
                             @_);
}
sub rewind {
  my ($self) = @_;
  $self->{'pythagorean_i'} = 0;
  $self->SUPER::rewind;
}

sub next {
  my ($self) = @_;
  for (;;) {
    my $n = sqrt ($self->SUPER::next);
    if ($n == int($n)) {
      return ($self->{'pythagorean_i'}++, $n);
    }
  }
}

sub pred {
  my ($self, $n) = @_;
  return $self->SUPER::pred ($n*$n);
}

1;
__END__
