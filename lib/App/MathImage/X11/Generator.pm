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


package App::MathImage::X11::Generator;
use 5.008;
use strict;
use warnings;
use Carp;
use Scalar::Util;
use Time::HiRes;

use base 'App::MathImage::Generator';
use App::MathImage::X11::Protocol::Extras;
use App::MathImage::X11::Protocol::XSetRoot;
use Image::Base::X11::Protocol::Window;

# uncomment this to run the ### lines
#use Smart::Comments '###';

our $VERSION = 44;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);

  my $X = $self->{'X'};
  my $window = $self->{'window'};
  my $colormap = $X->{'default_colormap'};
  my ($width, $height) = App::MathImage::X11::Protocol::Extras::window_size ($X, $window);

  my $image_window = Image::Base::X11::Protocol::Window->new
    (-X            => $X,
     -window       => $window,
     -colormap     => $colormap);

  require Image::Base::X11::Protocol::Pixmap;
  my $image_pixmap = $self->{'image_pixmap'}
    = Image::Base::X11::Protocol::Pixmap->new
      (-X            => $X,
       -width        => $width,
       -height       => $height,
       -colormap     => $colormap,
       -for_drawable => $window);
  $self->{'pixmap'} = $image_pixmap->get('-pixmap');
  ### pixmap: $self->{'pixmap'}

  require Image::Base::Multiplex;
  my $image = Image::Base::Multiplex->new
    (-images => [ $image_pixmap, $image_window ]);

  $self->draw_Image_start ($image);

  my $seq = $X->send('QueryPointer', $X->{'root'});
  $X->add_reply($seq, \$self->{'reply'});
  $X->flush;

  return $self;
}

sub DESTROY {
  my ($self) = @_;
  if ((my $X = $self->{'X'})
      && (my $pixmap = $self->{'pixmap'})) {
    # ignore errors if closed, maybe
    eval { $X->FreePixmap ($pixmap) };
  }
}

sub draw {
  my ($self) = @_;
  while ($self->draw_steps) {
    ### Generator-X11 more
  }
}

sub draw_steps {
  my ($self) = @_;

  my $more = $self->draw_Image_steps;
  if (! $more) {
    ### Generator-X11 finished
    my $window = $self->{'window'};
    my $pixmap = delete $self->{'pixmap'};
    my $image_pixmap = delete $self->{'image_pixmap'};

    ### _image_pixmap_any_allocated_colours: _image_pixmap_any_allocated_colours($self->{'image_pixmap'})

    if ($self->{'flash'}) {
      require App::MathImage::X11::Protocol::Splash;
      my $splash = App::MathImage::X11::Protocol::Splash->new
        (X => $self->{'X'},
         pixmap => $pixmap,
         width => $self->{'width'},
         height => $self->{'height'});
      $splash->popup;
      $self->{'X'}->QueryPointer($window);  # sync

      Time::HiRes::sleep (0.75);
    }

    # $self->{'X'}->QueryPointer($window);  # sync
    App::MathImage::X11::Protocol::XSetRoot->set_background
        (X => $self->{'X'},
         rootwin => $window,
         pixmap => $pixmap,
         allocated_pixels => _image_pixmap_any_allocated_colours($image_pixmap));
  }

  return $more;
}

sub _image_pixmap_any_allocated_colours {
  my ($image) = @_;
  my $colour_to_pixel = $image->get('-colour_to_pixel')
    || return 1;  # umm, dunno
  %$colour_to_pixel or return 0;  # no colours at all

  my $X        = $image->get('-X');
  my $screen   = $image->get('-screen');
  my $colormap = $image->get('-colormap') || return 0;  # no colormap

  my $screen_info = $X->{'screens'}->[$screen];
  if ($colormap != $screen_info->{'default_colormap'}) {
    return 1;  # private colormap
  }

  foreach my $pixel (values %$colour_to_pixel) {
    unless ($pixel == $screen_info->{'black_pixel'}
            || $pixel == $screen_info->{'white_pixel'}) {
      return 1;
    }
  }
  return 0; # only black and white and in the default colormap
}

1;
__END__
