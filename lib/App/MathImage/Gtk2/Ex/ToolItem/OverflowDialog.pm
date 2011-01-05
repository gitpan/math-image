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

package App::MathImage::Gtk2::Ex::ToolItem::OverflowDialog;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 39;

use Glib::Object::Subclass
  'Gtk2::MessageDialog',
  signals => { map => \&_do_map,
               unmap => \&_do_unmap,
               destroy => \&_do_destroy,
             },
  properties => [ Glib::ParamSpec->object
                  ('toolitem',
                   'Tool item object',
                   'Blurb.',
                   'Gtk2::ToolItem',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;

  $self->set (message_type => 'other',
              destroy_with_parent => 1);
  $self->add_buttons ('gtk-close' => 'close');

  # connect to self instead of a class handler since as of Gtk2-Perl 1.200 a
  # Gtk2::Dialog class handler for 'response' is called with response IDs as
  # numbers, not enum strings like 'accept'
  $self->signal_connect (response => \&_do_response);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### ToolItem-Entry SET_PROPERTY: $pspec->get_name
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;

  if ($pname eq 'toolitem') {
    if (Gtk2::Widget->find_property('tooltip-text')) {
      # tooltip-text new in Gtk 2.12
      $self->{'connp'} = $newval && Gtk2::Ex::ConnectProperties->dynamic
        ([$newval, 'tooltip-text']
         [$self->vbox, 'tooltip-text', write_only=>1]);
    }
  }
}

sub _do_destroy {
  my ($self) = @_;
  ### ToolItem-OverflowDialog _do_destroy()
  _do_unmap($self); # put the content back
}

sub _do_response {
  my ($self, $response) = @_;
  ### ToolItem-OverflowDialog _do_response(): $response

  if ($response eq 'close') {
    if (my $content = delete $self->{'content'}) {
      if (my $parent = $content->get_parent) {
        $parent->remove ($content);
      }
      my $toolitem = $self->{'toolitem'};
      $toolitem->add ($content);
    }
    $self->signal_emit ('close');
  }
}

sub _do_map {
  my ($self) = @_;
  if (! $self->{'content'}) {
    if (my $toolitem = $self->{'toolitem'}) {
      if (my $content = $self->{'content'} = $toolitem->get_child) {
        $toolitem->remove ($content);
        $self->vbox->pack_start ($content, 1,1,0);
      }
    }
  }
  shift->signal_chain_from_overridden (@_);
}
sub _do_unmap {
  my ($self) = @_;
  if (my $content = $self->{'content'}) {
    if (my $parent = $content->get_parent) {
      $parent->remove ($content);
    }
    if (my $toolitem = $self->{'toolitem'}) {
      $toolitem->add ($content);
    }
  }
  shift->signal_chain_from_overridden (@_);
}

sub make_menuitem {
  my ($self, ) = @_;

  my $entry = $self->{'entry'};
  my $menuitem = Gtk2::MenuItem->new_with_label ($self->get('label'));
  $menuitem->set (visible => 1,
                  sensitive => $self->get('sensitive'));
  Scalar::Util::weaken (my $weak_self = $self);
  $menuitem->signal_connect (activate => \&_do_menu_activate, \$weak_self);
  ### menuitem visible: $menuitem->get('visible')
  ### menuitem sensitive: $menuitem->get('sensitive')
  $self->set_proxy_menu_item (__PACKAGE__, $menuitem);

  # $menuitem->signal_connect (notify => sub {
  #                              my ($self, $pspec) = @_;
  #                              ### menuitem notify: $pspec->get_name
  #                            });

  return 1;
}

sub _do_menu_activate {
  my ($menuitem, $ref_weak_self) = @_;
  my $self = $$ref_weak_self || return;
  ### ToolItem-Entry _do_menu_activate(): $self->get('label')

  my $dialog = $self->{'dialog'};
  if (! $dialog) {

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

1;
__END__
