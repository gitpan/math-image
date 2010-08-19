# nick-to-text $str
# set_data and call nick-to-text every time ?



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

our $VERSION = 16;

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
                  ('active-nick',
                   'active-nick',
                   'The selected enum value, as its nick.',
                   '',
                   Glib::G_PARAM_READWRITE),
                ];

use constant { _COLUMN_NICK    => 0,
               _COLUMN_DISPLAY => 1,
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
  ### EnumValues GET_PROPERTY: $pname

  if ($pname eq 'active_nick') {
    my $iter = $self->get_active_iter || return undef;
    ### $iter
    ### nick: $self->get_model->get_value ($iter, _COLUMN_NICK)
    my $model = $self->get_model || return undef;
    return $model->get_value ($iter, _COLUMN_NICK);
  }
  return $self->{$pname};
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### EnumValues SET_PROPERTY: $pname, $newval

  if ($pname eq 'enum_type') {
    # preserve active by its nick, if new type has that value
    my $nick = $self->get('active-nick');
    $self->{$pname} = $newval;
    $self->set_model (_model_for_enum ($newval));
    $newval = _nick_to_nth ($self, $newval);  # as if setting active-nick
    # set_active() will notify if the active changes, in particular to -1 if
    # nick not known in the new enum_type
  }

  # $pname eq 'active_nick'
  if ($self->get_model) {
    $self->set_active (_nick_to_nth ($self, $newval));
  }
}

# Crib note: $combobox->set_active_iter() doesn't accept undef for no active
# until Perl-Gtk 1.240, hence nth instead
sub _nick_to_nth {
  my ($self, $nick) = @_;
  ### _nick_to_nth: $nick
  my $ret = -1;
  if (defined $nick) {
    if (my $model = $self->get_model) {
      $model->foreach
        (sub {
           my ($model, $path, $iter) = @_;
           if ($nick eq $model->get_value ($iter, _COLUMN_NICK)) {
             ($ret) = $path->get_indices;
             ### found: $ret
             return 1; # stop
           }
           return 0; # continue
         });
    }
  }
  ### result: $ret
  return $ret;
}

# 'changed' class closure
sub _do_notify {
  my ($self, $pspec) = @_;
  if ($pspec->get_name eq 'active') {
    $self->notify ('active-nick');
  }
}

my %_model_for_enum;
sub _model_for_enum {
  my ($enum_type) = @_;

  # prune any weakened away
  delete @_model_for_enum{ # hash slice
    grep{!$_model_for_enum{$_}} keys %_model_for_enum
  };

  if (! defined $enum_type) {
    return undef;
  }
  if (my $model = $_model_for_enum{$enum_type}) {
    return $model;  # existing model
  }

  # new model
  my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String');
  foreach my $info (Glib::Type->list_values($enum_type)) {
    $model->set ($model->append,
                 _COLUMN_NICK,    $info->{'nick'},
                 _COLUMN_DISPLAY, App::MathImage::Glib::Ex::EnumBits::to_text($enum_type,$info->{'nick'}));
  }
  Scalar::Util::weaken ($_model_for_enum{$enum_type} = $model);
  return $model;
}

1;
__END__

=for stopwords Gtk Gtk2 combobox ComboBox Gtk programmatically

=head1 NAME

App::MathImage::Gtk2::Ex::ComboBox::EnumValues -- combobox for values of a Glib::Enum

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ComboBox::EnumValues;
 my $combo = App::MathImage::Gtk2::Ex::ComboBox::EnumValues->new
                 (enum_type => 'Glib::UserDirectory',
                  active_nick => 'home');  # initial selection

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
C<Glib::Enum>.  The text shown is per
C<App::MathImage::Glib::Ex::EnumBits::to_text>, so a particular enum class
can control how its values appear.

The C<active-nick> property of the EnumValues is the user's selection.  The
usual ComboBox C<active> property row number works too, but the nick is
normally the interesting bit.

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ComboBox::EnumValues->new (key=>value,...) >>

Create and return a new C<EnumValues> object.  Optional key/value pairs set
initial properties per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<enum-type> (type, default C<undef>)

The enum type to display and select from.  Until this is set the ComboBox is
empty.

When changing C<enum-type> if the current C<active-nick> also exists in the
new type then it remains selected (possibly on a different row).  If the
C<active-nick> doesn't exist in the new type then the combobox changes to
nothing selected.

This parameter is a C<Glib::Param::GType> in Glib-Perl 1.240 and up where
that pspec is available, or a plain string otherwise.  At the Perl level
both give string values, but the GType spec checks a setting really is a
C<Glib::Enum> sub-type.

=item C<active-nick> (string or undef, default C<undef>)

The nick of the selected enum value.  The nick is the usual way an enum
value appears at the Perl level.

If there's no active row in the ComboBox or no C<enum-type> has been set
then C<active-nick> is C<undef>.

=back

=head1 SEE ALSO

L<Gtk2::ComboBox>,
L<App::MathImage::Glib::Ex::EnumBits>

=cut
