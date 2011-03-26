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

package App::MathImage::NumSeq::Sparse;
use 5.004;
use strict;
use warnings;

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 49;

# uncomment this to run the ### lines
#use Smart::Comments;

sub is_type {
  my ($self, $type) = @_;
  if ($type eq 'sparse') {
    return 1;
  } else {
    return $self->SUPER::is_type($type);
  }
}

sub new {
  my $class = shift;
  ### Sparse new()
  my $self = $class->SUPER::new (pred_array => [],
                                 pred_hash  => {},
                                 pred_value => -1,
                                 @_);
  my $lo = $self->{'lo'};
  ### $lo
  ### f0: $self->{'f0'}

  if (defined $self->{'f0'}) {
    while ($self->{'f0'} < $lo) {
      ### Sparse next() for f0<lo
      $self->next;
    }
  }
  return $self;
}
sub ith {
  my ($self, $i) = @_;
  ### pred_array last: $#{$self->{'pred_array'}}
  while ($#{$self->{'pred_array'}} < $i) {
    _extend ($self);
  }
  ### pred_array: $self->{'pred_array'}
  return $self->{'pred_array'}->[$i];
}

sub pred {
  my ($self, $value) = @_;
  ### Sparse pred(): $value
  while ($self->{'pred_value'} < $value
         || $self->{'pred_value'} < 10) {
    _extend ($self);
  }
  ### pred_hash: $self->{'pred_hash'}
  ### Sparse pred result: exists($self->{'pred_hash'}->{$value})
  return exists($self->{'pred_hash'}->{$value});
}

sub _extend {
  my ($self) = @_;
  ### Sparse _extend()
  my $iter = ($self->{'pred_iter'} ||= do {
    ### Sparse create pred_iter
    my $class = ref $self;
    my $it = $class->new (%$self);
    # while ($self->{'pred_value'} < 10) {
    #   my ($i, $pred_value) = $it->next;
    #   $self->{'pred_hash'}->{$self->{'pred_value'}=$pred_value} = undef;
    # }
    # ### $it
    $it
  });
  my ($i, $value) = $iter->next;
  ### $i
  ### $value
  if ($value >= $self->{'lo'}) {
    $self->{'pred_value'} = $value;
    $self->{'pred_array'}->[$i] = $value;
    $self->{'pred_hash'}->{$value} = undef;
  }
}

1;
__END__
