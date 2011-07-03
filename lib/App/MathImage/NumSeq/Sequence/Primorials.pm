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

package App::MathImage::NumSeq::Sequence::Primorials;
use 5.004;
use strict;
use Math::Prime::XS;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Sparse';

use vars '$VERSION';
$VERSION = 62;

use constant name => __('Primorials');
use constant description => __('The primorials 1, 2, 6, 30, 210, etc, 2*3*5*7*...Prime(n).');
use constant values_min => 1;

# cf A034386 product of primes p <= i, so repeating 1, 2, 6, 6, 30, 30,
#
use constant oeis_anum => 'A002110'; # starting at 1

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  ### Primorials rewind()
  $self->{'prime'} = 1;
  $self->{'i'} = 0;
  $self->{'f'} = 1;
}
sub next {
  my ($self) = @_;
  ### Primorials next()
  if (my $i = $self->{'i'}++) {
    my $prime;
    do {
      $prime = $self->{'prime'}++;
    } until (Math::Prime::XS::is_prime($prime));
    return ($i, $self->{'f'} *= $prime);
  } else {
    return (0, 1);
  }
}

1;
__END__
