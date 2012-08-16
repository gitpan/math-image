#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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

package App::MathImage::Tk::Perl::AfterObject;
use 5.008;
use strict;
use Tk;
use Scalar::Util;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 106;

sub new {
  my ($class) = @_;
  return bless { }, $class;
}
sub idle {
  my ($self, $widget, $method, @args) = @_;
  if ($self->type ne 'idle') {
    $self->cancel;
  }
  $self->{'widget'} = $widget;
  Scalar::Util::weaken($self->{'widget'});
  $self->{'method'} = $method;
  if (@args) {
    $self->{'args'} = \@args;
  }
  Scalar::Util::weaken(my $weak_self = $self);
  $self->{'id'} = $widget->afterIdle(\&_do_once, \$weak_self);
}
sub _do_once {
  my ($ref_weak_self) = @_;
  ### AfterObject _do_once(): map {"$_"} @_

  my $self = $$ref_weak_self || return;
  delete $self->{'id'};

  my $widget = $self->{'widget'} || return;
  my $method = $self->{'method'};
  $widget->$method (@{$self->{'args'}});
}


sub after {
  my ($self, $widget, $ms, $method, @args) = @_;
  $self->cancel;
  $self->{'widget'} = $widget;
  Scalar::Util::weaken($self->{'widget'});
  $self->{'method'} = $method;
  if (@args) {
    $self->{'args'} = \@args;
  }
  Scalar::Util::weaken(my $weak_self = $self);
  $self->{'id'} = $widget->after($ms, \&_do_once, \$weak_self);
}

sub DESTROY {
  my ($self) = @_;
  $self->cancel;
}
sub cancel {
  my ($self) = @_;
  ### AfterObject cancel() ...
  if (my $id = delete $self->{'id'}) {
    $id->cancel;
  }
}
sub info {
  my ($self) = @_;
  if (my $widget = $self->{'widget'}) {
    if (my $id = $self->{'id'}) {
      return $widget->afterInfo($id);
    }
  }
  return;
}
sub type {
  my ($self) = @_;
  my $type = '';
  if (my $widget = $self->{'widget'}) {
    if (my $id = $self->{'id'}) {
       (undef,$type) = $widget->afterInfo($id);
    }
  }
  return $type;
}

1;
__END__

L<Tk::After>,
L<Tk::callbacks>
