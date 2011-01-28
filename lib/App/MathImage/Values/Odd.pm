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

package App::MathImage::Values::Odd;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values::Even';

use vars '$VERSION';
$VERSION = 43;

use constant name => __('Odd Integers');
use constant description => __('The odd integers 1, 3, 5, 7, 9, etc.');
use constant values_min => 1;
use constant oeis => 'A005408'; # odds
# OEIS: A005408

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %self) = @_;
  if (defined $self{'lo'}) {
    $self{'lo'} = ceil($self{'lo'});     # next integer
    $self{'lo'} += ! ($self{'lo'} & 1);  # next odd, if not already odd
  } else {
    $self{'lo'} = 1;
  }
  my $self = bless \%self, $class;
  $self->rewind;
  return $self;
}
sub pred {
  my ($class_or_self, $n) = @_;
  ### Odd pred(): $n
  return ($n & 1);
}

1;
__END__
