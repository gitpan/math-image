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


package App::MathImage::Image::Base::Imlib2;
use 5.004;
use strict;
use Carp;
use Image::Imlib2 ();

use vars '$VERSION', '@ISA';
$VERSION = 69;

use Image::Base;
@ISA = ('Image::Base');

# uncomment this to run the ### lines
#use Devel::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Image-Base-Imlib2 new(): %params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    my $self = $class;
    $class = ref $class;
    if (! defined $params{'-imlib'}) {
      $params{'-imlib'} = $self->get('-imlib')->clone;
    }
    # inherit everything else
    %params = (%$self, %params);
    ### copy params: \%params
  }

  if (! defined $params{'-imlib'}) {
    my $width  = delete $params{'-width'};
    my $height = delete $params{'-height'};

    # same 256 default as Image::Imlib2->new() itself
    if (! defined $width) { $width = 256; }
    if (! defined $height) { $height = 256; }

    $params{'-imlib'} = Image::Imlib2->new ($width, $height);
  }
  my $self = bless {}, $class;
  $self->set (%params);

  if (defined $params{'-file'}) {
    $self->load;
  }

  ### new made: $self
  return $self;
}


my %attr_to_get_method = (-width       => 'width',
                          -height      => 'height',
                          -file_format => sub {
                            croak "Cannot get -file_format (write-only)";
                          },
                         );
sub _get {
  my ($self, $key) = @_;
  ### Image-Base-Imlib2 _get(): $key

  if (my $method = $attr_to_get_method{$key}) {
    ### $method
    ### is: $self->{'-imlib'}->$method
    return  $self->{'-imlib'}->$method
  }
  return $self->SUPER::_get ($key);
}

my %attr_to_method = (-quality_percent => 'set_quality',
                      -file_format     => 'image_set_format',
                     );
sub set {
  my ($self, %param) = @_;
  ### Image-Base-Imlib2 set(): \%param

  foreach my $key ('-width','-height') {
    if (exists $param{$key}) {
      croak "Attribute $key is read-only";
    }
  }

  # apply this first
  if (my $imlib = delete $param{'-imlib'}) {
    $self->{'-imlib'} = $imlib;
  }

  my $imlib = $self->{'-imlib'};

  foreach my $key (keys %param) {
    if (my $method = $attr_to_method{$key}) {
      $imlib->$method ($param{$key});
    }
  }

  %$self = (%$self, %param);
}

sub load {
  my ($self, $filename) = @_;
  ### Image-Base-Imlib2 load(): @_
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  $self->{'-imlib'} = Image::Imlib2->load ($filename);

  ### imlib: $self->{'-imlib'}
  ### size: $self->{'-imlib'}->width.'x'.$self->{'-imlib'}->height
}

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-Imlib2 save(): @_
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename

  $self->{'-imlib'}->save ($filename);
}

sub _set_colour {
  my ($self, $colour) = @_;
  my $imlib = $self->{'-imlib'};
  my @rgba;
  if ($colour eq 'None') {
    $imlib->set_color (0,0,0,0);

  } elsif ($colour =~ /^#(([0-9A-F]{3}){1,4})$/i) {
    my $len = length($1)/3; # of each group, so 1,2,3 or 4
    $imlib->set_color
      ((map {hex(substr($_ x 2, 0, 2))}  # first 2 chars of replicated
        substr ($colour, 1, $len),      # full groups
        substr ($colour, 1+$len, $len),
        substr ($colour, -$len)),
       255); # alpha
  } else {
    croak "Unrecognised colour: $colour";
  }
  return $imlib;
}


sub xy {
  my ($self, $x, $y, $colour) = @_;
  ### Image-Base-Imlib2 xy: $x,$y,$colour
  my $imlib = $self->{'-imlib'};
  if (@_ == 4) {
    _set_colour($self,$colour)->draw_point ($x, $y);

  } else {
    my ($r,$g,$b,$a) = $imlib->query_pixel ($x, $y);
    ### rgba: "$r,$g,$b,$a"
    if ($a == 0) {
      return 'None';
    }
    return sprintf ('#%02X%02X%02X', $r, $g, $b);
  }
}
sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  ### Image-Base-Imlib2 line: @_
  _set_colour($self,$colour)->draw_line ($x1,$y1, $x2,$y2);
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Imlib2 rectangle: @_

  my $method = ($fill ? 'fill_rectangle' : 'draw_rectangle');
  _set_colour($self,$colour)->$method ($x1,$y1,
                                       $x2-$x1+1,
                                       $y2-$y1+1);
}

sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Imlib2 ellipse: "$x1, $y1, $x2, $y2, $colour"

  my $a = $x2 - $x1;
  my $b = $y2 - $y1;
  ### diameters ...
  ### $a
  ### $b

    shift->SUPER::ellipse(@_);

  # if (($a & 1) || ($b & 1)) {
  # 
  # } else {
  #   $a = $a/2;
  #   $b = $b/2;
  #   ### centre: $x1+$a, $y1+$b
  #   ### $a
  #   ### $b
  #   my $method = ($fill ? 'fill_ellipse' : 'draw_ellipse');
  #   _set_colour($self,$colour)->$method ($x1 + $a,
  #                                        $y1 + $b,
  #                                        $a, $b);
  # }
}

sub diamond {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Imlib2 diamond() ...

  my $imlib = _set_colour($self,$colour);

  # 0 1 2 3 4
  # x1=0, x2=4 -> xh=2
  #
  # 0 1 2 3 4 5
  # x1=0, x2=5 -> xh=2
  #
  my $xh = ($x2 - $x1);
  my $yh = ($y2 - $y1);

  # Imlib2 1.4.4 does something fishy in draw_polygon() for a 1-high shape,
  # ie. y1==y2, ending up not drawing the right half of the shape.
  $fill ||= ($yh == 0);

  my $xeven = ($xh & 1);
  my $yeven = ($yh & 1);
  $xh = int($xh / 2);
  $yh = int($yh / 2);
  ### $xh
  ### $yh
  ### top lo: $x1+$xh
  ### top hi: $x2-$xh

  my $poly = Image::Imlib2::Polygon->new;

  # top centre
  $poly->add_point ($x1+$xh,$y1);

  # left
  $poly->add_point ($x1,$y1+$yh);
  if ($yeven) { $poly->add_point ($x1,$y2-$yh); }

  # bottom
  $poly->add_point ($x1+$xh,$y2);
  if ($xeven) { $poly->add_point ($x2-$xh,$y2); }

  # right
  if ($yeven) { $poly->add_point ($x2,$y2-$yh); }
  $poly->add_point ($x2,$y1+$yh);

  # top again
  if ($xeven) { $poly->add_point ($x2-$xh,$y1); }

  if ($fill) {
    $poly->fill;
  } else {
    $imlib->draw_polygon ($poly, 1);
  }
}

# sub add_colours {
#   my $self = shift;
#   ### add_colours: @_
#   $self->{'-imlib'}->addcolors (colors => \@_);
# }


1;
__END__

=for stopwords PNG Imlib2 filename Ryde Zlib Imlib2 RGB JPEG PNM GIF BMP ICO Paletted paletted pre-load png jpeg imager hotspot Image-Base-Imlib2 paletted

=head1 NAME

App::MathImage::Image::Base::Imlib2 -- draw images using Imlib2

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Imlib2;
 my $image = App::MathImage::Image::Base::Imlib2->new (-width => 100,
                                       -height => 100);
 $image->rectangle (0,0, 99,99, 'white');
 $image->xy (20,20, 'black');
 $image->line (50,50, 70,70, '#FF00FF');
 $image->line (50,50, 70,70, '#0000AAAA9999');
 $image->save ('/some/filename.png');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Imlib2> is a subclass of C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Imlib2

=head1 DESCRIPTION

C<App::MathImage::Image::Base::Imlib2> extends C<Image::Base> to create or
update image files using the C<Image::Imlib2> module.

As of Imlib2 1.4.4 the following file formats are available, provided for
some of them that Imlib2 was built with supporting libraries (such as
C<libpng>).

    PNG, JPEG, TIFF, PNM, BMP
    GIF    read-only
    XPM    read-only
    TGA    Targa
    LBM    Amiga Paint, read-only
    ARGB   raw format from Imlib (?)

=head2 Colour Names

There's no named colours as such, only hex and a special "None" for
transparent

    #RGB
    #RRGGBB
    #RRRGGGBBB
    #RRRRGGGGBBBB
    None             transparent

When loading XPM files F</usr/share/X11/rgb.txt> or similar is consulted for
named colours in the file, but that's not made available to later drawing
operations.

=head1 FUNCTIONS

=over 4

=item C<$image = App::MathImage::Image::Base::Imlib2-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A new image can be started with
C<-width> and C<-height>,

    $image = App::MathImage::Image::Base::Imlib2->new (-width => 200, -height => 100);

Or an existing file can be read,

    $image = App::MathImage::Image::Base::Imlib2->new (-file => '/some/filename.png');

Or an C<Image::Imlib2> object can be given,

    my $imlibobj = Image::Imlib2->new (20, 10);
    $image = App::MathImage::Image::Base::Imlib2->new (-imlib => $imlibobj);

=item C<$new_image = $image-E<gt>new (key=E<gt>value,...)>

Create and return a copy of C<$image>.  The Imlib object within C<$image> is
cloned per C<$imlib-E<gt>clone()>.  Optional key/value parameters are
applied to the new image as per C<set()>.

    # copy image, new compression level
    my $new_image = $image->new (-zlib_compression => 9);

=item C<< $image->load >>

=item C<< $image->load ($filename) >>

Read the C<-file>, or set C<-file> to C<$filename> and then read.

This creates and sets a new underlying C<-imlib> because it's not possible
to read into an existing Imlib2 object, only create a new one from the load.

=item C<$image-E<gt>save ()>

=item C<$image-E<gt>save ($filename)>

Save to C<-file>, or with a C<$filename> argument set C<-file> then save to
that.

The file format is taken from the C<-file_format> (see below) if that was
set by a C<load> or explicit C<set>, otherwise Imlib2 follows the filename
extension.  In both cases if format or extension is unrecognised then
C<save()> croaks.

=back

=head1 ATTRIBUTES

=over

=item C<-width> (integer, create-only)

=item C<-height> (integer, create-only)

The size of the underlying C<Image::Imlib2> is set when created and can't be
changed after that.  (Is that right?)

=item C<-imlib>

The underlying C<Image::Imlib2> object.

=item C<-file_format> (string or C<undef>, write-only)

The file format as a string like "png" or "jpeg".

After C<load()> the C<-file_format> is the format read.  Setting
C<-file_format> can change the format for a subsequent C<save()>.

This is applied with C<$imlib-E<gt>set_file_format()> and is currently
write-only.

=item C<-quality_percent> (0 to 100, write-only)

The image quality for saving to JPEG format.  JPEG compresses by reducing
colours and resolution in ways that are not too noticeable to the human eye.
100 means full quality, no such reductions.

=back

=head1 BUGS

Imlib2 interprets filenames with a colon like "name:foo.bar" as meaning a
sub-part of certain file formats.  If the full "name:foo.bar" exists and is
a ordinary file (not a char special) then it loads that, otherwise it tries
"name" alone.  This is unlike other C<Image::Base> modules and the intention
would be to avoid it in C<load()> and C<save()> in the interests of
consistency, if possible.

In the current implementation C<ellipse()> is done with the C<Image::Base>
code, since in Imlib2 1.4.4 the native ellipse drawing seems a bit dubious,
going outside the requested size.  In any case they would only be applicable
for odd sides, meaning C<$x2-$x1+1> and C<$y2-$y1+1> both odd numbers, since
they take an x,y centre and a,b semi-radii must be integers.

=head1 SEE ALSO

L<Image::Base>,
L<Image::Imlib2>

file://usr/share/doc/libimlib2-dev/html/index.html

=cut

# =item C<-zlib_compression> (integer 0-9)
# 
# The amount of data compression to apply when saving.  The value is Zlib
# style 0 for no compression up to 9 for maximum.



# In the current implementation ellipses with odd sides (meaning C<$x2-$x1+1>
# and C<$y2-$y1+1> both odd numbers) are drawn with Imlib2 and the rest go to
# C<Image::Base>, because as of Imlib2 1.4.4 the native ellipse drawing takes
# a centre x,y and a,b semi-radii which must be integers.  This different
# handling for different sizes is a bit inconsistent.
