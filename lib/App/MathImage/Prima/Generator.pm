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


package App::MathImage::Prima::Generator;
use strict;
use warnings;
use Carp;
use Scalar::Util;

use Image::Base::Prima::Drawable;
use base 'App::MathImage::Generator';

# uncomment this to run the ### lines
#use Smart::Comments '###';

our $VERSION = 65;

use constant 1.02; # for leading underscore
use constant _DEFAULT_IDLE_TIME_SLICE => 0.25;  # seconds
use constant _DEFAULT_IDLE_TIME_FIGURES => 1000;  # drawing requests

sub new {
  my $class = shift;
  ### Prima-Generator new()

  my $self = $class->SUPER::new (step_time    => _DEFAULT_IDLE_TIME_SLICE,
                                 step_figures => _DEFAULT_IDLE_TIME_FIGURES,
                                 @_);
  my $drawable = $self->{'drawable'};
  my ($width, $height) = $drawable->size;

  my $image = $self->{'image'}
    = Image::Base::Prima::Drawable->new (-drawable => $drawable);

  # my $progressive = $self->{'draw_progressive'};
  # if ($progressive) {
  #   require Image::Base::Prima::Gdk::Drawable;
  #   my $image_drawable = Image::Base::Prima::Gdk::Drawable->new
  #     (-drawable => $drawable);
  # 
  #   require Image::Base::Multiplex;
  #   $image = $self->{'image'} = Image::Base::Multiplex->new
  #     (-images => [ $image, $image_drawable ]);
  # }

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

  if ($self->draw_Image_steps ()) {
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
# calls $object->$method ($arg,...)
sub _post_method_weakly {
  my $weak_object = shift;
  Scalar::Util::weaken ($weak_object);
  Prima::Utils::post (\&_post_method_weakly_handler, \$weak_object, @_);
}
sub _post_method_weakly_handler {
  # ($ref_weak_object,$method,$arg...)
  my $object = ${(shift)} || return;
  my $method = shift;
  $object->$method (@_);
}

sub _drawing_finished {
  my ($self) = @_;
  ### _drawing_finished()

  # my $pixmap = $self->{'pixmap'};
  # my $drawable = $self->{'drawable'};
  # ### set_back_pixmap: "$pixmap"
  # $drawable->set_back_pixmap ($pixmap);
  # _drawable_invalidate_all ($drawable);
}

# sub draw {
#   my $class = shift;
#   my $self = $class->new (@_,
#                        draw_progressive => 0);
#   while ($self->draw_steps) {
#     ### Generator-X11 more
#   }
#   _drawing_finished ($self);
# }

1;
__END__
