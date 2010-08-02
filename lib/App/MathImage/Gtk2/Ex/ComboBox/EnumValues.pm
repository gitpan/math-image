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

package App::MathImage::Gtk2::Ex::ComboBox::EnumValues;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use List::MoreUtils;
use Locale::Messages;
use App::MathImage::Glib::Ex::EnumBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 13;

use Glib::Object::Subclass
  'Gtk2::ComboBox',
  signals => { notify => \&_do_notify },
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
                  ('nick',
                   'nick',
                   'The selected enum value, as its nick.',
                   '',
                   Glib::G_PARAM_READWRITE),
                ];

use constant { _COLUMN_NICK    => 0,   # arg string for gdk_pixbuf_save()
                 _COLUMN_DISPLAY => 1,   # translated display string
               };

sub INIT_INSTANCE {
  my ($self) = @_;

  my $renderer = Gtk2::CellRendererText->new;
  $renderer->set (ypad => 0);
  $self->pack_start ($renderer, 1);
  $self->set_attributes ($renderer, text => _COLUMN_DISPLAY);
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;

  if ($pname eq 'nick') {
    my $iter = $self->get_active_iter || return undef;
    return $self->get_model->get_value ($iter, _COLUMN_NICK);
  }
  return $self->{$pname};
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;

  if ($pname eq 'enum_type') {
    # preserve active by its nick, if new type has that value
    my $nick;
    if (my $iter = $self->get_active_iter) {
      $nick = $self->get_model->get_value ($iter, _COLUMN_NICK);
    }
    $self->{$pname} = $newval;
    $self->set_model (_model_for_enum ($newval));
    $newval = _nick_to_nth ($self, $newval);

    # set_active() will notify if the active changes, in particular to -1 if
    # nick not known in the new enum_type
  }

  # $pname eq 'nick'
  if ($self->get_model) {
    $self->set_active (_nick_to_nth ($self, $newval));
  }
}

# Crib note: $combobox->set_active_iter() doesn't accept undef for no active
# until Perl-Gtk 1.240, hence nth instead
sub _nick_to_nth {
  my ($self, $nick) = @_;
  my $ret = -1;
  if (defined $nick) {
    if (my $model = $self->get_model) {
      $model->foreach
        (sub {
           my ($model, $path, $iter) = @_;
           if ($nick eq $model->get_value ($iter, _COLUMN_NICK)) {
             ($ret) = $path->get_indices;
             return 1; # stop
           }
           return 0; # continue
         });
    }
  }
  return $ret;
}

# 'changed' class closure
sub _do_notify {
  my ($self, $pspec) = @_;
  if ($pspec->get_name eq 'active') {
    $self->notify ('nick');
  }
}

my %_model_for_enum;
sub _model_for_enum {
  my ($enum_class) = @_;
  delete @_model_for_enum{ # hash slice
    grep{!$_model_for_enum{$_}} keys %_model_for_enum
  };

  my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String');
  foreach my $info (Glib::Type->list_values($enum_class)) {
    $model->set ($model->append,
                 _COLUMN_NICK,    $info->{'nick'},
                 _COLUMN_DISPLAY, App::MathImage::Glib::Ex::EnumBits::to_display($enum_class,$info->{'nick'}));
  }
  Scalar::Util::weaken ($_model_for_enum{$enum_class} = $model);
  return $model;
}

1;
__END__

=for stopwords Gtk Gtk2 combobox ComboBox Gtk programmatically

=head1 NAME

App::MathImage::Gtk2::Ex::ComboBox::EnumValues -- combobox for Glib::Enum values

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ComboBox::EnumValues;
 my $combo = App::MathImage::Gtk2::Ex::ComboBox::EnumValues->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ComboBox::EnumValues> is a subclass of
C<Gtk2::ComboBox>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ComboBox
            App::MathImage::Gtk2::Ex::ComboBox::EnumValues

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::ComboBox::EnumValues> displays the values of a
C<Glib::Enum>.  The C<nick> property is the value selected by the user, or
set programmatically.

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ComboBox::EnumValues->new (key=>value,...) >>

Create and return a new C<TypeComboBox> object.  Optional key/value pairs
set initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<enum-type> (string)

...

=item C<nick> (string or undef, default undef)

The nick of the selected enum value.

=back

=cut
