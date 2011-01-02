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

package App::MathImage::Values::Tribonacci;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesSparse';

use vars '$VERSION';
$VERSION = 38;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Tribonacci Numbers');
use constant description => __('Tribonacci numbers 1, 1, 1, 3, 5, 9, 17, 31, 57, 105, being T(i) = T(i-1) + T(i-2) + T(i-3) starting from 1,1,1.');
use constant oeis => 'A000073'; # tribonacci

sub new {
  my ($class, %options) = @_;
  return $class->SUPER::new (%options,
                             f0 => 1,
                             f1 => 1,
                             f2 => 1);
}
sub next {
  my ($self) = @_;
  ### Tribonacci next(): "$self->{'f0'} $self->{'f1'} $self->{'f2'}"
  (my $ret,
   $self->{'f0'},
   $self->{'f1'},
   $self->{'f2'})
   = ($self->{'f0'},
      $self->{'f1'},
      $self->{'f2'},
      $self->{'f0'}+$self->{'f1'}+$self->{'f2'});
  return $ret;
}

1;
__END__
