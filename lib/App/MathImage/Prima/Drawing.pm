# Copyright 2010, 2011, 2012 Kevin Ryde

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
use Module::Load;

use vars qw(@ISA);
@ISA = qw(Prima::Widget);

use App::MathImage::Generator;

use vars '$VERSION';
$VERSION = 101;

# uncomment this to run the ### lines
#use Smart::Comments;

sub profile_default {
  my ($class) = @_;
  ### Prima-Drawing profile_default() ...
  return { %{$class->SUPER::profile_default},
           onMouseWheel     => \&onMouseWheel,
           gen_options      => App::MathImage::Generator->default_options,
           draw_progressive => 1,
           transparent      => 1, # no clear background for paint

           # default colours
           color            => cl::White(),
           backColor        => cl::Black(),

           # onSize => sub {
           #   ### Prima-Drawing onSize: @_[1..$#_]
           # },
         };
}

sub init {
  my ($self, %profile) = @_;
  ### Drawing init() ...
  # ### %profile
  $profile{'gen_options'} = { %{App::MathImage::Generator->default_options},
                              %{$profile{'gen_options'} || {}} }; # copy
  $self->{'gen_options'} = delete $profile{'gen_options'};
  $self->{'draw_progressive'} = 1;
  return $self->SUPER::init (%profile);
}

sub redraw {
  my ($self) = @_;
  delete $self->{'gen_object'};
  delete $self->{'bitmap'};
  ### Prima-Drawing repaint() ...
  $self->repaint;
}

sub gen_options {
  my $self = shift;
  ### Prima-Drawing gen_options(): @_
  my $gen_options = $self->{'gen_options'};
  if (@_) {
    %$gen_options = (%$gen_options, @_);
    $self->redraw;
  }
  return $gen_options;
}
sub path_parameters {
  my $self = shift;
  ### Prima-Drawing path_options(): @_
  my $path_parameters = ($self->gen_options->{'path_parameters'} ||= {});
  if (@_) {
    %$path_parameters = (%$path_parameters, @_);
    $self->redraw;
  }
  return $path_parameters;
}
sub draw_progressive {
  my $self = shift;
  ### Prima-Drawing draw_progressive(): @_
  if (@_) { $self->{'draw_progressive'} = shift; }
  return $self->{'draw_progressive'};
}

sub on_paint {
  my ($self, $canvas) = @_;
  ### Prima-Drawing on_paint() ...
  $canvas->clear;
  #   $canvas->fill_ellipse(50,50, 20,20);

  # my $gen = $self->gen_object;
  # my $scale = $gen->{'scale'} || 1;
  # my $path_parameters = $self->path_parameters;
  # $path_parameters->{'width'}  = int ($canvas->width / $scale);
  # $path_parameters->{'height'} = int ($canvas->height / $scale);
  # ### canvas width:  $canvas->width
  # ### canvas height: $canvas->height
  #
  # require Image::Base::Prima::Drawable;
  # my $image = Image::Base::Prima::Drawable->new (-drawable => $canvas);
  # ### width:  $image->get('-width')
  # ### height: $image->get('-height')
  # $gen->draw_Image ($image);

  if (my $bitmap = $self->bitmap) {
    $canvas->put_image (0,0, $bitmap);
  }
}

sub bitmap {
  my ($self) = @_;
  ### bitmap()...
  if (! _bitmap_is_good($self)) {
    ### new bitmap ...
    $self->start_drawing_window ($self);
  }
  return $self->{'bitmap'};
}
sub _bitmap_is_good {
  my ($self) = @_;
  ### _bitmap_is_good() ...
  ### bitmap: $self->{'bitmap'}
  my $bitmap = $self->{'bitmap'} || return 0;
  return ($self->width == $bitmap->width
          && $self->height == $bitmap->height);
}

sub start_drawing_window {
  my ($self, $target) = @_;
  ### Prima-Drawing start_drawing_window() ...

  delete $self->{'gen_object'};
  my $gen = $self->gen_object
    (generator_class => 'App::MathImage::Prima::Generator',
     # busycursor      => Prima::Ex::BusyCursor->new,
    );

  $self->{'path_object'} = $gen->path_object;
  $self->{'affine_object'} = $gen->affine_object;

  # if drawing to self, not if drawing to root window
  if ($target == $self) {
    $self->{'bitmap'} = $gen->{'bitmap'};
    ### bitmap: $self->{'bitmap'}
  }
}

sub gen_object {
  my ($self, %gen_parameters) = @_;
  return ($self->{'gen_object'} ||= do {
    my $gen_options = $self->gen_options;
    my $generator_class = delete $gen_parameters{'generator_class'}
      || 'App::MathImage::Generator';

    ### self: keys %$self
    ### transparent: $self->transparent

    my $foreground = $self->map_color($self->color);
    my $foreground_str = sprintf '#%06X', $foreground;
    my $background = $self->map_color($self->backColor);
    my $background_str = sprintf '#%06X', $background;
    my $undrawnground
      = int (($background & 0xFF0000) * .8 + ($foreground & 0xFF0000) * .2
             + ($background & 0xFF00) * .8 + ($foreground & 0xFF00) * .2
             + ($background & 0xFF) * .8 + ($foreground & 0xFF) * .2);
    my $undrawnground_str = sprintf '#%06X', $undrawnground;

    Module::Load::load ($generator_class);
    $generator_class->new
      (step_time        => 0.25,
       step_figures     => 1000,

       draw_progressive => $self->draw_progressive,
       foreground       => $foreground_str,
       background       => $background_str,
       undrawnground    => $undrawnground_str,

       widget           => $self,
       drawable         => $self,
       width            => $self->width,
       height           => $self->height,

       %$gen_options,
      )
    });
}

#------------------------------------------------------------------------------
# mouse wheel scroll

sub onMouseWheel {
  my ($self, $modifiers, $x,$y, $delta_wheel) = @_;
  ### onMouseWheel(): "$modifiers, $x,$y, $delta_wheel"

  # "Control" by page, otherwise by step
  my $frac = ($modifiers & km::Ctrl() ? 0.9 : 0.1) * $delta_wheel/120;
  ### $frac

  # "Shift" horizontally, otherwise vertically
  if ($modifiers & km::Shift()) {
    $self->{'gen_options'}->{'x_offset'} += int ($self->width * $frac);
  } else {
    $self->{'gen_options'}->{'y_offset'} -= int ($self->height * $frac);
  }
  $self->redraw;
}

#------------------------------------------------------------------------------

1;
__END__
