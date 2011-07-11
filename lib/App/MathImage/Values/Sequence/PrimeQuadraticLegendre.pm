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

package App::MathImage::Values::Sequence::PrimeQuadraticLegendre;
use 5.004;
use strict;

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';

use vars '$VERSION';
$VERSION = 63;

use constant name => __('Prime Generating Quadratic of Legendre');
use constant description => __('The quadratic numbers 2*k^2 + 29.');
use constant values_min => 29;

# http://oeis.org/A007641  # only the prime ones
# use constant oeis_anum => undef;

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, 2*$i*$i + 29);
}
sub ith {
  my ($self, $i) = @_;
  return 2*$i*$i + 29;
}
sub pred {
  my ($self, $n) = @_;
  return ($n >= 29
          && do {
            my $i = sqrt($n*.5 - 14.5);
            ($i==int($i))
          });
}

1;
__END__
