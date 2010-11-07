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

package App::MathImage::Values::Padovan;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesSparse';

use vars '$VERSION';
$VERSION = 29;

use constant name => __('Padovan Numbers');
use constant description => __('Padovan numbers 1, 1, 1, 2, 2, 3, 4, 5, 7, 9, etc, being P(i) = P(i-2) + P(i-3) starting from 1,1,1.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  return $class->SUPER::new (%options,
                             f0 => 1,
                             f1 => 1,
                             f2 => 1);
}
sub next {
  my ($self) = @_;
  ### Padovan next(): "$self->{'f0'} $self->{'f1'} $self->{'f2'}"
  (my $ret,
   $self->{'f0'},
   $self->{'f1'},
   $self->{'f2'})
   = ($self->{'f0'},
      $self->{'f1'},
      $self->{'f2'},
      $self->{'f0'}+$self->{'f1'});
  return ($ret, 1);
}
# sub pred {
#   my ($self, $n) = @_;
#   return (($n >= 0)
#           && do {
#             $n = sqrt($n);
#             $n == int($n)
#           });
# }

1;
__END__
