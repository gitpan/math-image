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

package App::MathImage::Values::Tetrahedral;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesSparse';

use vars '$VERSION';
$VERSION = 31;

use constant name => __('Tetrahedral');
use constant description => __('The tetrahedral numbers 1, 4, 10, 20, 35, 56, 84, 120, etc, k*(k+1)*(k+2)/6.');

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  require Math::Libm;
  return bless { i => 1,
                 lo => $lo,
               }, $class;
}
sub next {
  my ($self) = @_;
  return $self->ith($self->{'i'}++);
}
# sub pred {
#   my ($self, $n) = @_;
#   $n = Math::Libm::cbrt ($n);
#   return ($n == int($n));
# }
sub ith {
  my ($self, $i) = @_;
  return $i*($i+1)*($i+2)/6;
}

1;
__END__