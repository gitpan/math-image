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

package App::MathImage::Values::Pronic;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 42;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Pronic Numbers');
use constant description => __('The pronic numbers 2, 6, 12, 20, 30, etc, etc, k*(k+1).  These are twice the triangular numbers, and half way between perfect squares.');
use constant oeis => 'A002378';
# OEIS: A002378

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => ceil(_inverse(max(0,$lo))),
               }, $class;
}
sub next {
  my ($self) = @_;
  ### Pronic next(): $self->{'i'}
  return $self->ith($self->{'i'}++);
}
sub pred {
  my ($class_or_self, $n) = @_;
  if ($n < 0) { return 0; }
  my $i = _inverse($n);
  return ($i == int($i));
}
sub ith {
  my ($class_or_self, $i) = @_;
  return $i*($i+1);
}

sub _inverse {
  my ($n) = @_;
  return sqrt($n + .25) - .5;
}

1;
__END__
