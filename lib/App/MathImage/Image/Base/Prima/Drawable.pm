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
use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 30;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my $class = shift;
  my $self = bless { _set_colour => '' }, $class;
  $self->set (@_);
  return $self;
}

my %get_methods = (-width  => 'width',
                   -height => 'height',
                   -depth  => 'get_bpp',
                   -bpp    => 'get_bpp',
                  );
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
    #### xy store: $x,$y
    $drawable->pixel ($x,$y, $self->colour_to_pixel($colour));
  } else {
    #### fetch: $x,$y
    return sprintf '#%06X', $drawable->pixel($x,$y);
  }
}
sub line {
  my ($self, $x1,$y1, $x2,$y2, $colour) = @_ ;
  ### Image-Base-Prima-Drawable line(): "$x1,$y1, $x2,$y2"
  my $y_top = $self->{'-drawable'}->height - 1;
  _set_colour($self,$colour)->line ($x1, $y_top-$y1,
                                    $x2, $y_top-$y2);
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;

  # In Prima 1.28 under X, if lineWidth==0 then a one-pixel unfilled
  # rectangle x1==x2 and y1==y2 draws nothing.  This will be just the usual
  # server-dependent behaviour on a zero-width line.  Use bar() for this
  # case so as to be sure of getting a pixel drawn whether lineWidth==0 or
  # lineWidth==1.
  #
  my $method = ($fill || ($x1==$x2 && $y1==$y2)
                ? 'bar'
                : 'rectangle');
  my $y_top = $self->{'-drawable'}->height - 1;
  ### Image-Base-Prima-Drawable rectangle(): $method
  _set_colour($self,$colour)->$method ($x1, $y_top - $y1,
                                       $x2, $y_top - $y2);
}
sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;

  # In Prima 1.28 under X, if lineWidth==0 then a one-pixel ellipse x1==x2
  # and y1==y2 draws nothing, the same as for an unfilled rectangle above.
  #
  my $drawable = $self->{'-drawable'};
  my $y_top = $drawable->height - 1;
  if ($x1==$x2 && $y1==$y2) {
    $drawable->pixel ($x1, $y_top - $y1,
                      $self->colour_to_pixel($colour));
  } else {
    # The adjustment from the x1,y1 corner to the centre args for prima
    # ellipse() are per the unix/apc_graphics.c X code.  Hope it ends up the
    # same on different platforms.  The calculate_ellipse_divergence() looks
    # a bit doubtful, it might be exercising the zero-width line.
    #
    my $dx = $x2-$x1+1; # diameter
    my $dy = $y2-$y1+1;
    ### ellipse
    ### centre x: $x1 + int (($dx - 1)/2)
    ### centre y: $y_top - ($y1 + int (($dy - 1)/2))
    ### $dx
    ### $dy
    _set_colour($self,$colour)->ellipse
      ($x1 + int (($dx - 1)/2),
       ($y_top - $y1) - int ($dy/2),
       $dx, $dy);
  }
}

sub _set_colour {
  my ($self, $colour) = @_;
  my $drawable = $self->{'-drawable'};
  if ($colour ne $self->{'_set_colour'}) {
    ### Image-Base-Prima-Drawable _set_colour() change to: $colour
    $self->{'_set_colour'} = $colour;
    $drawable->color ($self->colour_to_pixel ($colour));
  }
  return $drawable;
}

# not documented yet
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


# =item C<$image-E<gt>add_colours ($name, $name, ...)>
# 
# Add colours to the drawable's palette.  Colour names are the same for the
# drawing functions.
# 
#     $image->add_colours ('red', 'green', '#FF00FF');
# 
# The drawing functions automatically add a colour if it doesn't already exist
# but C<add_colours> can initialize the palette with particular desired
# colours.


1;
__END__

=for stopwords Ryde Prima RGB drawables

=head1 NAME

App::MathImage::Image::Base::Prima::Drawable -- draw into Prima window, image, etc

=for test_synopsis my ($d)

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Prima::Drawable;
 my $image = App::MathImage::Image::Base::Prima::Drawable->new
               (-drawable => $d);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Prima::Drawable> is a subclass of C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Prima::Drawable

=head1 DESCRIPTION

C<App::MathImage::Image::Base::Prima::Drawable> extends C<Image::Base> to draw into a
C<Prima::Drawable> drawables, meaning a widget window, off-screen image,
printer, etc.

The native Prima drawing has lots more features, but this module is an easy
way to point C<Image::Base> style code at a Prima image etc.

Colours names for drawing are the "Blue" etc from the Prima colour constants
C<cl::Blue> etc (see L<Prima::Drawable/Color space>), plus 2-digit #RRGGBB
or 4-digit #RRRRGGGGBBBB hex.  Internally Prima works in 8-bit RGB
components, so 4-digit values are truncated.

X,Y coordinates are the usual C<Image::Base> style 0,0 at the top-left
corner.  Prima works from 0,0 as the bottom-left but
C<App::MathImage::Image::Base::Prima::Drawable> converts.  There's no support for the Prima
"translate" origin shift yet.

None of the drawing functions do a C<$drawable-E<gt>begin_paint>.  That's
left to the application, and of course happens automatically for an
C<onPaint> handler.  The symptom of forgetting is that lines, rectangles and
ellipses don't draw anything.  (In the current code C<xy> might come out
since it uses C<$drawable-E<gt>pixel>, but don't rely on that.)

=head1 FUNCTIONS

=over 4

=item C<$image = App::MathImage::Image::Base::Prima::Drawable-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A C<Prima::Drawable> object must be
given.

    $image = App::MathImage::Image::Base::Prima::Drawable->new (-drawable => $d);

=item C<$colour = $image-E<gt>xy ($x, $y)>

=item C<$image-E<gt>xy ($x, $y, $colour)>

Get or set the pixel at C<$x>,C<$y>.

Currently colours returned by a get are always 2-digit hex #RRGGBB.

=back

=head1 ATTRIBUTES

=over

=item C<-drawable> (C<Prima::Drawable>)

The target drawable.

=item C<-width> (integer, read-only)

=item C<-height> (integer, read-only)

The width and height of the underlying drawable.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Prima::Drawable>

=cut
