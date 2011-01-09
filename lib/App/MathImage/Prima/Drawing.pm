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


package App::MathImage::Prima::Drawing;
use 5.004;
use strict;
use warnings;

use vars qw(@ISA);
@ISA = qw(Prima::Widget);

use App::MathImage::Generator;

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 40;

sub profile_default {
  my ($class) = @_;
  return { %{$class->SUPER::profile_default},
           gen_options => App::MathImage::Generator->default_options,
         };
}

sub init {
  my ($self, %profile) = @_;
  ### Drawing init(): @_
  $profile{'gen_options'} = { %{App::MathImage::Generator->default_options},
                             %{$profile{'gen_options'} || {}} }; # copy
  $self->{'gen_options'} = $profile{'gen_options'};
  return $self->SUPER::init (%profile);
}

sub gen_options {
  my $self = shift;
  ### gen_options()
  ### $self
  my $gen_options = $self->{'gen_options'};
  if (@_) {
    %$gen_options = (%$gen_options, @_);
    $self->repaint;
  }
  return $gen_options;
}

sub on_paint {
  my ($self, $canvas) = @_;
  ### _paint
  $canvas->clear;
  $canvas->fill_ellipse(50,50, 20,20);

  _draw_image ($canvas, $self->gen_options);
}

sub _draw_image {
  my ($drawable, $gen_options) = @_;
  ### _draw_image(): ref($drawable)

  my $gen = App::MathImage::Generator->new
    (step_time       => 0.25,
     step_figures    => 1000,
     %$gen_options,
     width  => $drawable->width,
     height => $drawable->height);
  #      foreground => $self->style->fg($self->state)->to_string,
  #      background => $background_colorobj->to_string,

  #   $self->{'path_object'} = $gen->path_object;
  #   $self->{'coord'} = $gen->{'coord'};

  ### width:  $drawable->width
  ### height: $drawable->height

  require App::MathImage::Image::Base::Prima::Drawable;
  my $image = App::MathImage::Image::Base::Prima::Drawable->new
    (-drawable => $drawable);
  ### width:  $image->get('-width')
  ### height: $image->get('-height')

  $gen->draw_Image ($image);
}

# sub expose {
#           if ( $d-> begin_paint) {
#              $d-> color( cl::Black);
#              $d-> bar( 0, 0, $d-> size);
#              $d-> color( cl::White);
#              $d-> fill_ellipse( $d-> width / 2, $d-> height / 2, 30, 30);
#              $d-> end_paint;
#           } else {
#              die "can't draw on image:$@";
#           }

1;
__END__
