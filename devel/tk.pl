#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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

use 5.010;
use strict;
use warnings;
use Tk;
use Scalar::Util;

# uncomment this to run the ### lines
use Smart::Comments;

{
  use FindBin;
  my $progname = $FindBin::Script;

  my $mw = MainWindow->new;

  my $id = $mw->after(10_000, sub { print "after\n"; });
  Scalar::Util::weaken($id);
  # ### $id

  use Devel::FindRef;
  print Devel::FindRef::track($id);


  my @ret = $mw->afterInfo($id);
  ### @ret

  MainLoop;
  exit 0;
}

{
  # after, repeat, idle

  package Tk::Perl::AfterObject;
  sub new {
    my ($class, $widget, $ms, $repeat) = @_;
    my $self = bless { widget => $widget }, $class;
    Scalar::Util::weaken($self->{'widget'});
    my $method = ($ms eq 'idle' ? 'afterIdle'
                  : ($repeat||'') eq 'repeat' ? 'repeat' : 'after');
    $self->{'id'} = $widget->$method($ms,$callback,$type);
    return $self;
  }
  sub DESTROY {
    my ($self) = @_;
    $self->cancel;
  }
  sub cancel {
    my ($self) = @_;
    if (my $id = $self->{'id'}) {
      $id->cancel;
    }
  }
  sub info {
    my ($self) = @_;
    if (my $id = $self->{'id'}) {
      return $id->afterInfo;
    } else {
      return;
    }
  }
  sub time {
    my ($self, $ms) = @_;
    if (my $id = $self->{'id'}) {
      if ($ms == 0) {
        $self->cancel;
      } else {
        $id->time ($ms);
      }
    } else {
      return;
    }
  }
}
