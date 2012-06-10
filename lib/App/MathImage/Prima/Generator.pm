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


package App::MathImage::Prima::Generator;
use 5.006;
use strict;
use warnings;
use Carp;
use Scalar::Util;

use Image::Base::Prima::Drawable;
use base 'App::MathImage::Generator';

# uncomment this to run the ### lines
#use Smart::Comments '###';

our $VERSION = 101;

use constant 1.02; # for leading underscore
use constant _DEFAULT_IDLE_TIME_SLICE => 0.25;  # seconds
use constant _DEFAULT_IDLE_TIME_FIGURES => 1000;  # drawing requests

sub new {
  my $class = shift;
  ### Prima-Generator new()

  my $self = $class->SUPER::new (step_time    => _DEFAULT_IDLE_TIME_SLICE,
                                 step_figures => _DEFAULT_IDLE_TIME_FIGURES,
                                 @_);
  if ($self->{'widget'}) {
    Scalar::Util::weaken ($self->{'widget'});
  }
  my $drawable = $self->{'drawable'};

  ### width: $drawable->width
  ### height: $drawable->height
  ### draw_progressive: $self->{'draw_progressive'}

  my $bitmap
    =  $self->{'bitmap'}
      = Prima::DeviceBitmap->new (width  => $drawable->width,
                                  height => $drawable->height);
  my $image
    = $self->{'image'}
      = $self->{'bitmap_image'}
        = Image::Base::Prima::Drawable->new (-drawable => $bitmap);

  if ($self->{'draw_progressive'}) {
    my $widget_image
      = Image::Base::Prima::Drawable->new (-drawable => $self->{'drawable'});
    require Image::Base::Multiplex;
    $image
      = $self->{'image'}
        = Image::Base::Multiplex->new (-images => [ $image, $widget_image ]);
  }

  if (! eval { $self->draw_Image_start ($image); 1 }) {
    my $err = $@;
    ### $err;
    # my ($main, $statusbar);
    # if (($main = $self->{'primamain'})
    #     && ($statusbar = $main->get('statusbar'))) {
    #   require Prima::Ex::Statusbar::MessageUntilKey;
    #   $err =~ s/\n+$//;
    #   Prima::Ex::Statusbar::MessageUntilKey->message($statusbar, $err);
    # }
    #
    # undef $self->{'path_object'};
    # App::MathImage::Prima::Drawing::draw_text_centred
    #     ($self->{'widget'}, $self->{'pixmap'}, $err);
    _drawing_finished ($self);
    return $self;
  }

  _post_method_weakly ($self, 'post_handler');
  $self->{'post_pending'} = 1;
  return $self;
}

sub post_handler {
  my ($self) = @_;
  ### _post_handler()
  $self->{'post_pending'} = 0;

  ### bitmap paint state: $self->{'bitmap'}->get_paint_state
  ### drawable paint state: $self->{'drawable'}->get_paint_state

  # Prima::DeviceBitmap always in paint-enabled state, so no begin/end for it

  my $more;
  if ($self->{'draw_progressive'}) {
    # or maybe better a single $widget_image and tell it when a cached
    # $drawable->color() setting must be re-applied
    #    $widget_image->set(-current_colour => '');
    #
    my $widget_image
      = Image::Base::Prima::Drawable->new (-drawable => $self->{'drawable'});
    $self->{'image'}->set (-images => [ $self->{'bitmap_image'},
                                        $widget_image ]);
    $self->{'drawable'}->begin_paint
      or die "Oops, cannot begin_paint on drawable: ",$@;
    $more = $self->draw_Image_steps;
    $self->{'drawable'}->end_paint;
  } else {
    $more = $self->draw_Image_steps;
  }

  if ($more) {
    ### keep drawing
    unless ($self->{'post_pending'}) {
      ### further post()
      _post_method_weakly ($self, 'post_handler');
      $self->{'post_pending'} = 1;
    }
  } else {
    ### done, install pixmap
    _drawing_finished ($self);
  }
}

# _post_method_weakly($object,$method,$arg...)
# Install a post() which calls $object->$method ($arg,...).
# Only a weak reference is held to $object, so the fact a post exists
# doesn't keep it alive.  calls
sub _post_method_weakly {
  my $weak_object = shift;
  Scalar::Util::weaken ($weak_object);
  Prima::Utils::post (\&_post_method_weakly_handler, \$weak_object, @_);
}
sub _post_method_weakly_handler {
  # called ($ref_weak_object,$method,$arg...)
  my $object = ${(shift)} || return;
  my $method = shift;
  $object->$method(@_);
}

sub _drawing_finished {
  my ($self) = @_;
  ### _drawing_finished()

  # ENHANCE-ME: background image ?
  $self->{'drawable'}->repaint;
}

# sub draw {
#   my $class = shift;
#   my $self = $class->new (@_,
#                        draw_progressive => 0);
#   while ($self->draw_steps) {
#     ### Prima-Generator more ...
#   }
#   _drawing_finished ($self);
# }

1;
__END__
