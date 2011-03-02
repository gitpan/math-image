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

package App::MathImage::NumSeq::Sequence::PrimeQuadraticHonaker;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 46;

use constant name => __('Prime Generating Quadratic of Honaker');
use constant description => __('The quadratic numbers 4*k^2 + 4*k + 59.');
use constant values_min => 59;

# http://oeis.org/A048988  # only the primes ones
# use constant oeis => undef;

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => 0,
               }, $class;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return 4*($i + 1)*$i + 59;
}

sub pred {
  my ($class_or_self, $n) = @_;
  return ($n >= 59
          && do {
            my $i = sqrt((1/4) * $n - 29/2) -1/2;
            ($i==int($i))
          });
}

1;
__END__
