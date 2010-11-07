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

package App::MathImage::Gtk2::Ex::ToolItem::CheckButton;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use List::Util qw(max);

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 29;

use Glib::Object::Subclass
  'Gtk2::ToolItem',
  signals => { notify => \&_do_notify,
               create_menu_proxy => \&_do_create_menu_proxy,
             },
  properties => [ Glib::ParamSpec->boolean
                  ('active',
                   'active',
                   'Gdk Pixbuf file save format, such as "png".',
                   'png',
                   Glib::G_PARAM_READWRITE),
                ];

sub new_with_label {
  my ($class, $str) = @_;
  my $self = $class->new;
  $self->get_child->set_label ($str);
}

sub INIT_INSTANCE {
  my ($self) = @_;

  my $checkbutton = Gtk2::CheckButton->new;
  $self->add (Gtk2::CheckButton->new);
  $checkbutton->signal_connect ('notify:active' => \&_do_checkbutton_notify);
}

sub _do_checkbutton_notify {
  my ($checkbutton) = @_;
  if (my $self = $checkbutton->get_parent) {
    $self->notify('active');
  }
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  # my $pname = $pspec->get_name;
  # $pname eq 'active') {
  return $self->get_child->get_active;
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### ToolItem-CheckButton SET_PROPERTY: $pspec->get_name
  # my $pname = $pspec->get_name;
  # $pname eq 'active') {

  $self->get_child->set_active($newval);
}

sub _do_create_menu_proxy {
  my ($self) = @_;
  my $checkbutton = $self->get_child;
  my $menuitem = Gtk2::CheckMenuItem->new_with_label ($checkbutton->get_label);
  require Glib::Ex::ConnectProperties;
  Glib::Ex::ConnectProperties->new ([$checkbutton,'active'],
                                    [$menuitem,'active']);
  Glib::Ex::ConnectProperties->new ([$checkbutton,'label'],
                                    [$menuitem->get_child,'label',
                                     write_only=>1]);
  $toolitem->set_proxy_menu_item (__PACKAGE__, $menuitem);
  return 1;
}


1;
__END__

=for stopwords Gtk Gtk2 Perl-Gtk ToolItem Gdk Pixbuf Gtk

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::CheckButton -- toolitem for Gdk Pixbuf file types

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ToolItem::CheckButton;
 my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ToolItem::CheckButton> is a subclass of
C<Gtk2::ToolItem>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ToolItem
            App::MathImage::Gtk2::Ex::ToolItem::CheckButton

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::ToolItem::CheckButton> ...

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ToolItem::CheckButton->new (key=>value,...) >>

Create and return a new toolitem object.  Optional key/value pairs set
initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<active> (boolean, default false)

=back

=cut
