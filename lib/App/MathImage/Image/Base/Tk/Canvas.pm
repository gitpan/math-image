# Copyright 2010, 2011 Kevin Ryde

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


# Tk::Canvas
# Tk::options  configure(), cget()
#

package App::MathImage::Image::Base::Tk::Canvas;
use 5.004;
use strict;
use Carp;

use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 65;

# uncomment this to run the ### lines
#use Devel::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Math-Image new(): %params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    croak "Cannot clone Image::Base::Tk::Canvas";

    # my $self = $class;
    # $class = ref $class;
    # if (! defined $params{'-tkcanvas'}) {
    #   $params{'-tkcanvas'} = $self->get('-tkcanvas')->copy;
    # }
    # # inherit everything else
    # %params = (%$self, %params);
    # ### copy params: \%params
  }

  if (! defined $params{'-tkcanvas'}) {
    my $for_widget = delete $params{'-for_widget'}
      || croak 'Must have -for_widget to create new Tk::Canvas';
    $params{'-tkcanvas'} = $for_widget->Canvas
      ((exists $params{'-width'} ? (-width => $params{'-width'}) : ()),
       (exists $params{'-height'} ? (-height => $params{'-height'}) : ()))->pack;
  }
  my $self = bless {}, $class;
  $self->set (%params);

  if (exists $params{'-file'}) {
    $self->load;
  }

  ### new made: $self
  return $self;
}


my %attr_to_option = (-width    => '-width',
                      -height   => '-height',
                     );
sub _get {
  my ($self, $key) = @_;
  ### Image-Base-Tk-Canvas _get(): $key
  if (my $option = $attr_to_option{$key}) {
    ### $option
    return $self->{'-tkcanvas'}->cget($option);
  }
  return $self->SUPER::_get ($key);
}

sub set {
  my ($self, %param) = @_;
  ### Image-Base-Tk-Canvas set(): \%param

  # apply this first
  if (my $tkcanvas = delete $param{'-tkcanvas'}) {
    $self->{'-tkcanvas'} = $tkcanvas;
  }

  {
    my @configure;
    foreach my $key (keys %param) {
      if (my $option = $attr_to_option{$key}) {
        push @configure, $option, delete $param{$key};
      }
    }
    ### @configure
    if (@configure) {
      $self->{'-tkcanvas'}->configure (@configure);
    }
  }

  %$self = (%$self, %param);
}

sub load {
  my ($self, $filename) = @_;
  ### Image-Base-Tk-Canvas load()
  croak "Cannot load into canvas";
}

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-Tk-Canvas save()
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  if (defined (my $ret = $self->{'-tkcanvas'}->postscript (-file => $filename))) {
    croak $ret;
  }
}
# undocumented ...
sub save_string {
  my ($self, $filename) = @_;
  ### Image-Base-Tk-Canvas save()
  return $self->{'-tkcanvas'}->postscript;
}

my %anchor_is_xcentre = (n => 1, centre => 1, s => 1);
my %anchor_is_xright = (ne => 1, e => 1, se => 1);
my %anchor_is_ycentre = (w => 1, centre => 1, e => 1);
my %anchor_is_ybot = (sw => 1, s => 1, se => 1);
                       
sub xy {
  my ($self, $x, $y, $colour) = @_;
  ### Image-Base-Tk-Canvas xy(): "$x,$y"

  my $tkcanvas = $self->{'-tkcanvas'};
  if (@_ > 3) {
    $tkcanvas->createRectangle($x,$y, $x+1,$y+1,
                               -fill => $colour,
                               -width => 0); # outline width
  } else {
    my $item = ($tkcanvas->find('overlapping',$x,$y,$x,$y))[0];
    if (! defined $item) {
      ### no overlapping item, return background: $tkcanvas->cget('-background')
      return $tkcanvas->cget('-background');
    }
    my $type = $tkcanvas->type($item);
    ### $item
    ### $type
    # FIXME: look at -activefill etc according to state
    if ($type eq 'rectangle' || $type eq 'oval' || $type eq 'polygon'
        || $type eq 'arc') {
      # FIXME: to do this properly would have to check if x,y is on the
      # outline, according to the width, or the fill area
      return (scalar($tkcanvas->itemcget($item,'-fill'))
              || scalar($tkcanvas->itemcget($item,'-outline')));
    }
    if ($type eq 'line' || $type eq 'text') {
      return scalar($tkcanvas->itemcget($item,'-fill'));
    }
    if ($type eq 'window') {
      my ($wx,$wy) = $tkcanvas->coords($item);
      ### $wx
      ### $wy
      my $widget = $tkcanvas->itemcget($item,'-window');
      my $width = $tkcanvas->itemcget($item,'-width') || $widget->reqwidth;
      my $height = $tkcanvas->itemcget($item,'-height') || $widget->reqheight;

      # change wx,wy to its top-left corner according to anchor
      my $anchor = $tkcanvas->itemcget($item,'-anchor');
      if ($anchor_is_xright{$anchor}) {
        $wx -= $width-1;
      } elsif ($anchor_is_xcentre{$anchor}) {
        $wx -= int(($width-1)/2);
      }
      if ($anchor_is_ybot{$anchor}) {
        $wy -= $height-1;
      } elsif ($anchor_is_ycentre{$anchor}) {
        $wy -= int(($height-1)/2);
      }

      # change x,y to a position within the $widget
      $x -= $wx;
      $y -= $wy;

      ### $anchor
      ### $wx
      ### $wy
      ### $width
      ### $height
      ### $x
      ### $y
      ### id: $widget->id
      if ($x < 0 || $y < 0 || $x >= $width || $y >= $height) {
        ### oops, why does overlapping give an out-of-range ? ...
        return undef;
      }
      $widget->update;
      require Tk::WinPhoto;
      my $photo = $widget->Photo (-format => 'window',
                                  -data => oct($widget->id));
      #      $photo->write ('/tmp/x.png', -format => 'xpm');
      ### rgb: $photo->get($x,$y)
      return sprintf ('#%02X%02X%02X', $photo->get ($x, $y));  # r,g,b
    }
    # if ($type eq 'image') {
    #   # copy Tk::Image to  Tk::Photo to get its pixels, maybe ...
    # }
    # if ($type eq 'grid') {
    #   # but never occurs as an "overlapping", or something ...
    # }
    # if ($type eq 'bitmap') {
    #   # either its -background or -foreground ...
    # }
    return undef;
  }
}

# lower and right edges are excluded when filled, per X11 style
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Tk-Canvas rectangle()
  $self->{'-tkcanvas'}->createRectangle($x1,$y1, $x2,$y2,
                                        -outline => $colour,
                                        ($fill ? (-fill => $colour) : ()));
}
sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Tk-Canvas ellipse()
  # seems that a 1xN or Nx1 pixel unfilled doesn't draw anything, so go filled
  $fill ||= ($x1 == $x2 || $y1 == $y2);
  $self->{'-tkcanvas'}->createOval($x1,$y1, $x2,$y2,
                                   -outline => $colour,
                                   ($fill ? (-fill => $colour) : ()));
}

sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  # must have 'projecting' to ensure the bottom right pixel drawn, per X style
  $self->{'-tkcanvas'}->createLine($x1,$y1, $x2,$y2,
                                   -fill => $colour,
                                   -capstyle => 'projecting');
}

sub diamond {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Tk-Canvas diamond()
  my $xh = ($x2 - $x1 + 1);
  my $yh = ($y2 - $y1 + 1);
  my $xeven = ! ($xh & 1);
  my $yeven = ! ($yh & 1);
  $xh = int($xh / 2);
  $yh = int($yh / 2);
  my $method = ($fill ? 'createPolygon' : 'createLine');
  $self->{'-tkcanvas'}->$method ($x1+$xh,$y1,  # top centre

                                 # left
                                 $x1,$y1+$yh,
                                 ($yeven ? ($x1,$y2-$yh) : ()),

                                 # bottom
                                 $x1+$xh,$y2,
                                 ($xeven ? ($x2-$xh,$y2) : ()),

                                 # right
                                 ($yeven ? ($x2,$y2-$yh) : ()),
                                 $x2,$y1+$yh,

                                 ($xeven ? ($x2-$xh,$y1) : ()),
                                 ($fill ? () : ($x1+$xh,$y1)),

                                 -fill => $colour);
}

1;
__END__

=for stopwords PNG filename Ryde Imager JPEG PNM GIF BMP png jpeg

=head1 NAME

Image::Base::Tk::Canvas -- draw into Tk::Canvas

=head1 SYNOPSIS

 use Image::Base::Tk::Canvas;
 my $image = Image::Base::Tk::Canvas->new (-width => 100,
                                       -height => 100);
 $image->rectangle (0,0, 99,99, 'white');
 $image->xy (20,20, 'black');
 $image->line (50,50, 70,70, '#FF00FF');
 $image->line (50,50, 70,70, '#0000AAAA9999');
 $image->save ('/some/filename.eps');

=head1 CLASS HIERARCHY

C<Image::Base::Tk::Canvas> is a subclass of C<Image::Base>,

    Image::Base
      Image::Base::Tk::Canvas

=head1 DESCRIPTION

C<Image::Base::Tk::Canvas> extends C<Image::Base> to add items to a
C<Tk::Canvas> widget.  There's no file reading, but encapsulated postscript
(EPS) can be written.

C<Tk::Canvas> has more features than are available here, but this module is
a novel way to point some C<Image::Base> code at a canvas.  In principle
there's no limit on how many items a canvas can hold, but if drawing lots of
individual pixels then C<Tk::Photo> and C<Image::Base::Tk::Photo> may be
better.

=head2 Colours

Colour names are anything recognised by L<Tk_GetColor(3tk)>, which means X11
style

    X server F<rgb.txt> names
    #RGB            hex
    #RRGGBB         hex
    #RRRGGGBBB      hex
    #RRRRGGGGBBBB   hex

Like Xlib, the shorter hex forms are padded with zeros, so "#FFF" means only
"#F000F000F000", which is a light grey rather than white.

=head1 FUNCTIONS

=over 4

=item C<$image = Image::Base::Tk::Canvas-E<gt>new (key=E<gt>value,...)>

Create and return a new canvas image object.  A new canvas can be created
with C<-width>, C<-height>, and a C<-for_widget> which is its parent

    $image = Image::Base::Tk::Canvas->new (-for_widget => $parent,
                                           -width => 200, -height => 100);

Or an existing C<Tk::Canvas> object can be given,

    $image = Image::Base::Tk::Canvas->new (-tkcanvas => $tkcanvas);

=item C<$colour = $image-E<gt>xy ($x, $y)>

=item C<$image-E<gt>xy ($x, $y, $colour)>

Get or set an individual pixel.  Setting an individual pixel adds a 1x1
rectangle.

Getting a pixel is currently implemented by looking for an item at C<$x,$y>
and picking out its colour.  This works well enough for the item types added
by this module but may be wrong for others, in particular an item outline is
not distinguished from its fill interior.  "window" items are read with a
C<Tk::WinPhoto> and may be a bit slow (and might even induce an Xlib error
if the window is off the edges of the screen).  "bitmap" items are not read
at all yet.

=item C<$image-E<gt>diamond ($x0, $y0, $x1, $y1, $colour)>

Draw a diamond shape within the rectangle top left ($x0,$y0) and bottom
right ($x1,$y1) using $colour.  If optional argument C<$fill> is true then
the diamond is filled.

In the current code a filled diamond uses a "polygon" item and an unfilled
uses a "line" segments item.  The line segments ensure interior points are
not part of the diamond for C<find("overlapping")> etc, the same as they're
not for an unfilled ellipse or rectangle.  Is that the best way?

=item C<$image-E<gt>load ()>

=item C<$image-E<gt>load ($filename)>

Currently there's no file format to read a canvas.

=item C<$image-E<gt>save ()>

=item C<$image-E<gt>save ($filename)>

Save encapsulated postscript to C<-file>, or with a C<$filename> argument
set C<-file> then save to that.

=back

=head1 ATTRIBUTES

=over

=item C<-width> (integer)

=item C<-height> (integer)

Setting these changes the size of the image.

=item C<-tkcanvas>

The underlying C<Tk::Canvas> object.

=item C<-file_format> (string or C<undef>)

The file format as a string like "png" or "jpeg", or C<undef> if unknown or
never set.

After C<load> the C<-file_format> is the format read.  Setting
C<-file_format> can change the format for a subsequent C<save>.

There's no attempt to check or validate the C<-file_format> value, since
it's possible to add new formats to Tk::Canvas at run time.  Expect C<save()> to
croak if the format is unknown.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Tk::Canvas>

=cut
