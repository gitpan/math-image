# xy() read back rgb?



# Copyright, 2011 Kevin Ryde

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


package App::MathImage::Image::Base::Gtk::Gdk::Drawable;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 76;

use Image::Base;
@ISA = ('Image::Base');

# uncomment this to run the ### lines
#use Devel::Comments;


sub new {
  my ($class, %params) = @_;
  my $self = bless { _gc_colour => '',
                     _gc_colour_pixel => -1,
                   }, $class;
  ### Image-Base-Gtk-Gdk-Drawable new: $self
  $self->set (%params);
  return $self;
}

my %attr_to_get_method = (-depth    => sub {
                            # my ($window) = @_;
                            # return $window->get_visual->get_depth;
                          },
                          # no get_width method or property, just
                          # get_size(), and the return from it is
                          # ($height,$width)
                          -width  => sub { ($_[0]->get_size)[1] },
                          -height => sub { ($_[0]->get_size)[0] },
                         );
sub _get {
  my ($self, $key) = @_;

  if (my $method = $attr_to_get_method{$key}) {
    return $self->{'-drawable'}->$method;
  }
  if ($key eq '-pixmap' || $key eq '-window') {  # aliasing
    $key = '-drawable';
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  ### Image-Base-Gtk-Gdk-Drawable set: \%params

  foreach my $key ('-depth') {
    if (exists $params{$key}) {
      croak "Attribute $key is read-only";
    }
  }

  if (exists $params{'-gc'}) {
    # when setting -gc no longer assume the current foreground pixel
    $params{'_gc_colour'} = '';
    $params{'_gc_pixel'} = -1;
  }

  # aliasing
  if (exists $params{'-pixmap'}) {
    $params{'-drawable'} = delete $params{'-pixmap'};
  }
  if (exists $params{'-window'}) {
    $params{'-drawable'} = delete $params{'-window'};
  }

  # set -drawable now so as to apply -colormap and size to possible new one
  if (exists $params{'-drawable'}) {
    $self->{'-drawable'} = delete $params{'-drawable'};
  }

  my $width  = delete $params{'-width'};
  my $height = delete $params{'-height'};
  if (defined $width || defined $height) {
    if (! defined $width)  { $width  = ($self->{'-drawable'}->get_size)[1]; }
    if (! defined $height) { $height = ($self->{'-drawable'}->get_size)[0]; }
    $self->{'-drawable'}->resize ($width, $height);
  }

  %$self = (%$self, %params);
  ### set leaves: $self
}

#------------------------------------------------------------------------------
# drawing

sub xy {
  my ($self, $x, $y, $colour) = @_;
  my $drawable = $self->{'-drawable'};
  if (@_ >= 4) {
    ### Image-GtkGdkDrawable xy: "$x, $y, $colour"
    $drawable->draw_point ($self->gc_for_colour($colour), $x, $y);
  } else {
    ### Image-GtkGdkDrawable xy() fetch: "$x, $y"

    # ENHANCE-ME: pixel colour fetch from colormap ?
    my $gdkimage = Gtk::Gdk::Image->get ($drawable, $x,$y, 1,1);
    return $gdkimage->get_pixel (0,0);



    # ### $pixel
    # ### $colormap
    # my $visual = $colormap->get_visual;
    # ### $visual
    # return $pixel;

    # my $visual_type = $visual->get_type;
    # ### $visual_type
    # my $color = $colormap->color ($pixel);  # not range checked ...
    # ### $color
    # if ($color) {
    #   return sprintf '#%04X%04X%04X',
    #     $color->red, $color->green, $color->blue;
    # }

    # get_from_drawable() ref count bad in 0.7009
    # if (my $colormap = $self->get('-colormap')) {
    #   ### use pixbuf ...
    #   require Gtk::Gdk::Pixbuf;
    #   Gtk::Gdk::Pixbuf->init;
    #   my $pixbuf = Gtk::Gdk::Pixbuf->new (0,     # colorspace rgb
    #                                       0,     # has_alpha
    #                                       8,     # bits_per_sample
    #                                       1,1);  # width,height
    #   ### $pixbuf
    #   ### $drawable
    #   ### $colormap
    #   Gtk::Gdk::Pixbuf::get_from_drawable ($drawable, $colormap,
    #                               $x,$y,  # src x,y
    #                               0,0,    # dst x,y
    #                               1,1);   # width,height
    #   return sprintf '#%04X%04X%04X', unpack 'CCC', $pixbuf->get_pixels (0,0);
    # } else {
    #    }
  }
}

# Crib note: no limit on how many points passed to draw_points().  The
# underlying xlib XDrawPoints() automatically splits into multiple PolyPoint
# requests as necessary.
#
sub Image_Base_Other_xy_points {
  my $self = shift;
  my $colour = shift;
  ### Image_Base_Other_xy_points $colour
  ### len: scalar(@_)
  @_ or return;

  ### drawable: $self->{'-drawable'}
  ### gc: $self->gc_for_colour($colour)
  unshift @_, $self->{'-drawable'}, $self->gc_for_colour($colour);
  ### len: scalar(@_)
  ### $_[0]
  ### $_[1]

  # shift/unshift changes the first two args from self,colour to drawable,gc
  # does that save stack copying?
  my $code = $self->{'-drawable'}->can('draw_points');
  goto &$code;

  # the plain equivalent ...
  # $self->{'-drawable'}->draw_points ($self->gc_for_colour($colour), @_);
}

sub line {
  my ($self, $x1,$y1, $x2,$y2, $colour) = @_;
  ### Image-GtkGdkDrawable line()
  $self->{'-drawable'}->draw_line ($self->gc_for_colour($colour),
                                   $x1,$y1, $x2,$y2);
}

# $x1==$x2 and $y1==$y2 on $fill==false may or may not draw that x,y point
# outline with gc line_width==0
    # or alternately $drawable->draw_point ($gc, $x1,$y1);
#
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  # ### Image-GtkGdkDrawable rectangle: "$x1, $y1, $x2, $y2, $colour, $fill"
  $fill = !! $fill;
  $fill ||= ($x1 == $x2 || $y1 == $y2);
  $self->{'-drawable'}->draw_rectangle ($self->gc_for_colour($colour), $fill,
                                        $x1, $y1,
                                        $x2-$x1+$fill, $y2-$y1+$fill);

  # or with WidgetBits,
  # Gtk::Ex::GdkBits::draw_rectangle_corners
  #     ($self->{'-drawable'}
  #      $self->gc_for_colour($colour),
  #      $fill, $x1,$y1, $x2,$y2);

}

# Per notes in Image::Base::X11::Protocol::Drawable, a filled arc ellipse is
# effectively 0.5 pixel smaller.  To make sure rightmost and bottom pixels
# are drawn for now try an unfilled on top of a filled to get that extra 0.5
# around the outside.  Can it be done better?
#
sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-GtkGdkDrawable ellipse: "$x1, $y1, $x2, $y2, $colour, ".($fill||0)
  my $drawable = $self->{'-drawable'};
  my $gc = $self->gc_for_colour($colour);
  my $w = $x2 - $x1;
  my $h = $y2 - $y1;
  if ($w <= 1 || $h <= 1) {
    # 1 or 2 pixels high or wide
    $self->{'-drawable'}->draw_rectangle ($gc, 1,  # filled
                                          $x1, $y1, $w+1, $h+1);
  } else {
    foreach my $fillarg (0 .. !!$fill) {
      $drawable->draw_arc ($gc, $fillarg,
                           $x1, $y1, $w, $h,
                           0, 360*64);  # angles in 64ths of a 360 degrees
    }
  }
}

sub diamond {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-GtkGdkDrawable diamond: "$x1, $y1, $x2, $y2, $colour, ".($fill||0)
  my $drawable = $self->{'-drawable'};
  my $gc = $self->gc_for_colour($colour);

  if ($x1==$x2 && $y1==$y2) {
    # 1x1 polygon draws nothing, do it as a point instead
    $drawable->draw_point ($gc, $x1,$y1);

  } else {
    my $xh = ($x2 - $x1);
    my $yh = ($y2 - $y1);
    my $xeven = ($xh & 1);
    my $yeven = ($yh & 1);
    $xh = int($xh / 2);
    $yh = int($yh / 2);
    ### assert: $x1+$xh+$xeven == $x2-$xh
    ### assert: $y1+$yh+$yeven == $y2-$yh

    my @points = ($x1+$xh, $y1,  # top centre

                  # left
                  $x1, $y1+$yh,
                  ($yeven ? ($x1, $y2-$yh) : ()),

                  # bottom
                  $x1+$xh, $y2,
                  ($xeven ? ($x2-$xh, $y2) : ()),

                  # right
                  ($yeven ? ($x2, $y2-$yh) : ()),
                  $x2, $y1+$yh,

                  ($xeven ? ($x2-$xh, $y1) : ()),
                  $x1+$xh, $y1);  # back to start
    foreach my $fillarg (0 .. !!$fill) {
      $drawable->draw_polygon ($gc,
                               $fillarg,
                               @points);
    }
  }
}

#------------------------------------------------------------------------------
# colours

# return '-gc' with its foreground set to $colour
# -gc is created if not already set
# the colour set is recorded to save work if the next drawing is the same
#
sub gc_for_colour {
  my ($self, $colour) = @_;
  my $gc = $self->{'-gc'};
  if ($colour ne $self->{'_gc_colour'}) {
    ### gc_for_colour change: $colour

    my $colorobj = $self->colour_to_colorobj($colour);
    ### pixel: sprintf("%#X",$colorobj->pixel)

    $self->{'_gc_colour'} = $colour;
    if ($colorobj->pixel ne $self->{'_gc_colour_pixel'}) {
      $self->{'_gc_colour_pixel'} = $colorobj->pixel;
      if (! $gc) {
        return ($self->{'-gc'}
                = Gtk::Gdk::GC->new ($self->{'-drawable'},
                                     { foreground => $colorobj }));
      }
      $gc->set_foreground ($colorobj);
    }
  }
  return $gc;
}

use constant::defer _COLOROBJ_SET => sub {
  my $color = Gtk::Gdk::Color->parse_color ('#FFFFFF');
  $color->pixel(1);
  $color->{'pixel'} = 1;
  ### $color
  return $color;
};
use constant::defer _COLOROBJ_CLEAR => sub {
  my $color = Gtk::Gdk::Color->parse_color ('#000');
  $color->pixel(0);
  $color->{'pixel'} = 0;
  ### $color
  return $color;
};

sub colour_to_colorobj {
  my ($self, $colour) = @_;
  ### colour_to_colorobj(): $colour

  if ($colour =~ /^\d+$/) {
    my $colorobj = Gtk::Gdk::Color->parse_color ('#000');
    $colorobj->pixel($colour);
    return $colorobj;
  }
  if ($colour eq 'set') {
    return _COLOROBJ_SET();
  }
  if ($colour eq 'clear') {
    return _COLOROBJ_CLEAR();
  }

  my $drawable = $self->{'-drawable'};
  my $colormap = $self->get('-colormap');
  if (! $colormap) {
    # if ($drawable->get_depth == 1) {
    #   if ($colour =~ /^#(000)+$/) {
    #     return Gtk::Gdk::Color->new (0,0,0, 0);
    #   } elsif ($colour  =~ /^#(FFF)+$/i) {
    #     return Gtk::Gdk::Color->new (0,0,0, 1);
    #   }
    # }
    croak "No colormap to interpret colour: $colour";
  }

  # think parse and rgb_find are client-side operations, no need to cache
  # the results
  #
  my $colorobj = Gtk::Gdk::Color->parse_color ($colour)
    || croak "Cannot parse colour: $colour";
  ### $colorobj
  $colorobj = $colormap->color_alloc ($colorobj);
  ### $colorobj
  return $colorobj;
}

1;
__END__

=for stopwords resized filename Ryde Gdk bitmap pixmap pixmaps colormap colormaps Image-Base-Gtk Pango Gtk

=head1 NAME

App::MathImage::Image::Base::Gtk::Gdk::Drawable -- draw into a Gdk window or pixmap

=for test_synopsis my $win_or_pixmap

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Gtk::Gdk::Drawable;
 my $image = App::MathImage::Image::Base::Gtk::Gdk::Drawable->new
                 (-drawable => $win_or_pixmap);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Gtk::Gdk::Drawable> is a subclass of
C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Gtk::Gdk::Drawable

=head1 DESCRIPTION

I<In progress ...>

C<App::MathImage::Image::Base::Gtk::Gdk::Drawable> extends C<Image::Base> to draw into a
Gdk drawable, meaning either a window or a pixmap.

Colour names are anything recognised by
C<< Gtk::Gdk::Color->parse_color() >>, which means various names like "pink"
plus hex #RRGGBB or #RRRRGGGGBBB.  Special names "set" and "clear" mean
pixel values 1 and 0 for use with bitmaps.

The C<Image::Base::Gtk::Gdk::Pixmap> subclass has some specifics for
creating pixmaps, but this base Drawable is enough to draw into an existing
one.

Native Gdk drawing does much more than C<Image::Base> but if you have some
generic pixel twiddling code for C<Image::Base> then this Drawable class
lets you point it at a Gdk window etc.  Drawing into a window is a good way
to show slow drawing progressively, rather than drawing into a pixmap or
image file and only displaying when complete.  See C<Image::Base::Multiplex>
for a way to do both simultaneously.

=head1 FUNCTIONS

See L<Image::Base/FUNCTIONS> for the behaviour common to all Image-Base
classes.

=over 4

=item C<$image = App::MathImage::Image::Base::Gtk::Gdk::Drawable-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A C<-drawable> parameter must be
given,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Drawable->new
                 (-drawable => $win_or_pixmap);

Further parameters are applied per C<set> (see L</ATTRIBUTES> below).

=item C<$image-E<gt>xy ($x, $y, $colour)>

Get or set the pixel at C<$x>,C<$y>.

In the current code colours are returned in #RRGGBB form and require a
colormap.  Perhaps in the future it will be #RRRRGGGGBBBB form since under X
there's 16-bit resolution.  Generally a colormap is required, though bitmaps
without a colormap give 0 and 1.  The intention is probably to have pixmaps
without colormaps give back raw pixel values.  Maybe bitmaps could give back
"set" and "clear" as an option.

Fetching a pixel is an X server round-trip and reading out a big region will
be slow.  The server can give a region or the entire drawable in one go, so
some function for that would be better if much fetching is needed.

=back

=head1 ATTRIBUTES

=over

=item C<-drawable> (C<Gtk::Gdk::Drawable> object)

The target drawable.

=item C<-width> (integer)

=item C<-height> (integer)

The size of the drawable per C<< $drawable->get_size() >>.

=item C<-colormap> (C<Gtk::Gdk::Colormap>, or C<undef>)

The colormap in the underlying C<-drawable> per
C<< $drawable->get_colormap >>.  Windows always have a colormap, but pixmaps
may or may not.

=item C<-depth> (integer, read-only)

The number of bits per pixel in the drawable, from
C<< $drawable->get_depth >>.

=back

=cut
