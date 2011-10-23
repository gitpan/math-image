# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


package App::MathImage::Image::Base::Gtk::Gdk::Pixbuf;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 78;

use Image::Base 1.12; # version 1.12 for ellipse() $fill
@ISA = ('Image::Base');

# uncomment this to run the ### lines
#use Devel::Comments;

sub new {
  my ($class, %params) = @_;
  ### Pixbuf new(): \%params

  my $self;
  my $filename = delete $params{'-file'};

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    $self = bless { %$class }, ref $class;
    if (defined $filename) {
      $self->load ($filename);
    } elsif (! defined $params{'-pixbuf'}) {
      $self->{'-pixbuf'} = $self->{'-pixbuf'}->copy;
    }

  } else {
    if (! defined $filename) {
      if (! $params{'-pixbuf'}) {
        ### create new GdkPixbuf
        require Gtk::Gdk::Pixbuf;
        Gtk::Gdk::Pixbuf->init;
        my $width = delete $params{'-width'};
        my $height = delete $params{'-height'};
        my $has_alpha = !! delete $params{'-has_alpha'};
        my $len = $width * $height;
        my $pixbuf = $params{'-pixbuf'} = Gtk::Gdk::Pixbuf->new_from_data
          (scalar($has_alpha ? "\x00\x00\x00\xFF" : "\x00\x00\x00") x $len,
           delete $params{'-colorspace'} || 'rgb',
           $has_alpha,
           delete $params{'-bits_per_sample'} || 8,
           $width,   # width
           $height,  # height
           $width * (3+$has_alpha));  # rowstride
      }
    }
    $self = bless {}, $class;
    if (defined $filename) {
      $self->load ($filename);
    }
    $self->set (%params);
  }

  return $self;
}

my %attr_to_get_method = (-has_alpha  => 'get_has_alpha',
                          -colorspace => 'get_colorspace',
                          -width      => 'get_width',
                          -height     => 'get_height',
                         );
sub _get {
  my ($self, $key) = @_;
  if (my $method = $attr_to_get_method{$key}) {
    return $self->{'-pixbuf'}->$method;
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  ### Pixbuf set(): \%params

  if (my $pixbuf = $params{'-pixbuf'}) {
    $pixbuf->get_bits_per_sample == 8
      or croak "Only pixbufs of 8 bits per sample supported";
  }

  foreach my $key (keys %params) {
    if (my $method = $attr_to_get_method{$key}) {
      croak "$key is read-only";
    }
  }

  %$self = (%$self, %params);
  ### set leaves: $self
}

#------------------------------------------------------------------------------
# file load/save

sub load {
  my ($self, $filename) = @_;
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  ### load: $filename

  # Gtk::Gdk::Pixbuf->new_from_file doesn't seem to give back the format
  # used to load, so go to PixbufLoader in load_fh()
  open my $fh, '<', $filename or croak "Cannot open $filename: $!";
  binmode ($fh) or die "Oops, cannot set binmode: $!";
  $self->load_fh ($fh);
  close $fh or croak "Error closing $filename: $!";
}

sub load_fh {
  my ($self, $fh, $filename) = @_;
  ### load_fh()
  my $loader = Gtk::Gdk::PixbufLoader->new;
  for (;;) {
    my $buf;
    my $len = read ($fh, $buf, 8192);
    if (! defined $len) {
      croak "Error reading file",
        (defined $filename ? (' ',$filename) : ()),
          ": $!";
    }
    if ($len == 0) {
      last;
    }
    $loader->write ($buf);
  }
  $loader->close;
  $self->set (-pixbuf      => $loader->get_pixbuf,
              -file_format => $loader->get_format->{'name'});
  ### loaded format: $self->{'-file_format'}
}

sub load_string {
  my ($self, $str) = @_;
  ### load_string()
  my $loader = Gtk::Gdk::PixbufLoader->new;
  $loader->write ($str);
  $loader->close;
  $self->set (-pixbuf      => $loader->get_pixbuf,
              # -file_format => $loader->get_format->{'name'}
             );
  ### loaded format: $self->{'-file_format'}
}

sub save {
  my ($self, $filename) = @_;
  croak "Cannot save GdkPixbuf 1.0";
}

#------------------------------------------------------------------------------
# drawing

sub xy {
  my ($self, $x, $y, $colour) = @_;

  my $pixbuf = $self->{'-pixbuf'};
  if (@_ >= 4) {
    ### Image-GdkPixbuf xy: "$x, $y, $colour"

    my $bytes = $self->colour_to_bytes($colour);
    $pixbuf->put_pixels ($bytes, $y, $x);

  } else {
    my $n_channels = $pixbuf->get_n_channels;
    my $rgba = $pixbuf->get_pixels($y,$x);

    ### Image-GdkPixbuf xy fetch: "row=$y col=$x"
    ### $n_channels
    ### has_alpha: $pixbuf->get_has_alpha
    ### $rgba
    if ($pixbuf->get_has_alpha && substr($rgba,3,1) eq "\0") {
      return 'None';
    }
    return sprintf '#%02X%02X%02X', unpack 'CCC', $rgba;
  }
}

sub line {
  my ($self, $x1,$y1, $x2,$y2, $colour) = @_;
  ### Pixbuf line(): "$x1,$y1, $x2,$y2, $colour"

  if ($y1 == $y2) {
    # horizontal line with put_pixels() into some of a row

    my $bytes = $self->colour_to_bytes($colour);
    ### $bytes
    if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
    if ($x2 < 0) { return; }
    if ($x1 < 0) { $x1 = 0; }

    my $pixbuf = $self->{'-pixbuf'};
    my $width = $pixbuf->get_width;
    if ($x1 >= $width) { return; }
    if ($x2 >= $width) { $x2 = $width-1; }

    ### put_pixels: "row=$y1 col=$x1 len=".($x2-$x1+1)." cf width=$width"
    $pixbuf->put_pixels ($bytes x ($x2-$x1+1),
                         $y1, $x1);
  } else {
    shift->SUPER::line (@_);
  }
}

sub rectangle {
  my ($self, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  ### rectangle(): "$x1,$y1, $x2,$y2, $colour, ".($fill||0)

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }   # swap
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }   # swap

  my $w = $x2 - $x1 + 1;
  my $h = $y2 - $y1 + 1;

  if ($fill || $w <= 2 || $h <= 2) {
    # solid rectangular block with $pixbuf->copy_area()

    my $pixbuf = $self->{'-pixbuf'};
    my $has_alpha = $pixbuf->get_has_alpha;
    my $wh = $w * $h;
    my $bytes = $self->colour_to_bytes($colour);
    my $src_pixbuf = Gtk::Gdk::Pixbuf->new_from_data
      ($bytes x $wh,
       'rgb',
       $has_alpha,
       8,      # bits per sample
       $w,$h,  # width,height
       $w * (3 + $has_alpha));

    $src_pixbuf->copy_area (0,0,   # src x,y
                            $w,$h, # src width,height
                            $pixbuf,  # dest
                            $x1,$y1); # dest x,y
  } else {
    shift->SUPER::rectangle(@_);
  }
}

#------------------------------------------------------------------------------
# colours

use constant::defer _gtk_init => sub {
  require Gtk;
  Gtk->init;
  return undef;
};

sub colour_to_bytes {
  my ($self, $colour) = @_;
  my $data;
  my $has_alpha = $self->{'-pixbuf'}->get_has_alpha;

  if (lc($colour) eq 'none') {
    if (! $has_alpha) {
      croak "pixbuf has no alpha channel for colour None";
    }
    return "\0\0\0\0";
  }

  if ($colour eq 'set') {
    return ($has_alpha ? "\xFF\xFF\xFF\xFF" : "\xFF\xFF\xFF");
  }
  if ($colour eq 'clear') {
    return ($has_alpha ? "\x00\x00\x00\x00" : "\x00\x00\x00");
  }

  _gtk_init();
  my $colorobj = Gtk::Gdk::Color->parse_color ($colour)
    || croak "Cannot parse colour: $colour";
  my $bytes = pack ('CCC',
                    $colorobj->red >> 8,
                    $colorobj->green >> 8,
                    $colorobj->blue >> 8);
  if ($has_alpha) {
    $bytes .= "\xFF";
  }
  return $bytes;
}

1;
__END__

=for stopwords Ryde Gdk Images pixbuf ie toplevel GdkPixbuf PNG JPEG Gtk ICO BMP XPM GIF XBM Pixbufs RGB RGBA pixbufs filename png jpeg boolean

=head1 NAME

App::MathImage::Image::Base::Gtk::Gdk::Pixbuf -- draw into Gtk::Gdk::Pixbuf images

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Gtk::Gdk::Pixbuf;
 my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
                 (-width => 100,
                  -height => 100);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Gtk::Gdk::Pixbuf> is a subclass of
C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Gtk::Gdk::Pixbuf

=head1 DESCRIPTION

I<In progress ...>

C<App::MathImage::Image::Base::Gtk::Gdk::Pixbuf> extends C<Image::Base> to
draw into GdkPixbuf 1.0 images (the GdkPixbuf version of Gtk 1.2).
GdkPixbuf 1.0 can read various file formats,

    PNG, JPEG, GIF, TIFF, XPM, XBM, ICO, RAS, PNM, BMP

but it has no file writing.

Pixbufs are held in client-side memory and don't of themselves require an X
server or C<Gtk-E<gt>init()>, but the code here uses
C<Gtk::Gdk::Color-E<gt>parse_color()> and will C<Gtk-E<gt>init()> where
necessary.

=head2 Colour Names

Colour names  recognised are

    names     \
    #FFF      | per Gtk::Gdk::Color->parse_color()
    #FFFFFF   |   which means Xlib XParseColor()
    etc       /
    None      special for transparent (when "has_alpha")

Only 8-bit RGB or RGBA pixbufs are supported by this module.  This is all
that GdkPixbuf 1.0 itself supports.  3 or 4 digit hex colours are truncated
to their high 8 bits.

=head1 FUNCTIONS

See L<Image::Base/FUNCTIONS> for the behaviour common to all Image-Base
classes.

=over 4

=item C<< $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new (key=>value,...) >>

Create and return a new GdkPixbuf image object.  It can be pointed at an
existing pixbuf,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
                 (-pixbuf => $gdkpixbuf);

Or a file can be read,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
                 (-file => '/my/file/name.jpeg');

Or a new pixbuf created with width and height,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
                 (-width  => 10,
                  -height => 10);

When creating a pixbuf an alpha channel (transparency) can be requested with
C<-has_alpha>,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
                 (-width     => 10,
                  -height    => 10,
                  -has_alpha => 1);

=item C<< $image->load () >>

=item C<< $image->load ($filename) >>

Read the C<-file>, or set C<-file> to C<$filename> and then read.  This
creates and sets a new underlying C<-pixbuf> because it's not possible to
read into an existing pixbuf object, only read a new one.

=item C<< $image->save () >>

=item C<< $image->save ($filename) >>

Gdk-Pixbuf 1.0 doesn't support saving.

=back

=head1 ATTRIBUTES

=over

=item C<-pixbuf> (C<Gtk::Gdk::Pixbuf> object)

The target C<Gtk::Gdk::Pixbuf> object.

=item C<-width> (integer, read-only)

=item C<-height> (integer, read-only)

The size of a pixbuf cannot be changed once created.

=item C<-has_alpha> (boolean, read-only)

Whether the underlying pixbuf has a alpha channel, meaning a transparency
mask (or partial transparency).  This cannot be changed once created.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Gtk::Gdk::Pixbuf::reference>

=cut
