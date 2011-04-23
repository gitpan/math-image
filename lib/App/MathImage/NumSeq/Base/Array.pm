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

package App::MathImage::NumSeq::Base::Array;
use 5.004;
use strict;

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 52;

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  my $array = $self->{'array'};
  if ($self->{'lo'}) {
    while (@$array && (! defined $array->[0] || $array->[0] < $self->{'lo'})) {
      shift @$array;
    }
  }
  ### shifted to: @$array
  return $self;
}
sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  ### NumSeqArray next(): $self->{'i'} . ' of ' . scalar(@{$self->{'array'}})
  my $array = $self->{'array'};
  my $i;
  for (;;) {
    if (($i = $self->{'i'}++) > $#$array) {
      return;
    }
    if (defined (my $n = $self->{'array'}->[$i])) {
      return ($i, $n);
    }
  }
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
