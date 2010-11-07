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

package App::MathImage::Values::Cubes;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 29;

use constant name => __('Cubes');
use constant description => __('The cubes 1, 8, 27, 64, 125, etc, k*k*k.');

sub new {
  my ($class, %self) = @_;
  require Math::Libm;
  if (! defined $self{'lo'}) {
    $self{'lo'} = 0;
  }
  my $self = bless \%self, $class;
  $self->rewind;
  return $self;
}
sub rewind {
  my ($self) = @_;
  $self->{'i'} = ceil (Math::Libm::cbrt (max(0,$self->{'lo'})));
}
sub next {
  my ($self) = @_;
  return $self->{'i'}++ ** 3;
}
sub pred {
  my ($self, $n) = @_;
  $n = Math::Libm::cbrt ($n);
  return ($n == int($n));
}
sub ith {
  my ($self, $i) = @_;
  return $i*$i*$i;
}

1;
__END__
