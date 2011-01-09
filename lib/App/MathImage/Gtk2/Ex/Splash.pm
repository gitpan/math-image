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


package App::MathImage::Gtk2::Ex::Splash;
use 5.008;
use strict;
use warnings;
use List::Util 'max';

our $VERSION = 40;

use Glib::Object::Subclass 'Gtk2::Window',
  signals => { realize => \&_do_realize,
               expose_event => \&_do_expose_event },
  properties => [ Glib::ParamSpec->object ('pixmap',
                                           'Pixmap',
                                           'Blurb.',
                                           'Gtk2::Gdk::Pixmap',
                                           Glib::G_PARAM_READWRITE) ];

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my $class = shift;
  return $class->SUPER::new (type => 'popup', @_);
}

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->set_app_paintable (0);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;

  if ($pname eq 'pixmap') {
    _update_pixmap ($self);
  }
}

sub _do_expose_event {
  my $self = shift;
  ### _do_expose(), no chain to default
}

sub _do_realize {
  my $self = shift;
  ### _do_realize()

  $self->signal_chain_from_overridden (@_);

  my $window = $self->window;
  $window->set_type_hint ('splashscreen');
  _update_pixmap ($self);

  # override_redirect => 1,

#  ### back: $window->get_back_pixmap
}

sub _update_pixmap {
  my ($self) = @_;
  ### _update_pixmap()

  if (my $pixmap = $self->{'pixmap'}) {
    if (my $window = $self->window) {
      ### Splash set_back_pixmap(): "$pixmap"
      $window->set_back_pixmap ($pixmap);
      $window->clear;
    }

    my ($width, $height) = $pixmap->get_size;
    my ($root_width, $root_height) = $self->get_root_window->get_size;
    $self->resize ($width, $height);

    my $x = max (0, int (($root_width - $width) / 2));
    my $y = max (0, int (($root_height - $height) / 2));
    $self->move ($x, $y);

    ### move resize: "$x, $y   $width x $height"
  }
}

sub run {
  my ($class, %options) = @_;
  my $time = delete $options{'time'};
  my $self = $class->new (%options);
  $self->show;
  Glib::Timeout->add (($time||.75) * 1000, sub {
                        Gtk2->main_quit;
                        return Glib::SOURCE_REMOVE();
                      });
  Gtk2->main;
}

1;
__END__
