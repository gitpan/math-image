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

package App::MathImage::Values::Sequence::Even;
use 5.004;
use strict;
use POSIX 'ceil';

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';

use vars '$VERSION';
$VERSION = 63;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Even Integers');
use constant description => __('The even integers 2, 4, 6, 8, 10, etc.');
use constant values_min => 0;
use constant oeis_anum => 'A005843';

# sub new {
#   my $class = shift;
#   my $self = $class->SUPER::new (@_);
#   $self->{'lo'} = ceil($self->{'lo'});   # next integer
#   $self->{'lo'} += ($self->{'lo'} & 1);  # next even, if not already even
#   return $self;
# }
sub rewind {
  my ($self) = @_;
  $self->{'i'} = ceil ($self->{'lo'} / 2);
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, 2*$i);
}
sub pred {
  my ($class_or_self, $value) = @_;
  ### Even pred(): $value
  return ! ($value & 1);
}
sub ith {
  my ($self, $i) = @_;
  return 2*$i; # $self->{'lo'} + 2*$i;
}

1;
__END__
