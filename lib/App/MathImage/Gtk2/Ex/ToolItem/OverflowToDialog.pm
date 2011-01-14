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

package App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog;
use 5.008;
use strict;
use warnings;
use Gtk2;
use Scalar::Util;
use Gtk2::Ex::ContainerBits;
use Gtk2::Ex::MenuBits 35;  # v.35 for mnemonic_escape, mnemonic_undo

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 41;

use Glib::Object::Subclass
  'Gtk2::ToolItem',
  signals => { add => \&_do_add,
               create_menu_proxy => \&_do_create_menu_proxy,
               notify => \&_do_notify,
               hierarchy_changed => \&_do_hierarchy_changed,
             },
  properties => [ Glib::ParamSpec->string
                  ('overflow-mnemonic',
                   'Overflow Mnemonic',
                   'Blurb.',
                   (eval {Glib->VERSION(1.240);1}
                    ? undef # default
                    : ''),  # no undef/NULL before Perl-Glib 1.240
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('child-widget',
                   'Child Widget',
                   'Blurb.',
                   'Gtk2::Widget',
                   Glib::G_PARAM_READWRITE),
                ];

# sub INIT_INSTANCE {
#   my ($self) = @_;
# }

sub FINALIZE_INSTANCE {
  my ($self) = @_;
  ### OverflowToDialog FINALIZE_INSTANCE()
  if (my $menuitem = delete $self->{'menuitem'}) {
    $menuitem->destroy;  # destroy circular MenuItem<->AccelLabel
  }
  if (my $dialog = delete $self->{'dialog'}) {
    $dialog->destroy;  # usual explicit destroy Gtk2::Window
  }
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### ToolItem-OverflowToDialog SET_PROPERTY: $pspec->get_name
  my $pname = $pspec->get_name;

  if ($pname eq 'child_widget') {
    $self->set_child_widget ($newval);

  } else {
    $self->{$pname} = $newval;

    if ($pname eq 'overflow_mnemonic') {
      # propagate
      if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
        $menuitem->set_label (_mnemonic_text ($self));
      }
      _update_dialog_text($self);
    }
  }
}

sub _do_add {
  my ($self, $child) = @_;
  $self->signal_chain_from_overridden ($child);
  $self->set_child_widget ($child);
}

# not documented yet
sub set_child_widget {
  my ($self, $newval) = @_;

  # watch out for recursion from _do_add()
  my $old_child_widget = $self->{'child_widget'};
  return if ((Scalar::Util::refaddr($old_child_widget)||0)
             == (Scalar::Util::refaddr($newval)||0));  # unchanged

  $self->{'child_widget'} = $newval;
  if (my $old_child = $self->get_child) {
    # child currently in the toolitem
    $self->remove ($old_child);
    $self->add ($newval);

  } elsif (my $dialog = $self->{'dialog'}) {
    # child currently in the dialog, replace
    my $child_vbox = $dialog->{'child_vbox'};
    Gtk2::Ex::ContainerBits::remove_widgets ($child_vbox, $old_child_widget);
    $child_vbox->pack_start ($newval, 0,0,0);

  } else {
    $self->add ($newval);
  }
  $self->notify('child_widget');
}

sub _do_notify {
  my ($self, $pspec) = @_;

  ### ToolItem-OverflowToDialog _do_notify(): $pspec->get_name
  $self->signal_chain_from_overridden ($pspec);

  # GtkToolItem notify handler propagates 'sensitive' to the menuitem
  # already (whatever one is currently set_proxy_menu_item())..  The code
  # here sends it to the dialog too.
  my $pname = $pspec->get_name;
  if ($pname eq 'sensitive' || $pname eq 'tooltip_text') {
    foreach my $target ($self->{'menuitem'},
                        $self->{'dialog'} && $self->{'dialog'}->{'child_vbox'}) {
      if ($target) {
        ### propagate sensitive to: "$target"
        $target->set ($pname => $self->get($pname));
      }
    }
  }
}

sub _do_hierarchy_changed {
  my ($self, $pspec) = @_;
  ### ToolItem-OverflowToDialog _do_hierarchy_changed()

  if (my $dialog = $self->{'dialog'}) {
    my $toplevel = $self->get_toplevel;
    $dialog->set_transient_for ($toplevel->toplevel ? $toplevel : undef);
  }
}

sub _do_create_menu_proxy {
  my ($self) = @_;
  ### ToolItem-OverflowToDialog _do_create_menu_proxy()
  ### visible: $self->get('visible')

  $self->{'menuitem'} ||= do {
    my $menuitem = Gtk2::MenuItem->new_with_mnemonic (_mnemonic_text($self));
    $menuitem->set (sensitive => $self->get('sensitive'));
    if ($self->find_property('tooltip_text')) { # new in Gtk 2.12
      $menuitem->set (tooltip_text => $self->get('tooltip_text'));
    }
    Scalar::Util::weaken (my $weak_self = $self);
    $menuitem->signal_connect (activate => \&_do_menu_activate, \$weak_self);
    $menuitem
  };

  $self->set_proxy_menu_item (__PACKAGE__, $self->{'menuitem'});
  return 1;
}
# $menuitem->signal_connect (notify => sub {
#                              my ($self, $pspec) = @_;
#                              ### menuitem notify: $pspec->get_name
#                            });


sub _do_menu_activate {
  my ($menuitem, $ref_weak_self) = @_;
  my $self = $$ref_weak_self || return;
  ### ToolItem-OverflowToDialog _do_menu_activate()

  my $dialog = ($self->{'dialog'} ||= do {
    ### create new dialog
    require App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog::Dialog;
    my $d = $self->{'dialog'}
      = App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog::Dialog->new
        (toolitem => $self);
    _do_hierarchy_changed ($self); # "transient-for"
    _update_dialog_text ($self);
    $d
  });
  $dialog->present_for_menuitem ($menuitem);
}

sub _mnemonic_text {
  my ($self) = @_;
  my $str = $self->{'overflow_mnemonic'};
  if (defined $str) {
    return $str;
  } elsif (my $child_widget = $self->{'child_widget'}) {
    return Gtk2::Ex::MenuBits::mnemonic_escape ($child_widget->get_name);
  } else {
    return '';
  }
}
sub _update_dialog_text {
  my ($self) = @_;
  my $dialog = $self->{'dialog'} || return;
  my $str = $self->{'overflow_mnemonic'};
  # Gtk 2.0.x gtk_label_set_label() didn't allow NULL, so empty ''
  if (! defined $str) { $str = ''; }
  $str = Gtk2::Ex::MenuBits::mnemonic_undo ($str);
  $dialog->{'label'}->set_label ($str);
  $dialog->set_title ($str);
}


#------------------------------------------------------------------------------
# generic

# sub _destroy_proxy_menu_item {
#   my ($toolitem, $menu_item_id) = @_;
# 
#   if (my $menuitem = $toolitem->get_proxy_menu_item ($menu_item_id)) {
#     # can't set undef until Perl-Gtk2 1.240
#     # $toolitem->set_proxy_menu_item (__PACKAGE__, undef);
# 
#     # explicit destroy needed for AccelLabel
#     $menuitem->destroy;
#   }
# }

1;
__END__

=for stopwords Gtk Gtk2 Perl-Gtk ToolItem Gtk toolitem boolean reparenting reparented undescores tooltip

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog -- toolitem overflowing to a dialog

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog;
 my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
 $toolitem->add ($child_widget);

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog> is a subclass of
C<Gtk2::ToolItem>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ToolItem
            App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog

=head1 DESCRIPTION

This ToolItem displays a given child widget in the usual way, and makes an
overflow menu item to display it in a dialog if the toolbar is full.

Overflowing to a separate dialog for each toolitem widget is probably
fantastic from a user interface point of view, but if you don't have any
better ideas then it at least ensures the user can always access the item.

Check boxes, toggles, etc can be done directly in an overflow menu.  See the
usual L<Gtk2::ToggleToolButton>, L<Gtk2::RadioToolButton>, etc, or specifics
like L<Gtk2::Ex::ToolItem::ComboEnum>.

=head2 Implementation

The dialog works by reparenting the child widget to the dialog, and then
putting it back in the toolitem when the dialog is closed or destroyed.

In the current code, when the dialog is open and the toolbar becomes big
enough again to show the toolitem, the dialog is not immediately popped
down.  It may be difficult to be sure the child would be visible again, and
if the toolbar size is jumping about then it might shortly be gone again,
which could be very annoying for the user to lose the dialog.

Due to the reparenting, the child widget isn't in the usual
C<< $toolitem->get_child >> (or C<get_children>, C<foreach>, etc).  Perhaps
this will change, but for now use the C<child-widget> property to get the
child.

Use this C<child-widget> property to get the current child.  When the child
is reparented to the overflow dialog it doesn't appear in the otherwise
usual C<< $toolitem->get_child >> or C<< $toolitem->get_children >>.


=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new (key=>value,...) >>

Create and return a new toolitem widget.  Optional key/value pairs set
initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<child-widget> (C<Gtk2::Widget>, default C<undef>)

The child widget to show in the toolitem or dialog.

The usual C<Gtk2::Container> C<child> property sets the child too.  But it's
write-only and can only store into an empty ToolItem, whereas
C<child-widget> is read/write and setting it replaces an existing child
widget.

The usual container C<< $toolitem->add($widget) >> sets the child widget
too, but again only into an empty ToolItem.

=item C<overflow-mnemonic> (string, default C<undef>)

A mnemonic string to show in the overflow menu item.  It should have "_"
undescores like "_Foo" with the "_F" meaning the "F" can be pressed to
select the item.  (Double underscore "__" is a literal underscore.)

=back

The ToolItem C<sensitive> property is propagated to the overflow menu item
and the dialog's child area.  (The dialog close button remains sensitive.)
Setting insensitive just on the child widget works too, but will leave the
menu item sensitive.  It's probably better to make the whole toolitem
insensitive so the menu item is disabled too.

The ToolItem C<tooltip-text> property (new in Gtk 2.12) is copied to the
dialog's child area.  A tooltip can also be put just on the child widget
too.

=cut
