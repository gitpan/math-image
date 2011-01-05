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

package App::MathImage::Values::Squares;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 39;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Perfect Squares');
use constant description => __('The perfect squares 1,4,9,16,25, etc k*k.');
use constant oeis => 'A000290'; # squares

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
  $self->{'i'} = ceil (sqrt (max(0,$self->{'lo'})));
}
sub next {
  my ($self) = @_;
  ### Squares next(): $self->{'i'}
  return $self->{'i'}++ ** 2;
}
sub pred {
  my ($class_or_self, $n) = @_;
  return (($n >= 0)
          && do {
            $n = sqrt($n);
            $n == int($n)
          });
}
sub ith {
  my ($class_or_self, $i) = @_;
  return $i*$i;
}

1;
__END__
