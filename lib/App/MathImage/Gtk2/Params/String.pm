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


package App::MathImage::Gtk2::Params::String;
use 5.008;
use strict;
use warnings;
use Carp;
use POSIX ();
use Glib;
use Gtk2;
use Glib::Ex::ObjectBits 'set_property_maybe';

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 55;

use Gtk2::Ex::ToolItem::OverflowToDialog;
use Glib::Object::Subclass
  'Gtk2::Ex::ToolItem::OverflowToDialog',
  properties => [ Glib::ParamSpec->string
                  ('value',
                   'Value',
                   'Blurb.',
                   '', # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->scalar
                  ('parameter-info',
                   'Parameter Info',
                   'Blurb.',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  if ($pname eq 'value') {
    return $self->{'entry'}->get_text;

  } else {
    return $self->{$pname};
  }
}
sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### Float SET_PROPERTY: $pname

  if ($pname eq 'value') {
    return $self->{'entry'}->set_value ($newval);
  } else {
    my $oldval = $self->{$pname};
    $self->{$pname} = $newval;

    my $entry_class = 'Gtk2::Entry';
    if (($newval->{'type_hint'}||'') eq 'oeis_anum') {
      require App::MathImage::Gtk2::OeisEntry;
      $entry_class = 'App::MathImage::Gtk2::OeisEntry';
    }
    my $entry = $self->{'entry'} = $entry_class->new;
    Scalar::Util::weaken (my $weak_self = $self);
    $entry->signal_connect (activate => \&_do_entry_activate, \$weak_self);
    $entry->show;
    $self->add ($entry);

    if (! $oldval) {
      $entry->set_text ($newval->{'default'});
    }
    $entry->set (width_chars => $newval->{'width'} || 5);

    my $display = ($newval->{'display'} || $newval->{'name'});
    $self->set (overflow_mnemonic =>
                Gtk2::Ex::MenuBits::mnemonic_escape($display));

    set_property_maybe ($self, # tooltip-text new in 2.12
                        tooltip_text => $newval->{'description'});
  }
}

sub _do_entry_activate {
  my ($adj, $pspec, $ref_weak_self) = @_;
  my $self = $$ref_weak_self || return;
  $self->notify ('value');
}

1;
__END__
