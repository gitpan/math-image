# label/name for overflow menu item





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
use Gtk2::Ex::ContainerBits;
use Gtk2::Ex::ComboBox::Enum 5; # v.5 for get_active_nick(),set_active_nick()

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 31;

use Glib::Object::Subclass
  'Gtk2::ToolItem',
  interfaces => [
                 # Gtk2::Buildable new in Gtk 2.12, omit if not available
                 Gtk2::Widget->isa('Gtk2::Buildable') ? ('Gtk2::Buildable') : ()
                ],
  signals => { create_menu_proxy => \&_do_create_menu_proxy,
             },
  properties => [
                 # FIXME: default enum-type is undef but
                 # Glib::ParamSpec->string() doesn't allow that until
                 # Perl-Glib 1.240, in which case have
                 # Glib::ParamSpec->gtype().
                 #
                 (Glib::Param->can('gtype')
                  ?
                  # new in Glib 2.10 and Perl-Glib 1.240
                  Glib::ParamSpec->gtype
                  ('enum-type',
                   'enum-type',
                   'The enum class to display.',
                   'Glib::Enum',
                   Glib::G_PARAM_READWRITE)
                  :
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
                  (eval {Glib->VERSION(1.240);1}
                   ? undef # default
                   : ''),  # no undef/NULL before Perl-Glib 1.240
                  Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  my $combobox = Gtk2::Ex::ComboBox::Enum->new;
  $combobox->show;
  $self->add ($combobox);
  $combobox->signal_connect ('notify::active-nick'
                             => \&_do_combobox_notify_nick);
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  ### EnumCombo GET_PROPERTY: $pname

  # $pname eq 'enum_type' || $pname eq 'active_nick'
  my $combobox;
  return (($combobox = $self->get_child)  # if perhaps being destroyed
          && $combobox->get($pname));
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### EnumCombo SET_PROPERTY: $pname, $newval

  # $pname eq 'enum_type' || $pname eq 'active_nick'
  if (my $combobox = $self->get_child) { # in case perhaps being destroyed
    $combobox->set ($pname => $newval);
    if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
      $menuitem->get_submenu->set ($pname => $newval);
    }
  }
  # $self->{$pname} = $newval;
}

sub get_active_nick {
  my ($self) = @_;
  my $combobox;
  return (($combobox = $self->get_child)  # if perhaps being destroyed
          && $combobox->get_active_nick);
}
sub set_active_nick {
  my ($self, $nick) = @_;
  if (my $combobox = $self->get_child) {  # if perhaps being destroyed
    $combobox->set_active_nick ($nick);
  }
}

sub _do_combobox_notify_nick {
  my ($combobox, $pspec) = @_;
  if (my $self = $combobox->parent) { # perhaps in case unparented
    $self->notify('active-nick');

    # my $pname = $pspec->get_name;
    # $pname
    # if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
    #   $menuitem->get_submenu->set ($pname => $combobox->get('active-nick'));
    # }
  }
}

sub _do_create_menu_proxy {
  my ($self) = @_;
  ### _do_create_menu_proxy()
  my $combobox = $self->get_child || return 0;  # if perhaps being destroyed

  require App::MathImage::Gtk2::Ex::Menu::EnumRadio;
  require Glib::Ex::ConnectProperties;

  my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new
    (enum_type   => $combobox->get('enum-type'));

  Glib::Ex::ConnectProperties->new ([$self,'active-nick'],
                                    [$menu,'active-nick']);
  Glib::Ex::ConnectProperties->new ([$self,'enum-type'],
                                    [$menu,'enum-type']);

  # ComboBox tearoff-title new in 2.10, but always present in Menu.
  if ($combobox->find_property('tearoff-title')) {
    Glib::Ex::ConnectProperties->new ([$combobox,'tearoff-title'],
                                      [$menu,'tearoff-title']);
  }

  my $label_str = (defined $self->{'name'}
                   ? $self->{'name'}
                   : $self->get_name);
  my $menuitem = Gtk2::MenuItem->new_with_label ($label_str);
  $menuitem->set_submenu ($menu);
  $self->set_proxy_menu_item (__PACKAGE__, $menuitem);
  return 1;
}

  # $menu->signal_connect ('notify::active-nick'
  #                        => \&_do_menu_notify_nick);

# sub _do_menu_notify_nick {
#   my ($menu) = @_;
#   if (my $self = $combobox->parent) { # perhaps in case unparented
#     $self->notify('active-nick');
#     if (my $menuitem = $self->get_proxy_menu_item (__PACKAGE__)) {
#       $menuitem->get_submenu->set ($pname => $combobox->get('active-nick'));
#     }
#   }
# }

#------------------------------------------------------------------------------
# Gtk2::Buildable interface

sub GET_INTERNAL_CHILD {
  my ($self, $builder, $name) = @_;
  if ($name eq 'combobox') {
    return $self->get_child;
  }
  return undef;
}


# Maybe allowing a different ComboBox subclass to be plugged in ...
#
# add => \&_do_add,
#                remove => \&_do_remove,
# use Glib::Ex::SignalIds;
# sub _do_add {
#   my ($self, $child) = @_;
#   my ($enum_type, $active_nick) = $self->get('enum_type','active_nick');
#   shift->signal_chain_from_overridden (@_);
# 
#   $self->set(enum_type => $enum_type,
#              active_nick => $active_nick);
#   $self->{'child_ids'} = Glib::Ex::SignalIds->new
#     ($child,
#      $child->signal_connect ('notify::active-nick'
#                              => \&_do_combobox_notify_nick));
# }
# sub _do_remove {
#   my ($self, $child) = @_;
#   delete $self->{'child_ids'};
#   shift->signal_chain_from_overridden (@_);
# }
# 
# sub ADD_CHILD {
#   my ($self, $builder, $child, $type) = @_;
#   # replace default combobox created in init
#   Gtk2::Ex::ContainerBits::remove_all($self);
#   $self->add ($child);
# }

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::ToolItem::EnumCombo -- toolitem with enum values in a combobox

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ToolItem::EnumCombo;
 my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
                  (enum_type   => 'Glib::UserDirectory',
                   active_nick => 'home');  # initial selection

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ToolItem::EnumCombo> is a subclass of
C<Gtk2::ToolItem>.  C<Gtk2::ToolItem> is new in Gtk 2.4.

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ToolItem
            App::MathImage::Gtk2::Ex::ToolItem::EnumCombo

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::ToolItem::EnumCombo> puts a
C<Gtk2::Ex::ComboBox::Enum> in a ToolItem.  The C<active-nick> property is
the user's selection.

A toolbar overflow menu item is provided offering the same enum choices in a
C<App::MathImage::Gtk2::Ex::Menu::EnumRadio>.

=head1 FUNCTIONS

=over 4

=item C<< $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new (key=>value,...) >>

Create and return a new C<EnumCombo> toolitem widget.  Optional key/value
pairs set initial properties per C<< Glib::Object->new >>.

    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
                     (enum_type   => 'Gtk2::TextDirection',
                      active_nick => 'ltr');

=back

=head1 PROPERTIES

=over 4

=item C<enum-type> (type name, default C<undef>)

The enum type to display and select from.  Until this is set the child
combobox is blank.

This property is a C<Glib::Param::GType> when possible, or a
C<Glib::Param::String> otherwise.  In both cases at the Perl level the value
is a type name string, but the GType will check a setting really is an enum.
Currently in both cases the pspec C<get_default_value> does not give the
actual default C<undef>.

=item C<active-nick> (string or C<undef>, default C<undef>)

The nick of the selected enum value.  The nick is the usual way an enum
value appears at the Perl level.

There's no default for C<active-nick>, so when creating a
ToolItem::EnumCombo it's usual to set the desired initial selection.

=back

=head1 SEE ALSO

L<Gtk2::ToolItem>,
L<Glib::Ex::ComboBox::Enum>,
L<App::MathImage::Gtk2::Ex::Menu::EnumRadio>

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

