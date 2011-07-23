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


# Tk::Photo
# Tk::Image
# Tk::options  configure(), cget()
#
# Tk::PNG
# Tk::JPEG
#    loaders

package App::MathImage::Image::Base::Tk::Photo;
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
  ### Math-Image new() ...

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    croak "Cannot clone Image::Base::Tk::Photo";

    # my $self = $class;
    # $class = ref $class;
    # if (! defined $params{'-tkphoto'}) {
    #   $params{'-tkphoto'} = $self->get('-tkphoto')->copy;
    # }
    # # inherit everything else
    # %params = (%$self, %params);
    # ### copy params: \%params
  }

  if (! defined $params{'-tkphoto'}) {
    my $for_widget = delete $params{'-for_widget'}
      || croak 'Must have -for_widget to create new Tk::Photo';
    $params{'-tkphoto'} = $for_widget->Photo (-width => $params{'-width'},
                                              -height => $params{'-height'});
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
                      # -file_format => '-format',
                     );
sub _get {
  my ($self, $key) = @_;
  ### Image-Base-Tk-Photo _get(): $key
  if (my $option = $attr_to_option{$key}) {
    ### $option
    return $self->{'-tkphoto'}->cget($option);
  }
  return $self->SUPER::_get ($key);
}

sub set {
  my ($self, %param) = @_;
  ### Image-Base-Tk-Photo set(): \%param

  # apply this first
  if (my $tkphoto = delete $param{'-tkphoto'}) {
    $self->{'-tkphoto'} = $tkphoto;
  }

  {
    my @configure;
    foreach my $key (keys %param) {
      if (my $option = $attr_to_option{$key}) {
        my $value = delete $param{$key};
        push @configure, $option, $value;
      }
    }
    ### @configure
    if (@configure) {
      $self->{'-tkphoto'}->configure (@configure);
    }
  }

  %$self = (%$self, %param);
}

sub load {
  my ($self, $filename) = @_;
  ### Image-Base-Tk-Photo load()

  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  my $tkphoto = $self->{'-tkphoto'};
  $tkphoto->read ($filename);
    # or croak "Cannot load: ",$tkphoto->errstr;
  $self->set(-file_format => $tkphoto->cget('-format'));
}
# undocumented, untested ...
sub load_string {
  my ($self, $str) = @_;
  ### Image-Base-Tk-Photo load()
  my $tkphoto = $self->{'-tkphoto'};
  $tkphoto->configure (-data => $str);
  $self->set(-file_format => $tkphoto->cget('-format'));
}

my %format_to_module = (png  => 'Tk::PNG',
                        jpeg => 'Tk::JPEG',
                        tiff => 'Tk::TIFF',
                       );
sub _format_use {
  my ($format) = @_;
  if (my $module = $format_to_module{lc($format)}) {
    eval "require $module; 1" or die;
  }
  return $format;
}

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-Tk-Photo save()
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  my $tkphoto = $self->{'-tkphoto'};
  ### file: $filename

  # croaks if an error ...
  $tkphoto->write ($filename,
                   -format => _format_use($self->get('-file_format')));
}
# undocumented, untested ...
sub save_fh {
  my ($self, $fh) = @_;
  print $fh $self->save_string;
}
# undocumented, untested ...
sub save_string {
  my ($self, $fh) = @_;
  # croaks if an error ...
  return $self->{'-tkphoto'}->data
    (-format => _format_use($self->get('-file_format')));
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  ### Image-Base-Tk-Photo xy() ...

  my $tkphoto = $self->{'-tkphoto'};
  if (@_ > 3) {
    $tkphoto->put ($colour, -to => $x,$y, $x+1,$y+1);
  } else {
    return sprintf ('#%02X%02X%02X', $tkphoto->get ($x, $y));  # r,g,b
  }
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-Tk-Photo rectangle() ...
  if ($fill) {
    $self->{'-tkphoto'}->put ($colour, -to => $x1,$y1, $x2+1,$y2+1);
  } else {
    shift->SUPER::rectangle(@_);
  }
}
sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  ### Image-Base-Tk-Photo line(): "$x1,$y1, $x2,$y2"
  if ($x1 == $x2) {
    if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }
  } elsif ($y1 == $y2) {
    if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
  } else {
    shift->SUPER::line(@_);
    return;
  }
  ### put: "$x1,$y1, ".($x2+1).",".($y2+1)
  $self->{'-tkphoto'}->put ($colour, -to => $x1,$y1, $x2+1,$y2+1);
}

1;
__END__

=for stopwords PNG filename Ryde Imager JPEG PNM GIF BMP png jpeg

=head1 NAME

Image::Base::Tk::Photo -- draw into Tk::Photo

=head1 SYNOPSIS

 use Image::Base::Tk::Photo;
 my $image = Image::Base::Tk::Photo->new (-width => 100,
                                       -height => 100);
 $image->rectangle (0,0, 99,99, 'white');
 $image->xy (20,20, 'black');
 $image->line (50,50, 70,70, '#FF00FF');
 $image->line (50,50, 70,70, '#0000AAAA9999');
 $image->save ('/some/filename.png');

=head1 CLASS HIERARCHY

C<Image::Base::Tk::Photo> is a subclass of C<Image::Base>,

    Image::Base
      Image::Base::Tk::Photo

=head1 DESCRIPTION

C<Image::Base::Tk::Photo> extends C<Image::Base> to create or update image
files using the C<Tk::Photo> module.

See L<Tk::Photo> for the supported file formats.  As of Perl-Tk 804 they
include PNG, JPEG, XPM, XBM, GIF, BMP, and PPM/PGM.

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

=item C<$image = Image::Base::Tk::Photo-E<gt>new (key=E<gt>value,...)>

Create and return a new photo image object.  A new image can be started with
C<-width> and C<-height>,

    $image = Image::Base::Tk::Photo->new (-for_widget => $widget,
                                          -width => 200, -height => 100);

Or an existing file can be read,

    $image = Image::Base::Tk::Photo->new (-file => '/some/filename.xpm');

Or an C<Tk::Photo> object can be given,

    $image = Image::Base::Tk::Photo->new (-tkphoto => $tkphoto);

=item C<$image-E<gt>save>

=item C<$image-E<gt>save ($filename)>

Save to C<-file>, or with a C<$filename> argument set C<-file> then save to
that.

The file format is taken from the C<-file_format> (see below) if that was
set by a C<load()> or explicit C<set()>.

=back

=head1 ATTRIBUTES

=over

=item C<-width> (integer)

=item C<-height> (integer)

Setting these changes the size of the image.

=item C<-tkphoto>

The underlying C<Tk::Photo> object.

=item C<-file_format> (string or C<undef>)

The file format as a string like "png" or "jpeg", or C<undef> if unknown or
never set.

After C<load> the C<-file_format> is the format read.  Setting
C<-file_format> can change the format for a subsequent C<save>.

There's no attempt to check or validate the C<-file_format> value, since
it's possible to add new formats to Tk::Photo at run time.  Expect C<save()> to
croak if the format is unknown.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Tk::Photo>

=cut
