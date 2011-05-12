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


package App::MathImage::Gtk2::Params::Boolean;
use 5.008;
use strict;
use warnings;
use Glib;
use Gtk2;
use Glib::Ex::ObjectBits 'set_property_maybe';

our $VERSION = 56;

use Glib::Object::Subclass
  'Gtk2::ToggleToolButton',
  properties => [ Glib::ParamSpec->boolean
                  ('value',
                   'Value',
                   'Blurb.',
                   0,
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->scalar
                  ('parameter-info',
                   'Parameter Info',
                   'Blurb.',
                   Glib::G_PARAM_READWRITE),
                ],
  signals => { notify => \&_do_notify };

sub INIT_INSTANCE {
  my ($self) = @_;
  set_property_maybe ($self->get_child, draw_as_radio => 1);
}

sub _do_notify {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  if ($pname eq 'active') {
    ### Boolean notify value
    $self->notify('value');
  }
}

sub GET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  return $self->get_active;
}
sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  $self->set_active ($newval);
}

1;
__END__
