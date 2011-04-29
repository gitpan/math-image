# literal filename, no %03d
# load() %d filename misses -file_format PNG somehow
# load() doesn't set -width / -height



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


package App::MathImage::Image::Base::Magick;
use 5.004;
use strict;
use Carp;
use Image::Magick;
use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 54;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Image-Base-Magick new(): %params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    my $self = $class;
    $class = ref $self;
    if (! defined $params{'-imagemagick'}) {
      $params{'-imagemagick'} = $self->get('-imagemagick')->Clone;
    }
    # inherit everything else
    %params = (%$self, %params);
    ### copy params: \%params
  }

  if (! defined $params{'-imagemagick'}) {
    # Crib: passing attributes to new() is the same as a subsequent set()
    # except you don't see an error return
    my $m = $params{'-imagemagick'} = Image::Magick->new;

    # must apply -width, -height as "size" before ReadImage()
    if (exists $params{'-width'} || exists $params{'-height'}) {
      my $width = delete $params{'-width'} || 0;
      my $height = delete $params{'-height'} || 0;
      if (my $err = $m->Set (size => "${width}x${height}")) {
        croak $err;
      }
    }
    if (my $err = $m->ReadImage('xc:black')) {
      croak $err;
    }
  }
  my $self = bless {}, $class;
  $self->set (%params);

  if (defined $params{'-file'}) {
    $self->load;
  }

  ### new made: $self
  return $self;
}

# "size" is the size of the canvas
# "width" and "height" are the size of a ReadImage() file, or something
# file:///usr/share/doc/imagemagick/www/perl-magick.html#get-attribute
#
sub _magic_get_width {
  my ($m, $idx) = @_;
  if (defined (my $size = $m->Get('size'))) {
    # ### $size
    # ### split: [ split /x/, $size ]
    # ### return: (split /x/, $size)[$idx||0]
    return (split /x/, $size)[$idx||0];
  } else {
    return 0;
  }
}
sub _magic_get_height {
  my ($m) = @_;
  _magic_get_width ($m, 1);
}
my %attr_to_get_func = (-width  => \&_magic_get_width,
                        -height => \&_magic_get_height,
                       );
my %attr_to_getset = (-file        => 'filename',
                      # these not documented yet ...
                      -ncolours    => 'colors',
                      -file_format => 'magick',
                     );
sub _get {
  my ($self, $key) = @_;
  ### Image-Base-Magick _get(): $key

  my $m = $self->{'-imagemagick'};
  if (my $func = $attr_to_get_func{$key}) {
    return &$func($m);
  }
  if (my $attribute = $attr_to_getset{$key}) {
    ### Get: $attribute
    ### is: $m->Get($attribute)
    return  $m->Get($attribute);
  }
  return $self->SUPER::_get ($key);
}

sub set {
  my ($self, %params) = @_;
  ### Image-Base-Magick set(): \%params

  foreach my $key ('-ncolours') {
    if (exists $params{$key}) {
      croak "Attribute $key is read-only";
    }
  }

  # apply this first
  if (my $m = delete $params{'-imagemagick'}) {
    $self->{'-imagemagick'} = $m;
  }

  my $m = $self->{'-imagemagick'};
  my @set;

  if (exists $params{'-width'} || exists $params{'-height'}) {
    # FIXME: might prefer a crop on shrink, and some sort of extend-only on
    # grow

    my @resize;
    my $width = delete $params{'-width'};
    if (defined $width && $width != _magic_get_width($m)) {
      push @resize, width => $width;
    }
    my $height = delete $params{'-height'};
    if (defined $height && $height != _magic_get_height($m)) {
      push @resize, height => $height;
    }
    # my $width = delete $params{'-width'};
    # my $height = delete $params{'-height'};
    if (! defined $width)  { $width = _magic_get_width($m); }
    if (! defined $height) { $height = _magic_get_height($m); }
    # $m->Resize (width => $width, height => $height);

    if (@resize) {
      $m->Resize (@resize);
    }
    push @set, size => "${width}x${height}";
  }

  foreach my $key (keys %params) {
    if (my $attribute = $attr_to_getset{$key}) {
      push @set, $attribute, delete $params{$key};
    }
  }
  if (@set) {
    ### @set
    if (my $err = $m->Set(@set)) {
      croak $err;
    }
  }

  %$self = (%$self, %params);
}

sub load {
  my ($self, $filename) = @_;
  ### Image-Base-Magick load()
  if (@_ > 1) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  my $m = $self->{'-imagemagick'};
  ### load filename: $filename

  # Not using Read($filename) because it won't read a file with "%d" in the
  # name.
  #
  # Must clear out @$m=() to avoid Read() using its set(filename) attribute
  # in preference to the given file=> handle (at least as of 6.6.0).
  #
  # Use sysopen() as as not to interpret whitespace etc on $filename.
  #
  require Fcntl;
  sysopen FH, $filename, Fcntl::O_RDONLY()
    or croak "Cannot open $filename: $!";
  binmode FH
    or croak "Cannot set binmode on $filename: $!";

  my @oldims = @$m;
  @$m = ();
  if (my $err = $m->Read (file => \*FH)) {
    @$m = @oldims;
    close FH;
    croak $err;
  }

  close FH
    or croak "Error closing $filename: $!";
  ### load leaves magick: $m

  $self->set('-file', $filename);
}

# not yet documented ...
sub load_fh {
  my ($self, $fh) = @_;
  ### Image-Base-Magick load_fh()
  if (my $err = $self->{'-imagemagick'}->Read (file => $fh)) {
    croak $err;
  }
}

# not yet documented ... and untested
sub load_string {
  my ($self, $str) = @_;
  if (my $err = $self->{'-imagemagick'}->Read (blob => $str)) {
    croak $err;
  }
}

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-Magick save(): @_
  if (@_ > 1) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename

  # Not using Write(filename=>) because it expands "%d" to a sequence
  # number, per file:///usr/share/doc/imagemagick/www/perl-magick.html#read
  #
  # Use sysopen() as as not to interpret whitespace etc on $filename.
  #
  require Fcntl;
  sysopen FH, $filename, Fcntl::O_WRONLY() | Fcntl::O_TRUNC() | Fcntl::O_CREAT()
    or croak "Cannot create $filename: $!";
  binmode FH
    or croak "Cannot set binmode on $filename: $!";

  if (my $err = $self->{'-imagemagick'}->Write (file => \*FH,
                                                _save_options($self))) {
    close FH;
    croak $err;
  }
  close FH or croak "Error closing $filename: $!";

  $self->set('-file', $filename);
}

# not yet documented ...
sub save_fh {
  my ($self, $fh) = @_;
  if (my $err = $self->{'-imagemagick'}->Write (file => $fh,
                                                _save_options($self))) {
    croak $err;
  }
}

sub _save_options {
  my ($self) = @_;

  # "quality" is zlib*10.  For undef or -1 omit the quality parameter.
  # file:///usr/share/doc/imagemagick/www/command-line-options.html#quality
  # coders/png.c WriteOnePNGImage() doing png_set_compression_level() of
  # quality/10, or maximum 9
  #
  my $m = $self->{'-imagemagick'};
  my $format = $m->Get('magick');
  if ($format eq 'png') {
    my $zlib_compression = $self->{'-zlib_compression'};
    if (defined $zlib_compression && $zlib_compression >= 0) {
      return (compression => $zlib_compression * 10);
    }
  }
  return;
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  ### Image-Base-Magick xy: $x,$y,$colour
  my $m = $self->{'-imagemagick'};
  my $err;
  if (@_ == 4) {
    $err = $m->set ("pixel[$x,$y]", $colour);

    # $err = $m->Draw (primitive => 'rectangle',
    #                  stroke => $colour,
    #                  points => $x.','.($y+1));
    # $err = $m->Draw (primitive => 'point',
    #                  stroke => $colour,
    #                  points => "$x,$y");

    # SetPixel() takes color=>[$r,$g,$b] arrayref, not a string
    # $err = $m->SetPixel (x=>$x, y=>$y, color=>$colour);

  } else {
    # cf $m->get("pixel[123,456]") gives a string "$r,$g,$g,$a"

    # GetPixel() gives list ($r,$g,$b) each in range 0 to 1
    my @rgb = $m->GetPixel (x => $x, y => $y);
    ### @rgb
    if (@rgb == 1) {
      $err = $rgb[0];
    } else {
      return sprintf '#%02X%02X%02X', map {$_*255} @rgb;
    }
  }
  if ($err) {
    croak $err;
  }
}
sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  ### Image-Base-Magick line: @_
  if (my $err = $self->{'-imagemagick'}->Draw (primitive => 'line',
                                               fill => $colour,
                                               points => "$x1,$y1 $x2,$y2")) {
    croak $err;
  }
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Magick rectangle: @_
  # ### index: $self->colour_to_index($colour)

  my $m = $self->{'-imagemagick'};
  my $err;
  if ($x1==$x2 && $y1==$y2) {
    # primitive=>rectangle of 1x1 seems to draw nothing

    ### use set pixel[]
    $err = $m->set ("pixel[$x1,$y1]", $colour);

    # $err = $m->Draw (primitive => 'point',
    #                  fill => $colour,
    #                  points => "$x1,$y1");

  } else {
    $err = $m->Draw (primitive => 'rectangle',
                     ($fill ? 'fill' : 'stroke'), $colour,
                     points => "$x1,$y1 $x2,$y2");
  }
  if ($err) {
    croak $err;
  }
}

sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Magick ellipse: "$x1, $y1, $x2, $y2, $colour"

  my $m = $self->{'-imagemagick'};
  my $w = $x2 - $x1;
  my $h = $y2 - $y1;
  my $err;
  if ($w || $h) {
    ### more than 1 pixel wide and/or high, primitive=>ellipse
    ### ellipse: (($x1+$x2)/2).','.(($y1+$y2)/2).' '.($w/2).','.($h/2).' 0,360'
    $err = $m->Draw (primitive => 'ellipse',
                     ($fill ? 'fill' : 'stroke') => $colour,
                     points => ((($x1+$x2)/2).','.(($y1+$y2)/2)
                                .' '
                                .($w/2).','.($h/2)
                                .' 0,360'));
  } else {
    ### only 1 pixel wide and/or high, primitive=>line
    $err = $m->Draw (primitive => 'line',
                     fill => $colour,
                     points => "$x1,$y1 $x2,$y2");
  }
  if ($err) {
    croak $err;
  }
}

# sub add_colours {
#   my $self = shift;
#   ### add_colours: @_
# 
#   my $m = $self->{'-imagemagick'};
# }

1;
__END__

=for stopwords PNG Magick filename undef Ryde Zlib Zlib's ImageMagick ImageMagick's RGB

=head1 NAME

App::MathImage::Image::Base::Magick -- draw images using Image Magick

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Magick;
 my $image = App::MathImage::Image::Base::Magick->new (-width => 100,
                                                       -height => 100);
 $image->rectangle (0,0, 99,99, 'white');
 $image->xy (20,20, 'black');
 $image->line (50,50, 70,70, '#FF00FF');
 $image->line (50,50, 70,70, '#0000AAAA9999');
 $image->save ('/some/filename.png');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Magick> is a subclass of C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Magick

=head1 DESCRIPTION

C<App::MathImage::Image::Base::Magick> extends C<Image::Base> to create or
update image files using C<Image::Magick>.

Colour names are anything recognised by ImageMagick,

    file:///usr/share/doc/imagemagick/www/color.html

It includes 1, 2 and 4-digit hex "#RGB", "#RRGGBB", "#RRRRGGGGBBBB", and
other colour model forms, and a table of names roughly per X11 plus a
F<config/colors.xml> for extras.

By default ImageMagick uses "anti-aliasing" to blur the edges of lines etc
drawn.  This is unlike the other C<Image::Base> modules but currently it's
not changed or overridden in the methods here.  Perhaps that will change.

=head1 FUNCTIONS

=over 4

=item C<$image = App::MathImage::Image::Base::Magick-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A new image can be started with
C<-width> and C<-height>,

    $image = App::MathImage::Image::Base::Magick->new (-width => 200, -height => 100);

Or an existing file can be read,

    $image = App::MathImage::Image::Base::Magick->new (-file => '/some/filename.png');

Or an C<Image::Magick> object can be given,

    $image = App::MathImage::Image::Base::Magick->new (-imagemagick => $mobj);

=back

=head1 ATTRIBUTES

=over

=item C<-width> (integer)

=item C<-height> (integer)

Setting these changes the size of the image.

=item C<-imagemagick>

The underlying C<Image::Magick> object.

=item C<-file> (string, default C<undef>)

The filename for C<load> or C<save>, or passed to C<new> to load a file.

ImageMagick normally expands a "%d" in filenames to a sequence number, but
that's avoided here, instead the filename is use literally, the same as
other C<Image::Base> classes do.

=item C<-zlib_compression> (integer 0-9 or -1, default C<undef>)

The amount of data compression to apply when saving.  The value is Zlib
style 0 for no compression up to 9 for maximum effort.  -1 means Zlib's
default, usually 6.  C<undef> or never set means ImageMagick's default,
which is 7.  (This attribute becomes the ImageMagick "quality" parameter.)

=back

=head1 SEE ALSO

L<Image::Base>,
L<Image::Base::GD>,
L<Image::Base::PNGwriter>,
L<Image::Magick>,
L<Image::Xbm>,
L<Image::Xpm>,
L<Image::Pbm>

=cut
