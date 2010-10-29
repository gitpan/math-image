# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::ToolItem::EnumCombo;
use 5.008;
use strict;
use warnings;
use Gtk2;
use Glib::Ex::SignalBits;
use Glib::Ex::EnumBits;

use Gtk2::Ex::ComboBox::Enum;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 28;

use Glib::Object::Subclass
  'Gtk2::ToolItem',
  signals => { create_menu_proxy => \&_do_create_menu_proxy },
  properties => [ (Glib::Param->can('gtype')
                   ?
                   # new in Glib 2.10 and Perl-Glib 1.240
                   Glib::ParamSpec->gtype
                   ('enum-type',
                    'enum-type',
                    'The enum class to display.',
                    'Glib::Enum',
                    Glib::G_PARAM_READWRITE)
                   :
                   # default is undef but Glib::ParamSpec->string() doesn't
                   # allow that until Perl-Glib 1.240, and in that case have
                   # Glib::ParamSpec->gtype() above
                   Glib::ParamSpec->string
                   ('enum-type',
                    'enum-type',
                    'The enum class to display.',
                    '',
                    Glib::G_PARAM_READWRITE)),

                  Glib::ParamSpec->string
                  ('active-nick',
                   'active-nick',
                   'The selected enum value, as its nick.',
                   # FIXME: default is undef, pending perl-glib 1.240 to
                   # accept that here
                   '', # default
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  my $combobox = Gtk2::Ex::ComboBox::Enum->new;
  $combobox->signal_connect ('notify::active-nick' => \&_do_combobox_notify);
  $combobox->show;
  $self->add ($combobox);
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  ### EnumCombo GET_PROPERTY: $pname

  return $self->get_child->get($pname);

  # if ($pname eq 'active_nick') {
  # }
  #
  # # if ($pname eq 'enum_type')
  # return $self->{$pname};
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### EnumCombo SET_PROPERTY: $pname, $newval

  $self->get_child->set ($pname => $newval);
  if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
    $menuitem->get_submenu->set ($pname => $newval);
  }

  # $self->{$pname} = $newval;
}

sub _do_combobox_notify {
  my ($combobox) = @_;
  if (my $self = $combobox->parent) { # perhaps in case unparented
    $self->notify('active-nick');
  }
}

sub _do_create_menu_proxy {
  my ($self) = @_;
  ### _do_create_menu_proxy()
  my $combobox = $self->get_child;

  require App::MathImage::Gtk2::Ex::Menu::EnumRadio;
  require Glib::Ex::ConnectProperties;

  my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new
    (enum_type   => $combobox->get('enum-type'));
  # tearoff-title new in 2.10, go undef if nothing
  $menu->set_title (eval { $combobox->get('tearoff-title') });
  Glib::Ex::ConnectProperties->new ([$self,'active-nick'],
                                    [$menu,'active-nick']);
  Glib::Ex::ConnectProperties->new ([$self,'enum-type'],
                                    [$menu,'enum-type']);

  my $menuitem = Gtk2::MenuItem->new_with_label ($self->{'name'}
                                                 || $self->get_name);
  $menuitem->set_submenu ($menu);
  $self->set_proxy_menu_item (__PACKAGE__, $menuitem);
  return 1;
}

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::EnumCombo -- toolitem with enum values in a combobox

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ToolItem::EnumCombo;
 my $menu = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
              (enum_type   => 'Glib::UserDirectory',
               active_nick => 'home');  # initial selection

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ToolItem::EnumCombo> is a subclass of C<Gtk2::Menu>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::MenuShell
          Gtk2::Menu
            App::MathImage::Gtk2::Ex::ToolItem::EnumCombo

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::ToolItem::EnumCombo> displays a combobox of
C<Glib::Enum> values.  The C<active-nick> property is the user's selection.

A toolbar overflow menu item is provided when necessary offering the same
enum choices in a radio button sub-menu.

=head1 FUNCTIONS

=over 4

=item C<< $menu = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new (key=>value,...) >>

Create and return a new C<EnumCombo> toolitem widget.  Optional key/value
pairs set initial properties per C<< Glib::Object->new >>.

    my $menu = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
                 (enum_type   => 'Gtk2::TextDirection',
                  active_nick => 'ltr');

=back

=head1 PROPERTIES

=over 4

=item C<enum-type> (type name, default C<undef>)

The enum type to display and select from.  Until this is set the child
combobox is blank.

=item C<active-nick> (string or C<undef>, default C<undef>)

The nick of the selected enum value.  The nick is the usual way an enum
value appears at the Perl level.

There's no default for C<active-nick>, so when creating an Enum menu it's
usual to set the desired initial selection, either by nick or perhaps just
C<active> row 0 for the first value.

=back

=head1 SEE ALSO

L<Gtk2::ToolItem>,
L<Glib::Ex::ComboBox::Enum>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see L<http://www.gnu.org/licenses/>.

=cut

# =head1 SIGNALS
# 
# =over 4
# 
# =item C<nick-to-display> (parameters: menu, nick -- return: string)
# 
# Emitted to turn an enum nick into a text display string.  The default is
# the C<to_display> of C<Glib::Ex::EnumBits>.
# 
# =back

