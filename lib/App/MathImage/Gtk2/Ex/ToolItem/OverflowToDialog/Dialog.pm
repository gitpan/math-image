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

package App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog::Dialog;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 41;

use Glib::Object::Subclass
  'Gtk2::Dialog',
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

  my $label = $self->{'label'} = Gtk2::Label->new ('');
  $label->show;
  $self->vbox->pack_start ($label, 0,0,0);

  my $child_vbox = $self->{'child_vbox'} = Gtk2::VBox->new;
  $child_vbox->show;
  $self->vbox->pack_start ($child_vbox, 1,1,0);

  $self->set (destroy_with_parent => 1);
  $self->add_buttons ('gtk-close' => 'close');

  # connect to self instead of a class handler since as of Gtk2-Perl 1.223 a
  # Gtk2::Dialog class handler for 'response' is called with response IDs as
  # numbers, not enum strings like 'accept'
  $self->signal_connect (response => \&_do_response);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### ToolItem-Entry SET_PROPERTY: $pspec->get_name
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;
  if ($self->{'toolitem'}) {
    # so toolitem will destroy on unreferenced
    Scalar::Util::weaken ($self->{'toolitem'});

    $self->{'child_vbox'}->set (sensitive => $newval->get('sensitive'));
    if ($newval->find_property('tooltip_text')) { # new in Gtk 2.12
      $self->{'child_vbox'}->set (tooltip_text => $newval->get('tooltip_text'));
      ### initial tooltip: $self->{'child_vbox'}->get('tooltip_text')
    }
  }
}

sub _do_destroy {
  my ($self) = @_;
  ### OverflowToDialog _do_destroy()

  if (my $toolitem = $self->{'toolitem'}) {
    # toolitem to create a new dialog next time required, even if someone
    # else is keeping the destroyed $self alive for a while
    delete $toolitem->{'dialog'};
  }
  _do_unmap($self); # put the child_widget back
}

sub _do_response {
  my ($self, $response) = @_;
  ### OverflowToDialog _do_response(): $response

  if ($response eq 'close') {
    $self->signal_emit ('close');
  }
}

sub _do_map {
  my ($self) = @_;
  if (! $self->{'child_widget'}) {
    if (my $toolitem = $self->{'toolitem'}) {
      if (my $child_widget = $self->{'child_widget'} = $toolitem->get_child) {
        $toolitem->remove ($child_widget);
        $self->{'child_vbox'}->pack_start ($child_widget, 1,1,0);
      }
    }
  }
  shift->signal_chain_from_overridden (@_);
}
sub _do_unmap {
  my ($self) = @_;
  if (my $child_widget = $self->{'child_widget'}) {
    if (my $parent = $child_widget->get_parent) {
      $parent->remove ($child_widget);
    }
    if (my $toolitem = $self->{'toolitem'}) {
      $toolitem->add ($child_widget);
    }
  }
  shift->signal_chain_from_overridden (@_);
}

sub present_for_menuitem {
  my ($self, $menuitem) = @_;
  if ($self->can('set_screen')) { # new in Gtk 2.2
    $self->set_screen ($menuitem->get_screen);
  }
  $self->present;
}

1;
__END__

=for stopwords Gtk Gtk2 Perl-Gtk ToolItem Gtk toolitem

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog::Dialog -- toolitem overflow dialog

=head1 DESCRIPTION

This is an internal part of
C<App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog> not meant for other
use.

=cut
