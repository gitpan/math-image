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


# for-pixbuf-save ?
# insensitive or omit ?
#                   Glib::ParamSpec->object
#                   ('for-pixbuf-save',
#                    'for-pixbuf-save',
#                    'Blurb.',
#                    'Gtk2::Gdk::Pixbuf',
#                    Glib::G_PARAM_READWRITE),
#   if ($pname eq 'for_pixbuf_save') {
#     Scalar::Util::weaken ($self->{$pname});
#   }
#     my $pixbuf = $self->{'for_pixbuf_save'};
# ,
#              ($pixbuf ? ($pixbuf->get_width, $pixbuf->get_height) : ())



# writable => 
# exclude_read_only => 

# type or active-type ?
# active-format ?


package App::MathImage::Gtk2::Ex::ComboBox::PixbufType;
use 5.008;
use strict;
use warnings;
use Carp;
use Gtk2;
use Scalar::Util;
use List::Util qw(max);
use POSIX ();
use Locale::Messages;
use Gtk2::Ex::ComboBoxBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 23;

BEGIN {
  if (0) {
    # These are the type names as of Gtk 2.20, extend if there's more and
    # want to translate their names.
    #
    # TRANSLATORS: These format types are localized in case some non-Latin
    # script ought to be shown instead, or as well.  Latin languages will
    # probably leave the types unchanged, as that will almost certainly make
    # them easiest to identify, even if the abbreviation would be different
    # in the target language.
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

use Glib::Object::Subclass
  'Gtk2::ComboBox',
  signals => { notify => \&_do_notify },
  properties => [ Glib::ParamSpec->string
                  ('active-type',
                   'active-type',
                   'Gdk Pixbuf file save format, such as "png".',
                   'png',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('for-width',
                   'for-width',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   0,
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->int
                  ('for-height',
                   'for-height',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   0,
                   Glib::G_PARAM_READWRITE),

                ];

use constant { COLUMN_TYPE    => 0,   # arg string for gdk_pixbuf_save()
               COLUMN_DISPLAY => 1,   # translated display string
             };

sub INIT_INSTANCE {
  my ($self) = @_;

  my $renderer = Gtk2::CellRendererText->new;
  $renderer->set (ypad => 0);
  $self->pack_start ($renderer, 1);
  $self->set_attributes ($renderer, text => COLUMN_DISPLAY);

  $self->set_model (Gtk2::ListStore->new ('Glib::String', 'Glib::String'));
  _update_model($self);
  $self->set (active_type => 'png');  # per default above
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;

  if ($pname eq 'active_type') {
    my $iter = $self->get_active_iter || return undef;
    return $self->get_model->get_value ($iter, COLUMN_TYPE);
  } else {
    return $self->{$pname};
  }
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### ComboBox-PixbufType SET_PROPERTY: $pname

  if ($pname eq 'active_type') {
    # because COLUMN_TYPE==0
    Gtk2::Ex::ComboBoxBits::set_active_text ($self, $newval);
  } else {
    $self->{$pname} = $newval;
    _update_model($self);
  }
}

# 'notify' class closure
sub _do_notify {
  my ($self, $pspec) = @_;
  if ($pspec->get_name eq 'active') {
    $self->notify ('active-type');
  }
}

# fallback enough for the formats examinations below, including the fallback
# $is_writable_method
my $get_formats_method;
BEGIN {
  if (Gtk2::Gdk::Pixbuf->can('get_formats')) {
    # new in Gtk 2.2
    $get_formats_method = 'get_formats';
  } else {
    my @formats = ({ name => 'png' },
                   { name => 'jpeg' });
    $get_formats_method = sub { return @formats };
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

sub _update_model {
  my ($self) = @_;

  my @formats = grep
    {$_->$is_writable_method}
      Gtk2::Gdk::Pixbuf->$get_formats_method;

  # exclude ICO  if bigger than 255
  # exclude JPEG if bigger than 65500
  # exclude PNG  if bigger than 2^31-1, per PNG spec
  #
  # ENHANCE-ME: libpng png_check_IHDR() has a PNG_USER_WIDTH_MAX,
  # PNG_USER_HEIGHT_MAX which default to 1_000_000, and also width
  # (2^32-1)/8-129 to fit RGBA rows in memory (for benefit of 32-bit systems
  # presumably).  Could think about enforcing that.
  {
    my $size = max ($self->get('for-width'),
                    $self->get('for-height'));
    @formats = grep {! (($size > 255 && $_->{'name'} eq 'ico')
                        || ($size > 65500 && $_->{'name'} eq 'jpeg')
                        || ($size > (2**31-1) && $_->{'name'} eq 'png')
                       )}
      @formats;
  }

  # translated descriptions
  foreach my $format (@formats) {
    $format->{'display'} = Locale::Messages::dgettext ('Math-Image',
                                                       uc($format->{'name'}));
  }

  # alphabetical by translated description
  @formats = sort { $a->{'display'} cmp $b->{'display'} } @formats;

  my $type = $self->get('active-type');
  my $model = $self->get_model;
  $model->clear;
  foreach my $format (@formats) {
    ### display: $format->{'display'}
    $model->set ($model->append,
                 COLUMN_TYPE,    $format->{'name'},
                 COLUMN_DISPLAY, $format->{'display'});
  }

  # preserve existing setting
  $self->set (active_type => $type);
}

1;
__END__

=for stopwords Gtk Gtk2 Perl-Gtk combobox ComboBox Gdk Pixbuf Gtk
writability png jpeg ico bmp undef programmatically

=head1 NAME

App::MathImage::Gtk2::Ex::ComboBox::PixbufType -- combobox for Gdk Pixbuf file types

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ComboBox::PixbufType;
 my $combobox = App::MathImage::Gtk2::Ex::ComboBox::PixbufType->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::ComboBox::PixbufType> is a subclass of
C<Gtk2::ComboBox>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::ComboBox
            App::MathImage::Gtk2::Ex::ComboBox::PixbufType

=head1 DESCRIPTION

C<App::MathImage::Gtk2::Ex::ComboBox::PixbufType> displays files types
available for C<Gtk2::Gdk::Pixbuf>.

The C<type> property sets the format displayed and then changes with the
type selected by the user.

The default is the writable types in alphabetical order.  Perl-Gtk 1.240 or
higher is needed to check writability of a format.  For earlier versions
there's a hard-coded list (png, jpeg, tiff, ico and bmp, or just png and
jpeg in old Gtk).

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ComboBox::PixbufType->new (key=>value,...) >>

Create and return a new combobox object.  Optional key/value pairs set
initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<type> (string or undef, default "png")

The format type selected in the ComboBox.  This is the user's combobox
choice, or setting it programmatically changes that choice.  The default
"png" is meant to be sensible and always available.

=back

=cut
