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

package App::MathImage::Gtk2::Ex::ToolItem::Entry;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use Gtk2::Ex::ContainerBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 29;

use Glib::Object::Subclass
  'Gtk2::ToolItem',
  signals => { create_menu_proxy => \&_do_create_menu_proxy,
               notify => \&_do_notify,
               hierarchy_changed => \&_do_hierarchy_changed,
             },
  properties => [ Glib::ParamSpec->string
                  ('label',
                   'label',
                   'Blurb.',
                   'Entry',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('entry',
                   'entry',
                   'Blurb.',
                   'Gtk2::Widget',
                   Glib::G_PARAM_READWRITE),,
                ];

sub INIT_INSTANCE {
  my ($self) = @_;

  my $entry = $self->{'entry'} = Gtk2::Entry->new;
  $entry->show;
  $self->add ($entry);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### ToolItem-Entry SET_PROPERTY: $pspec->get_name
  my $pname = $pspec->get_name;

  if ($pname eq 'label') {
    if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
      $menuitem->set_label ($newval);
    }
    if (my $dialog = $self->{'dialog'}) {
      $dialog->set_text ($newval);
    }
  }

  if ($pname eq 'entry') {
    my $entry = $self->{'entry'};
    if (my $old_entry = $self->get_child) {
      $self->remove ($old_entry);
      $self->add ($newval);
    } elsif (my $dialog = $self->{'dialog'}) {
      my $vbox = $dialog->vbox;
      Gtk2::Ex::ContainerBits::remove_widgets ($vbox, $entry);
      $dialog->vbox->pack_start ($vbox, 1,1,0);
    }
  }

  $self->{$pname} = $newval;
}

sub _do_notify {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  if ($pname eq 'visible' || $pname eq 'sensitive') {
    if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
      $menuitem->set ($pname => $self->get($pname));
    }
  }
}

sub _do_hierarchy_changed {
  my ($self, $pspec) = @_;
  # follow to the new parent
  if (my $dialog = $self->{'dialog'}) {
    my $toplevel = $self->get_toplevel;
    if (! $toplevel->toplevel) { undef $toplevel; }
    $dialog->set_transient_for ($toplevel);
  }
}

sub _do_create_menu_proxy {
  my ($self) = @_;
  ### ToolItem-Entry _do_create_menu_proxy(): $self->get('label')
  my $entry = $self->{'entry'};
  my $menuitem = Gtk2::MenuItem->new_with_label ($self->get('label'));
  $menuitem->set (visible => $self->get('visible'),
                  sensitive => $self->get('sensitive'));
  Scalar::Util::weaken (my $weak_self = $self);
  $menuitem->signal_connect (activate => \&_do_menu_activate, \$weak_self);
  ### visible: $menuitem->get('visible')
  ### sensitive: $menuitem->get('sensitive')
  $self->set_proxy_menu_item (__PACKAGE__, $menuitem);
  return 1;
}

sub _do_menu_activate {
  my ($menuitem, $ref_weak_self) = @_;
  my $self = $$ref_weak_self || return;
  ### ToolItem-Entry _do_menu_activate(): $self->get('label')

  my $dialog = $self->{'dialog'};
  if (! $dialog) {
    $dialog = $self->{'dialog'}
      = Gtk2::MessageDialog->new ($self->get_toplevel,
                                  ['destroy-with-parent'],
                                  'other', # message type
                                  'close', # buttons
                                  '%s', $self->get('label'));
    $dialog->signal_connect (response => \&_do_dialog_response, $ref_weak_self);

    my $entry = $self->{'entry'};
    if (my $parent = $entry->get_parent) {
      $parent->remove ($entry);
    }
    $dialog->vbox->pack_start ($entry, 1,1,0);
  }
  if ($dialog->can('set_screen')) { # new in Gtk 2.2
    $dialog->set_screen ($menuitem->get_screen);
  }
  $dialog->present;
}

sub _do_dialog_response {
  my ($dialog, $response, $ref_weak_self) = @_;
  my $self = $$ref_weak_self || return;
  ### ToolItem-Entry _do_dialog_response(): "$self"

  if ($response eq 'close') {
    my $entry = $self->{'entry'};
    if (my $parent = $entry->get_parent) {
      $parent->remove ($entry);
    }
    $self->add ($entry);
    $dialog->signal_emit ('close');
  }
}

1;
__END__

=for stopwords Gtk Gtk2 Perl-Gtk ToolItem Gdk Pixbuf Gtk

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::Entry -- toolitem for Gdk Pixbuf file types

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ToolItem::Entry;
 my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ToolItem::Entry> is a subclass of
C<Gtk2::ToolItem>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ToolItem
            App::MathImage::Gtk2::Ex::ToolItem::Entry

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::ToolItem::Entry> ...

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ToolItem::Entry->new (key=>value,...) >>

Create and return a new toolitem object.  Optional key/value pairs set
initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<active> (boolean, default false)

=back

=cut
