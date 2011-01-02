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

our $VERSION = 38;

use Glib::Object::Subclass
  'Gtk2::ToolItem',
  signals => { create_menu_proxy => \&_do_create_menu_proxy,
               notify => \&_do_notify,
               hierarchy_changed => \&_do_hierarchy_changed,
             },
  properties => [ Glib::ParamSpec->string
                  ('label',
                   'Label',
                   'Blurb.',
                   'Entry',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('entry',
                   'entry',
                   'Blurb.',
                   'Gtk2::Widget',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;

  my $entry = $self->{'entry'} = Gtk2::Entry->new;
  $entry->show;
  $self->add ($entry);
}

sub FINALIZE_INSTANCE {
  my ($self) = @_;
  if (my $dialog = $self->{'dialog'}) {
    $dialog->destroy;
  }
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
  ### ToolItem-Entry _do_notify(): $pname
  if ($pname eq 'sensitive' || $pname eq 'tooltip_text') {
    if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
      $menuitem->set ($pname => $self->get($pname));
    }
  }
}

sub _do_hierarchy_changed {
  my ($self, $pspec) = @_;
  ### ToolItem-Entry _do_hierarchy_changed()
  if (my $dialog = $self->{'dialog'}) {
    my $toplevel = $self->get_toplevel;
    if (! $toplevel->toplevel) { undef $toplevel; }
    $dialog->set_transient_for ($toplevel);
  }
}

sub _do_create_menu_proxy {
  my ($self) = @_;
  ### ToolItem-Entry _do_create_menu_proxy(): $self->get('label')
  ### visible: $self->get('visible')

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
    require App::MathImage::Gtk2::Ex::ToolItem::OverflowDialog;
    $dialog = $self->{'dialog'}
      = App::MathImage::Gtk2::Ex::ToolItem::OverflowDialog->new
        (toolitem => $self,
         transient_for => $self->get_toplevel);
    Scalar::Util::weaken ($self->{'dialog'});
  }
  if ($dialog->can('set_screen')) { # new in Gtk 2.2
    $dialog->set_screen ($menuitem->get_screen);
  }
  $dialog->present;
}

1;
__END__

=for stopwords Gtk Gtk2 Perl-Gtk ToolItem Gtk toolitem boolean

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::Entry -- toolitem for a Gtk2::Entry widget

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
