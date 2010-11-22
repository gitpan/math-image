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

package App::MathImage::ValuesArray;
use 5.004;
use strict;
use warnings;

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 31;

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %self) = @_;
  $self{'i'} = 0;
  my $array = $self{'array'};
  while (@$array && $array->[0] < $self{'lo'}) {
    shift @$array;
  }
  ### shifted to: @$array
  return bless \%self, $class;
}
sub next {
  my ($self) = @_;
  ### ValuesArray next(): $self->{'i'} . ' of ' . scalar(@{$self->{'array'}})
  return $self->{'array'}->[$self->{'i'}++];
}
sub pred {
  my ($self, $n) = @_;
  return exists (($self->{'hash'} ||= do {
    my %h;
    @h{@{$self->{'array'}}} = ();
    ### %h
    \%h
  })->{$n});
}
sub ith {
  my ($self, $i) = @_;
  return $self->{'array'}->[$i];
}

1;
__END__