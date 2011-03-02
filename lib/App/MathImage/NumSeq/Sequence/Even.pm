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

package App::MathImage::NumSeq::Sequence::Even;
use 5.004;
use strict;
use warnings;
use POSIX 'ceil';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 46;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Even Integers');
use constant description => __('The even integers 2, 4, 6, 8, 10, etc.');
use constant values_min => 0;
use constant oeis => 'A005843';
# OeisCatalogue: A005843

sub new {
  my ($class, %self) = @_;
  if (defined $self{'lo'}) {
    $self{'lo'} = ceil($self{'lo'});   # next integer
    $self{'lo'} += ($self{'lo'} & 1);  # next even, if not already even
  } else {
    $self{'lo'} = 0;
  }
  my $self = bless \%self, $class;
  $self->rewind;
  return $self;
}
sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->{'lo'} - 2;
}
sub next {
  my ($self) = @_;
  return $self->{'i'} += 2;
}
sub pred {
  my ($class_or_self, $n) = @_;
  ### Even pred(): $n
  return ! ($n & 1);
}
sub ith {
  my ($self, $i) = @_;
  return $self->{'lo'} + 2*$i;
}

1;
__END__
