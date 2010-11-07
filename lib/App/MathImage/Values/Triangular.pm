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

package App::MathImage::Values::Triangular;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 29;

use constant name => __('Triangular Numbers');
use constant description =>  __('The triangular numbers 1, 3, 6, 10, 15, 21, 28, etc, k*(k+1)/2.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  require Math::TriangularNumbers;
  Math::TriangularNumbers->VERSION(1.012); # for Tri()

  my $lo = $options{'lo'} || 0;
  return bless { i => Math::TriangularNumbers::Tri($lo),
               }, $class;
}
sub next {
  my ($self) = @_;
  return Math::TriangularNumbers::T($self->{'i'}++);
}
sub pred {
  my ($self, $n) = @_;
  return Math::TriangularNumbers::is_T($n);
}
sub ith {
  my ($self, $i) = @_;
  return Math::TriangularNumbers::T($i);
}

1;
__END__
