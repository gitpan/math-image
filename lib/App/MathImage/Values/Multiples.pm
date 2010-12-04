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

package App::MathImage::Values::Multiples;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 35;

use constant name => __('Multiples of a given K');
use constant description => __('The multiples K, 2*K, 3*K, 4*K, etc of a given number.');
use constant parameters => { multiples => { type => 'integer',
                                            default => 29,
                                          }
                           };

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $multiples = $options{'multiples'}
    || $class->parameters->{'multiples'}->{'default'};
  return bless { i => ceil ($lo / abs($multiples)),
                 multiples => $multiples,
               }, $class;
}
sub next {
  my ($self) = @_;
  return $self->{'i'}++ * $self->{'multiples'};
}
sub pred {
  my ($self, $n) = @_;
  return (($n % $self->{'multiples'}) == 0);
}
sub ith {
  my ($self, $i) = @_;
  return $i * $self->{'multiples'};
}

1;
__END__
