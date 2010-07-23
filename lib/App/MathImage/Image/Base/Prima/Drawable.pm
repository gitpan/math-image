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


package App::MathImage::Image::Base::Prima::Drawable;
use 5.004;
use strict;
use warnings;
use Carp;
use base 'Image::Base';

# uncomment this to run the ### lines
#use Smart::Comments '###';

use vars '$VERSION';
$VERSION = 11;

sub new {
  my $class = shift;
  my $self = bless { _set_colour => '',
                     @_ }, $class;
  return $self;
}

my %get_methods = (-width  => 'width',
                   -height => 'height');
sub _get {
  my ($self, $key) = @_;
  ### Prima-Drawable _get(): $key
  if (my $method = $get_methods{$key}) {
    return $self->{'-drawable'}->$method;
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  my $width  = delete $params{'-width'};
  my $height = delete $params{'-height'};

  %$self = (%$self, %params);

  my $drawable = $self->{'-drawable'};
  if (defined $width) {
    if (defined $height) {
      $drawable->size ($width, $height);
    } else {
      $drawable->width ($width);
    }
  } elsif (defined $height) {
    $drawable->height ($height);
  }
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  my $drawable = $self->{'-drawable'};
  $y = $drawable->height - 1 - $y;
  if (@_ == 4) {
    ### xy store: $x,$y
    $drawable->pixel ($x,$y, $self->colour_to_pixel($colour));
  } else {
    ### fetch: $x,$y
    return sprintf '#%06X', $drawable->pixel($x,$y);
  }
}
sub line {
  my ($self, $x0, $y0, $x1, $y1, $colour) = @_ ;
  my $y_top = $self->{'-drawable'}->height - 1;
  _set_colour($self,$colour)->line ($x0, $y_top - $y0,
                                    $x1, $y_top - $y1);
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  my $y_top = $self->{'-drawable'}->height - 1;
  my $method = ($fill ? 'bar' : 'rectangle');
  ### rectangle: $method
  _set_colour($self,$colour)->$method ($x1, $y_top - $y1,
                                       $x2, $y_top - $y2);
}
sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  _set_colour($self,$colour)->ellipse
    (($x1+$x2)/2, ($y1+$y2)/2, $x2-$x1+1, $y2-$y1+1);
}

sub _set_colour {
  my ($self, $colour) = @_;
  ### _set_colour: $colour
  my $drawable = $self->{'-drawable'};
  if ($colour ne $self->{'_set_colour'}) {
    $self->{'_set_colour'} = $colour;
    $drawable->color ($self->colour_to_pixel ($colour));
  }
  return $drawable;
}
sub colour_to_pixel {
  my ($self, $colour) = @_;
  ### colour_to_pixel(): $colour

  # Crib: [:xdigit:] new in 5.6, so just 0-9A-F for now
  if ($colour =~ /^#([0-9A-F]{6})$/i) {
    return hex(substr($colour,1));
  }
  if ($colour =~ /^#([0-9A-F]{2})[0-9A-F]{2}([0-9A-F]{2})[0-9A-F]{2}([0-9A-F]{2})[0-9A-F]{2}$/i) {
    return hex($1.$2.$3);
  }

  (my $c = $colour) =~ s/^cl:://;
  if (my $coderef = (cl->can($c) || cl->can(ucfirst($c)))) {
    ### coderef: &$coderef()
    return &$coderef();
  }

  ### $c
  croak "Unrecognised colour: $colour";
}

1;
__END__

=for stopwords undef Ryde pixmap colormap ie XID drawables Prima

=head1 NAME

Image::Base::Prima::Drawable -- draw into Prima window, image, etc

=head1 SYNOPSIS

 use Image::Base::Prima::Drawable;
 my $X = Prima->new;
 my $image = Image::Base::Prima::Drawable->new
               (-X         => $X,
                -drawable  => $xid);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<Image::Base::Prima::Drawable> is a subclass of
C<Image::Base>,

    Image::Base
      Image::Base::Prima::Drawable

=head1 DESCRIPTION

C<Image::Base::Prima::Drawable> extends C<Image::Base> to draw into Prima
drawables.

Colours for drawing can be names known to the X server (usually from the
file F</etc/X11/rgb.txt>) or 2-digit #RRGGBB or 4-digit #RRRRGGGGBBBB hex.

=head1 FUNCTIONS

=over 4

=item C<$image = Image::Base::Prima::Drawable-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  The C<Prima> connection
object and drawable XID (an integer) must be given.

    $image = Image::Base::Prima::Drawable->new
                 (-X        => $x11_protocol_obj,
                  -drawable => $xid_drawable,
                  -colormap => $xid_colormap);

=item C<$colour = $image-E<gt>xy ($x, $y)>

=item C<$image-E<gt>xy ($x, $y, $colour)>

Get or set the pixel at C<$x>,C<$y>.

Currently colours returned by a get are either a name used previously to
draw, or a 4-digit hex #RRRRGGGGBBBB.  If two colour names became the same
pixel value because that was a close as could be represented then it's
unspecified which is returned.  For hex it's 4-digits because that's the
range in the X protocol.

If the drawable is a window and it doesn't have backing store then fetching
a pixel from an obscured region returns an unspecified colour, usually
a garbage #RRRRGGGGBBBB value.

Fetching a pixel is an X server round-trip and will be very slow if
attempting to read out a big region.  It's possible to read a big region or
the entire drawable in one go, but how to know if there's going to be lots
of C<xy> calls, and whether to re-fetch for possibly changed window
contents?

=item C<$image-E<gt>add_colours ($name, $name, ...)>

Allocate colours in the colormap.  Colour names are the same for the drawing
functions.

    $image->add_colours ('red', 'green', '#FF00FF');

The drawing functions automatically add a colour if it doesn't already exist
but C<add_colours> can initialize the colormap with particular desired
colours and it does so with a single server round-trip instead of separate
individual ones.

If the C<-colormap> set is the default colormap in one of the screens then
colours "black" and "white" are taken from the screen info without querying
the server.

=back

=head1 ATTRIBUTES

=over

=item C<-drawable> (XID integer)

The target drawable.

=item C<-colormap> (XID integer)

The colormap in which to allocate colours when drawing.  It defaults to the
default colormap of the screen containing the target drawable, though
getting that screen costs a server round-trip the first time the colormap is
required (for drawing or for a C<get>).

The C<Image::Base::Prima::Window> sub-class instead uses a window's
installed colormap as the default.

Setting C<-colormap> only affects where colours are allocated.  If the
drawable is a window then the colormap is not installed in the window's
attributes.

=item C<-width> (integer, read-only)

=item C<-height> (integer, read-only)

Width and height are read-only.  Values are obtained from C<GetGeometry>
when required, then cached.  If you already know the size then including
values in the C<new> will record them ready for later C<get>.  The plain
drawing operations don't need the size though.

    $image = Image::Base::Prima::Drawable->new
                 (-X        => $x11_protocol_obj,
                  -drawable => $id,
                  -width    => 200,      # record known values to save
                  -height   => 100,      # a server query
                  -colormap => $colormap);

=back

=head1 SEE ALSO

L<Image::Base>,
L<Prima::Drawable>

=cut
