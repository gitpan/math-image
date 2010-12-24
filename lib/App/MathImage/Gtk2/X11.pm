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


package App::MathImage::Gtk2::X11;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2 1.220;
use Scalar::Util;

use Glib::Ex::SourceIds;

# uncomment this to run the ### lines
#use Smart::Comments '###';

our $VERSION = 37;

sub new {
  my ($class, %self) = @_;
  my $self = bless \%self, $class;

  my $gdk_window = $self{'gdk_window'};
  my $x11_window = $self->{'x11_window'} = $gdk_window->XID;
  my $display_name = ($gdk_window->can('get_display')
                      ? $gdk_window->get_display->get_name  # gtk 2.2 up
                      : Gtk2::Gdk->get_display);        # gtk 2.0.x

  require X11::Protocol;
  my $X = $self->{'X'} = X11::Protocol->new ($display_name);
  my $colormap = $X->{'default_colormap'};

  Scalar::Util::weaken (my $weak_self = $self);
  $self->{'io_watch'} = Glib::Ex::SourceIds->new
    (Glib::IO->add_watch (fileno($X->{'connection'}->fh),
                          ['in', 'hup', 'err'],
                          \&_do_read,
                          \$weak_self,
                          Gtk2::GDK_PRIORITY_REDRAW() + 10));
  ### fileno: fileno($X->{'connection'}->fh)

  my ($width, $height)  = $gdk_window->get_size;

  require App::MathImage::Generator::X11;
  $self->{'x11gen'} = App::MathImage::Generator::X11->new
    (%{$self->{'gen'}},
     X => $X,
     window => $x11_window,
     width => $width,
     height => $height);

  return $self;
}

sub _do_read {
  my ($fd, $conditions, $ref_weak_self) = @_;
  ### X11 _do_read()
  my $self = $$ref_weak_self || return Glib::SOURCE_REMOVE;
  my $X = $self->{'X'} || return Glib::SOURCE_REMOVE;
  $X->handle_input;

  if (my $x11gen = $self->{'x11gen'}) {
    if (defined $x11gen->{'reply'}) {
      undef $self->{'reply'};

      my $seq = $X->send('QueryPointer', $X->{'root'});
      $X->add_reply($seq, \$self->{'reply'});
      $X->flush;

      if (! $x11gen->draw_steps) {
        ### X11 _do_read() finished
        delete $self->{'x11gen'};
      }
    }
  } else {
    delete $self->{'X'};
    $X->close;
    return Glib::SOURCE_REMOVE;
  }

  return Glib::SOURCE_CONTINUE;
}

1;
__END__
