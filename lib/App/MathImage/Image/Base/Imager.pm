# Copyright 2011 Kevin Ryde

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


package App::MathImage::Image::Base::Imager;
use 5.004;
use strict;
use warnings;
use Carp;
use Imager;
use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 40;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Image-Base-Imager new(): %params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    my $self = $class;
    if (! defined $params{'-imager'}) {
      $params{'-imager'} = $self->get('-imager')->copy;
    }
    # inherit everything else
    %params = (%$self, %params);
    ### copy params: \%params
  }

  my $width  = delete $params{'-width'};
  my $height = delete $params{'-height'};
  if (! defined $params{'-imager'}) {
    my $i = $params{'-imager'} = Imager->new (xsize => $width,
                                              ysize => $height);
  }
  my $self = bless {}, $class;
  $self->set (%params);

  if (defined $self->{'filename'}) {
    $self->load;
  }

  ### new made: $self
  return $self;
}


my %attr_to_get_method = (-width    => 'getwidth',
                          -height   => 'getheight',
                          # these not documented yet ...
                          -ncolours => 'getcolorcount',
                          # -file_format => 'setformat',
                         );
sub _get {
  my ($self, $key) = @_;
  ### Image-Base-Imager _get(): $key

  if (my $method = $attr_to_get_method{$key}) {
    ### $method
    ### is: $self->{'-imager'}->$method
    return  $self->{'-imager'}->$method
  }
  return $self->SUPER::_get ($key);
}

my %attr_to_img_set = (-width  => 'xsize',
                       -height => 'ysize',
                       # this not documented yet ...
                       # -file_format => 'setformat',
                      );
sub set {
  my ($self, %param) = @_;
  ### Image-Base-Imager set(): \%param

  foreach my $key ('-ncolours') {
    if (exists $param{$key}) {
      croak "Attribute $key is read-only";
    }
  }

  # apply this first
  if (my $i = delete $param{'-imager'}) {
    $self->{'-imager'} = $i;
  }

  my @set;
  foreach my $key (keys %param) {
    if (my $attribute = $attr_to_img_set{$key}) {
      push @set, $attribute, delete $param{$key};
    }
  }
  if (@set) {
    ### @set
    $self->{'-imager'}->img_set(@set);
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
  my $i = $self->{'-imager'};
  $i->read (file => $filename)
    or croak "Cannot read $filename: ",$i->errstr;
}

# # not yet documented ...
# sub load_fh {
#   my ($self, $fh) = @_;
# }

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-Imager save(): @_
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename
  $self->{'-imager'}->write (file => $filename);
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  ### Image-Base-Imager xy: $x,$y,$colour
  my $i = $self->{'-imager'};
  if (@_ == 4) {
    $i->setpixel (x => $x, y => $y, color => $colour);

  } else {
    my $cobj = $i->getpixel (x => $x, y => $y);
    my ($r,$g,$b,$a) = $cobj->rgba;
    ### rgba: "$r,$g,$b,$a"
    # if ($a == 0) {
    #   return 'None';
    # }
    return sprintf ('#%02X%02X%02X', $r, $b, $g);
  }
}
sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  ### Image-Base-Imager line: @_
  $self->{'-imager'}->line (x1 => $x1,
                            y1 => $y1,
                            x2 => $x2,
                            y2 => $y2,
                            color => $colour);
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Imager rectangle: @_

  $self->{'-imager'}->box (xmin => $x1,
                           ymin => $y1,
                           xmax => $x2,
                           ymax => $y2,
                           color => $colour,
                           filled => $fill);
}

sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Imager ellipse: "$x1, $y1, $x2, $y2, $colour"

  my $i = $self->{'-imager'};
  my $diam = $x2-$x1;
  if (! ($diam & 1) && $y2-$y1 == $diam) {
    ### use circle
    $self->{'-imager'}->circle (x => ($x2+$x1)/2,
                                y => ($y2+$y1)/2,
                                r => $diam/2,
                                color => $colour,
                                filled => $fill);
  } else {
    ### use superclass ellipse
    shift->SUPER::ellipse (@_);
  }
}

sub add_colours {
  my $self = shift;
  ### add_colours: @_

  my $i = $self->{'-imager'};
}

1;
__END__

=for stopwords PNG Imager filename undef Ryde Zlib Imager RGB

=head1 NAME

App::MathImage::Image::Base::Imager -- draw images using Imager

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Imager;
 my $image = App::MathImage::Image::Base::Imager->new (-width => 100,
                                                       -height => 100);
 $image->rectangle (0,0, 99,99, 'white');
 $image->xy (20,20, 'black');
 $image->line (50,50, 70,70, '#FF00FF');
 $image->line (50,50, 70,70, '#0000AAAA9999');
 $image->save ('/some/filename.png');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Imager> is a subclass of C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Imager

=head1 DESCRIPTION

C<App::MathImage::Image::Base::Imager> extends C<Image::Base> to create or
update image files using the C<Image::Imager> module.

Colour names are any name recognised by C<Imager::Color>.  As of Imager
1.011 this means the GIMP F<Named_Colors> or X11 F<rgb.txt> names, or a hex
"#RGB", "#RRGGBB".

=head1 FUNCTIONS

=over 4

=item C<$image = App::MathImage::Image::Base::Imager-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A new image can be started with
C<-width> and C<-height>,

    $image = App::MathImage::Image::Base::Imager->new (-width => 200, -height => 100);

Or an existing file can be read,

    $image = App::MathImage::Image::Base::Imager->new (-file => '/some/filename.png');

Or an C<Image::Imager> object can be given,

    $image = App::MathImage::Image::Base::Imager->new (-imager => $iobj);

=back

=head1 ATTRIBUTES

=over

=item C<-width> (integer)

=item C<-height> (integer)

Setting these changes the size of the image.

=item C<-imager>

The underlying C<Image::Imager> object.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Imager>

L<Image::Base::GD>,
L<Image::Base::PNGwriter>,
L<Image::Xbm>,
L<Image::Xpm>,
L<Image::Pbm>

=cut
