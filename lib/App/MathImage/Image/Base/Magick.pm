# antialias force ?

# literal filename, no %03d


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
use warnings;
use Carp;
use Image::Magick;
use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 41;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Image-Base-Magick new(): %params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    my $self = $class;
    if (! defined $params{'-imagemagick'}) {
      $params{'-imagemagick'} = $self->get('-imagemagick')->Clone;
    }
    # inherit everything else
    %params = (%$self, %params);
    ### copy params: \%params
  }

  my $width  = delete $params{'-width'};
  my $height = delete $params{'-height'};
  my $size = (defined $width ? $width : 1).'x'.(defined $height ? $height : 1);

  if (! defined $params{'-imagemagick'}) {
    my $m = $params{'-imagemagick'} = Image::Magick->new (size => $size);
    $m->ReadImage('xc:black');
  }
  my $self = bless {}, $class;
  $self->set (%params);

  if (defined $self->{'filename'}) {
    $self->load;
  }

  ### new made: $self
  return $self;
}

my %attr_to_get = (# these not documented yet ...
                   -ncolours   => 'colors',
                   -file_format => 'magick',
                  );
my %attr_to_set = (-width       => 'width',
                   -height      => 'height',
                   # this not documented yet ...
                   -file_format => 'magick');
sub _get {
  my ($self, $key) = @_;
  ### Image-Base-Magick _get(): $key

  if (my $attribute = $attr_to_set{$key} || $attr_to_get{$key}) {
    ### Get: $attribute
    ### is: $self->{'-imagemagick'}->Get($attribute)
    return  $self->{'-imagemagick'}->Get($attribute);
  }
  return $self->SUPER::_get ($key);
}

sub set {
  my ($self, %param) = @_;
  ### Image-Base-Magick set(): \%param

  foreach my $key ('-ncolours') {
    if (exists $param{$key}) {
      croak "Attribute $key is read-only";
    }
  }

  # apply this first
  if (my $m = delete $param{'-imagemagick'}) {
    $self->{'-imagemagick'} = $m;
  }

  my @set;
  foreach my $key (keys %param) {
    if (my $attribute = $attr_to_set{$key}) {
      push @set, $attribute, delete $param{$key};
    }
  }
  if (@set) {
    ### @set
    $self->{'-imagemagick'}->Set(@set);
  }

  %$self = (%$self, %param);
}

sub load {
  my ($self, $filename) = @_;
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  $self->{'-imagemagick'}->Read ($filename);
}

# not yet documented ...
sub load_fh {
  my ($self, $fh) = @_;
  $self->{'-imagemagick'}->Read (file => $fh);
}

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-Magick save(): @_
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename
  $self->{'-imagemagick'}->Write (filename => $filename);
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  #### Image-Base-Magick xy: $x,$y,$colour
  my $m = $self->{'-imagemagick'};
  if (@_ == 4) {
    $m->Draw (stroke => $colour,
              primitive => 'rectangle',
              points => $x.','.($y+1));
    #     $m->Draw (stroke => $colour,
    #               primitive => 'point',
    #               points => "$x,$y");
  } else {
    my @rgb = $m->GetPixel (x => $x, y => $y);
    #### @rgb
    return sprintf '#%02X%02X%02X', map {$_*255} @rgb;
  }
}
sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  ### Image-Base-Magick line: @_
  $self->{'-imagemagick'}->Draw (fill => $colour,
                                 primitive => 'line',
                                 points => "$x1,$y1 $x2,$y2");
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Magick rectangle: @_
  # ### index: $self->colour_to_index($colour)

  my $m = $self->{'-imagemagick'};
  if ($x1==$x2 && $y1==$y2) {
    ### use point
    $m->Draw (fill => $colour,
              primitive => 'point',
              points => "$x1,$y1");
  } else {
    $m->Draw (($fill ? 'fill' : 'stroke'), $colour,
              primitive => 'rectangle',
              points => "$x1,$y1 $x2,$y2");
  }
}

sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Magick ellipse: "$x1, $y1, $x2, $y2, $colour"

  my $m = $self->{'-imagemagick'};
  if ($x1==$x2 || $y1==$y2) {
    ### use line
    $m->Draw (fill => $colour,
              primitive => 'line',
              points => "$x1,$y1 $x2,$y2");
  } else {
    ### ellipse: (($x1+$x2)/2).','.(($y1+$y2)/2).' '.(($x2-$x1)/2).','.(($y2-$y1)/2).' 0,360'
    $self->{'-imagemagick'}->Draw
      (($fill ? 'fill' : 'stroke') => $colour,
       primitive => 'ellipse',
       points => ((($x1+$x2)/2).','.(($y1+$y2)/2)
                  .' '.(($x2-$x1)/2).','.(($y2-$y1)/2)
                  .' 0,360'));
  }
}

sub add_colours {
  my $self = shift;
  ### add_colours: @_

  my $m = $self->{'-imagemagick'};
}

1;
__END__

=for stopwords PNG Magick filename undef Ryde Zlib ImageMagick RGB

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
update image files using the C<Image::Magick> module.

By default ImageMagick uses "anti-aliasing" to blur the edges of lines etc
drawn.  This is unlike the other C<Image::Base> modules but currently it's
not changed or overridden in the methods here.  Perhaps in the future that
will change.

Colour names are anything recognised by ImageMagick, as described under
"Color Names" in its documentation.  It has several RGB and other colour
model forms, and a table of names roughly per X11 plus a
F<config/colors.xml> for extras.

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
