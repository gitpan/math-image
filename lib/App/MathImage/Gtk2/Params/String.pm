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
#use Devel::Comments;

our $VERSION = 66;

use Gtk2::Ex::ToolItem::OverflowToDialog 41; # v.41 fix overflow-mnemonic
use Glib::Object::Subclass
  'Gtk2::Ex::ToolItem::OverflowToDialog',
  properties => [ Glib::ParamSpec->string
                  ('parameter-value',
                   'Parameter Value',
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
  if ($pname eq 'parameter_value') {
    my $child;
    return (($child = $self->get('child-widget'))
            && $child->get('text'));

  } else {
    return $self->{$pname};
  }
}
sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### Params-String SET_PROPERTY: $pname

  if ($pname eq 'parameter_value') {
    $self->{'parameter_value_set'} = $newval;
    if (my $child = $self->get('child-widget')) {
      if (! defined $newval) { $newval = ''; }
      $child->set (text => $newval);
    }

  } else {
    my $oldval = $self->{$pname};
    $self->{$pname} = $newval;

    my $entry = $self->get('child-widget');
    unless ($entry) {
      my $entry_class = 'Gtk2::Entry';
      if (($newval->{'type_hint'}||'') eq 'oeis_anum') {
        require App::MathImage::Gtk2::OeisEntry;
        $entry_class = 'App::MathImage::Gtk2::OeisEntry';
      }
      $entry = $entry_class->new;
      if (exists $self->{'parameter_value_set'}) {
        $entry->set (text => $self->{'parameter_value_set'});
        $self->{'parameter_value_set'} = 1;
      }
      Scalar::Util::weaken (my $weak_self = $self);
      $entry->signal_connect (activate => \&_do_entry_activate, \$weak_self);
      $entry->show;
      $self->add ($entry);
    }
    if (! exists $self->{'parameter_value_set'}) {
      # initial parameter-info
      $self->{'parameter_value_set'} = 1;
      $entry->set (text => $newval->{'default'});
    }
    $entry->set (width_chars => $newval->{'width'} || 5);

    my $display = ($newval->{'display'} || $newval->{'name'});
    $self->set (overflow_mnemonic =>
                Gtk2::Ex::MenuBits::mnemonic_escape($display));
  }
}

sub _do_entry_activate {
  my ($entry, $ref_weak_self) = @_;
  ### Params-String _do_entry_activate()...
  my $self = $$ref_weak_self || return;
  ### parameter-value now: $self->get('parameter-value')
  $self->notify ('parameter-value');
}

1;
__END__
