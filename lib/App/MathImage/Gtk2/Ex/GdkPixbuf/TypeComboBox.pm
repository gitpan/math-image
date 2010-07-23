# Copyright 2010 Kevin Ryde

# This file is part of Gtk2-Ex-WidgetBits.
#
# Gtk2-Ex-WidgetBits is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Gtk2-Ex-WidgetBits is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Gtk2-Ex-WidgetBits.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use List::MoreUtils;
use Locale::Messages;

Locale::Messages::bind_textdomain_filter
  ('Gtk2-Ex-WidgetBits', \&Locale::Messages::turn_utf_8_on);

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 11;

use Glib::Object::Subclass
  'Gtk2::ComboBox',
  signals => { notify => \&_do_notify },
  properties => [ Glib::ParamSpec->string
                  ('type',
                   'type',
                   'Gdk Pixbuf file save format, such as "png".',
                   'png',
                   Glib::G_PARAM_READWRITE),
                ];

use constant { COLUMN_TYPE    => 0,   # arg string for gdk_pixbuf_save()
               COLUMN_DISPLAY => 1,   # translated display string
             };

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->configure_types;
  $self->set (type => 'png');  # per default above

  my $renderer = Gtk2::CellRendererText->new;
  $renderer->set (ypad => 0);
  $self->pack_start ($renderer, 1);
  $self->set_attributes ($renderer, text => COLUMN_DISPLAY);
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;

  # type
  my $iter = $self->get_active_iter || return undef;
  return $self->get_model->get_value ($iter, COLUMN_TYPE);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;

  # type
  $self->set_active (_type_to_nth ($self, $newval));
}

# Crib note: $combobox->set_active_iter() doesn't accept undef for no active
# until Perl-Gtk 1.240, hence nth instead
sub _type_to_nth {
  my ($self, $type) = @_;
  my $ret = -1;
  if (defined $type) {
    $self->get_model->foreach
      (sub {
         my ($model, $path, $iter) = @_;
         if ($type eq $model->get_value ($iter, COLUMN_TYPE)) {
           ($ret) = $path->get_indices;
           return 1; # stop
         }
         return 0; # continue
       });
  }
  return $ret;
}

# 'changed' class closure
sub _do_notify {
  my ($self, $pspec) = @_;
  if ($pspec->get_name eq 'active') {
    $self->notify ('type');
  }
}

my $is_writable_method;
BEGIN {
  if (Gtk2::Gdk::PixbufFormat->can('is_writable')) {
    # is_writable() new in Gtk 2.2, and not wrapped until Perl-Gtk 1.240
    $is_writable_method = 'is_writable';
  } else {
    my %writable = (png => 1, jpeg => 1); # Gtk 2.0 and 2.2
    if (! Gtk2->check_version (2,4,0)) {  # 2.4.0 for ico saving
      $writable{'ico'} = 1;
    }
    if (! Gtk2->check_version(2,8,0)) {  # 2.8.0 for bmp saving
      $writable{'bmp'} = 1;
    }
    if (! Gtk2->check_version(2,10,0)) {  # 2.10.0 for tiff saving
      $writable{'tiff'} = 1;
    }
    $is_writable_method = sub {
      my ($format) = @_;
      return $writable{$format->{'name'}};
    };
  }
}

my $get_formats_method;
BEGIN {
  if (Gtk2::Gdk::Pixbuf->can('get_formats')) {
    # get_formats() new in Gtk 2.2
    $get_formats_method = 'get_formats';
  } else {
    $get_formats_method = sub {
      return { name => 'png' }, { name => 'jpeg' };
    };
  }
}

BEGIN {
  if (0) {
    # These are the only writables as of Gtk 2.20, extend this if there's
    # more and wnat to translate their names.
    #
    # TRANSLATORS: The format display strings are localized in case some
    # non-Latin script should be shown instead or as well.  Latin languages
    # should probably leave the names as-is even if the abbreviation would
    # be different in the target language.
    __('ANI');
    __('BMP');
    __('GIF');
    __('ICNS');
    __('ICO');
    __('JPEG');
    __('JPEG2000');
    __('PCX');
    __('PNG');
    __('PNM');
    __('QTIF');
    __('RAS');
    __('SVG');
    __('TGA');
    __('TIFF');
    __('WBMP');
    __('WMF');
    __('XBM');
    __('XPM');
  }
}

# not documented yet ...
sub configure_types {
  my ($self) = @_;
  my $model = _model_for_types (_choose_types(@_));

  my $type = $self->get('type');
  $self->set_model ($model);
  my $n = _type_to_nth ($self, $type);
  $self->set_active ($n >= 0 ? $n : 0);
}

# not documented ...
sub _choose_types {
  my $self = shift;
  my @prefer;
  my @formats = Gtk2::Gdk::Pixbuf->$get_formats_method;

  while (@_) {
    my $key = shift;
    my $value = shift;
    if ($key eq 'prefer_list') {
      @prefer = @$value;
    } elsif ($key eq 'plus_formats') {
      push @formats, @$value;
    } else {
      croak "Unrecognised pixbuf type chooser option: $key";
    }
  }

  # names of writables
  @formats = map {$_->{'name'}}
    grep {$_->$is_writable_method} @formats;

  # translated descriptions
  my %formats = map {; ($_,
                        Locale::Messages::dgettext('Gtk2-Ex-WidgetBits',
                                                   uc($_)))
                   } @formats;

  # alphabetical by translated description
  @formats = sort { $formats{$a} cmp $formats{$b} } @formats;

  @prefer = grep {exists $formats{$_}} @prefer;
  return List::MoreUtils::uniq (@prefer, @formats);
}

# not documented ...
my %_model_for_types;
sub _model_for_types {
  delete @_model_for_types{ # hash slice
    grep{!$_model_for_types{$_}} keys %_model_for_types };

  my $key = join(',',@_);
  if ($_model_for_types{$key}) {
    return $_model_for_types{$key};
  }

  my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String');
  foreach my $name (@_) {
    $model->set ($model->append,
                 COLUMN_TYPE, $name,
                 COLUMN_DISPLAY,
                 Locale::Messages::dgettext ('Gtk2-Ex-WidgetBits',
                                             uc($name)));
  }
  Scalar::Util::weaken ($_model_for_types{$key} = $model);
  return $model;
}

1;
__END__

=for stopwords Gtk Gtk2 combobox ComboBox Gdk Pixbuf Gtk writability png jpeg ico bmp undef programmatically

=head1 NAME

App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox -- combobox for Gdk Pixbuf file types

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox;
 my $combobox = App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox> is a subclass of
C<Gtk2::ComboBox>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ComboBox
            App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox> displays files types
available for C<Gtk2::Gdk::Pixbuf>.

The C<type> property sets the format displayed and then changes with the
type selected by the user.

The default is the writable types in alphabetical order.  Perl-Gtk 1.240 or
higher is needed to check writability of a format.  For earlier versions
there's a hard-coded list (png, jpeg, tiff, ico and bmp, or just png and
jpeg in old Gtk).

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::GdkPixbuf::TypeComboBox->new (key=>value,...) >>

Create and return a new C<TypeComboBox> object.  Optional key/value pairs
set initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<type> (string or undef, default "png")

The format type selected in the ComboBox.  The default "png" is This is the user's combobox choice, or setting it programmatically changes
that choice.

=back

=cut
