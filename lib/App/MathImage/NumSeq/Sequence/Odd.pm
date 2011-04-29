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

package App::MathImage::NumSeq::Sequence::Odd;
use 5.004;
use strict;
use POSIX 'ceil';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence::Even';

use vars '$VERSION';
$VERSION = 54;

use constant name => __('Odd Integers');
use constant description => __('The odd integers 1, 3, 5, 7, 9, etc.');
use constant values_min => 1;
use constant oeis_anum => 'A005408'; # odds

# uncomment this to run the ### lines
#use Smart::Comments;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = ceil (($self->{'lo'}-1) / 2);
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, 2*$i+1);
}
sub ith {
  my ($self, $i) = @_;
  return 2*$i+1; # $self->{'lo'} + 2*$i;
}
sub pred {
  my ($class_or_self, $n) = @_;
  ### Odd pred(): $n
  return ($n & 1);
}

# sub new {
#   my ($class, %self) = @_;
#   if (defined $self{'lo'}) {
#     $self{'lo'} = ceil($self{'lo'});     # next integer
#     $self{'lo'} += ! ($self{'lo'} & 1);  # next odd, if not already odd
#   } else {
#     $self{'lo'} = 1;
#   }
#   my $self = bless \%self, $class;
#   $self->rewind;
#   return $self;
# }

1;
__END__
