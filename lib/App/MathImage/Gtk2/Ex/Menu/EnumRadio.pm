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

package App::MathImage::Gtk2::Ex::Menu::EnumRadio;
use 5.008;
use strict;
use warnings;
use Gtk2;
use Glib::Ex::SignalBits;
use Glib::Ex::EnumBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 4;

use Glib::Object::Subclass
  'Gtk2::Menu',
  signals => { 'nick-to-display'
               => { param_types   => ['Glib::String'],
                    return_type   => 'Glib::String',
                    flags         => ['action','run-last'],
                    class_closure => \&default_nick_to_display,
                    accumulator   => \&Glib::Ex::SignalBits::accumulator_first_defined,
                  },
             },
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

# sub INIT_INSTANCE {
#   my ($self) = @_;
# }

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  ### Enum GET_PROPERTY: $pname

  if ($pname eq 'active_nick') {
    foreach my $item ($self->get_children) {
      if (defined (my $nick = $item->{'nick'}) && $item->get_active) {
        return $nick;
      }
    }
    return undef;
  }

  # $pname eq 'enum_type'
  return $self->{$pname};
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### Enum SET_PROPERTY: $pname, $newval

  if ($pname eq 'enum_type') {
    my $enum_type = $self->{$pname} = $newval;

    # preserve active by its nick, if new type has that value
    # set_active() below will notify if the active changes, in particular to
    # -1 if nick not known in the new enum_type
    $newval = $self->get('active-nick');

    if (defined $enum_type && $enum_type ne '') {
      foreach my $item ($self->get_children) {
        if ($item->isa ('Gtk2::RadioMenuItem')) {
          $self->remove ($item);
        }
      }
      my $item;
      foreach my $info (Glib::Type->list_values($enum_type)) {
        my $nick = $info->{'nick'};
        my $str = $self->signal_emit ('nick-to-display', $nick);
        $item = Gtk2::RadioMenuItem->new_with_label ($item, $str);
        $item->{'nick'} = $nick;
        $item->show;
        $self->append ($item);
        $item->signal_connect (toggled => \&_do_item_toggled);
      }
    }
  }

  # $pname eq 'active_nick'
  foreach my $item ($self->get_children) {
    if (defined $item->{'nick'}) {
      if (defined $newval) {
        if ($item->{'nick'} eq $newval) {
          $item->set_active (1);
          last;
        }
      } else {
        ### inactive: $item->{'nick'}
        $item->set_active (0);
      }
    }
  }
}

sub _do_item_toggled {
  my ($item) = @_;
  if ($item->get_active) {
    my $self = $item->get_ancestor(__PACKAGE__);
    $self->notify ('active-nick');
  }
}

sub default_nick_to_display {
  my ($self, $nick) = @_;
  my $enum_type;
  return (($enum_type = $self->{'enum_type'})
          && Glib::Ex::EnumBits::to_display ($enum_type, $nick));
}

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::Menu::EnumRadio -- menu of enum value radio items

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::Menu::EnumRadio;
 my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new
              (enum_type   => 'Glib::UserDirectory',
               active_nick => 'home');  # initial selection

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::Menu::EnumRadio> is a subclass of C<Gtk2::Menu>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::MenuShell
          Gtk2::Menu
            App::MathImage::Gtk2::Ex::Menu::EnumRadio

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::Menu::EnumRadio> displays the values of a
C<Glib::Enum> in a radio group.  The C<active-nick> property is the user's
selection.

The text shown for each entry is per C<to_display> of L<Glib::Ex::EnumBits>,
so an enum class can arrange how its values appear, or the default is a
sensible word split and capitalization.

(There's a secret experimental might change in the future C<nick-to-display>
signal for per-instance control of the display.  A signal is a good way to
express a callback, but some care may be needed to get it connected early
enough, or for the calls to be later than when C<enum-type> is set, since
that property will often be set before making signal connections.)

=head1 FUNCTIONS

=over 4

=item C<< $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new (key=>value,...) >>

Create and return a new C<EnumRadio> menu object.  Optional key/value pairs
set initial properties per C<< Glib::Object->new >>.

    my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new
                 (enum_type   => 'Gtk2::TextDirection',
                  active_nick => 'ltr');

=back

=head1 PROPERTIES

=over 4

=item C<enum-type> (type name, default C<undef>)

The enum type to display and select from.  Until this is set the Menu is
empty.

When changing C<enum-type> if the current selected C<active-nick> also
exists in the new type then it remains selected, possibly on a different
row.  If the C<active-nick> doesn't exist in the new type then the menu
changes to nothing selected.

This property is a C<Glib::Param::GType> in Glib 2.10 and Glib-Perl 1.240
where that ParamSpec is available, or a plain string otherwise.  At the Perl
level a GType is a string anyway, but a GType pspec checks a setting really
is a C<Glib::Enum> sub-type.

=item C<active-nick> (string or C<undef>, default C<undef>)

The nick of the selected enum value.  The nick is the usual way an enum
value appears at the Perl level.

If there's no active row in the menu or no C<enum-type> has been set
then C<active-nick> is C<undef>.

There's no default for C<active-nick>, so when creating an Enum menu it's
usual to set the desired initial selection, either by nick or perhaps just
C<active> row 0 for the first value.

=back

=head1 BUGS

There's no way to set mnemonics for each enum value.  A semi-automatic way
to pick sensible ones might be good.

=head1 SEE ALSO

L<Gtk2::Menu>,
L<Glib::Ex::EnumBits>,
L<Gtk2::Ex::Menu::Text>

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

