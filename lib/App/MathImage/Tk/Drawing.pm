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

package App::MathImage::Tk::Drawing;
use 5.008;
use strict;
use warnings;
use Tk;
use App::MathImage::Image::Base::Tk::Photo;

# uncomment this to run the ### lines
#use Devel::Comments;

use base 'Tk::Derived', 'Tk::Label';
Tk::Widget->Construct('AppMathImageTkDrawing');

our $VERSION = 65;

sub ClassInit {
  my ($class, $mw) = @_;
  ### ClassInit(): $class
  $class->SUPER::ClassInit($mw);
  # event handlers for all instances
  $mw->bind($class,'<Expose>',\&_do_expose);
  $mw->bind($class,'<Configure>',\&queue_reimage);
}

sub Populate {
  my ($self, $args) = @_;
  ### Drawing Populate(): $args
  %$args = (-background => 'black',
            -foreground => 'white',
            -activebackground => 'black',
            -activeforeground => 'white',
            -disabledforeground => 'white',
            -borderwidth => 0, # default
            %$args,
           );
  $self->SUPER::Populate($args);
  $self->configure(-background => 'black',
                   -foreground => 'white',
                   -activebackground => 'black',
                   -activeforeground => 'white',
                   -disabledforeground => 'white',
                  );
  ### background: $self->cget('-background')
  ### borderwidth: $self->cget('-borderwidth')
  $self->{'dirty'} = 1;
}

sub queue_reimage {
  my ($self) = @_;
  ### _update_draw() ...
  ### background: $self->cget('-background')
  $self->{'dirty'} = 1;
  $self->{'update_id'} ||= $self->afterIdle(sub { delete $self->{'update_id'};
                                                  _do_expose($self) });
}
sub _do_expose {
  my ($self) = @_;
  ### Drawing Expose() ...
  if (! $self->{'dirty'}) {
    return;
  }
  $self->{'dirty'} = 0;
  if (my $id = delete $self->{'draw_id'}) { $id->cancel; }

  my $gen_options = $self->{'gen_options'} || {};
  ### $gen_options

  my $background = $self->cget('-background');
  my $foreground = $self->cget('-foreground');
  my $borderwidth = $self->cget('-borderwidth');
  my $width = $self->width - 2*$borderwidth;
  my $height = $self->height - 2*$borderwidth;
  ### $width
  ### $height
  ### $background
  ### $foreground
  ### state: $self->cget('-state')
  my $photo = $self->Photo (-width => $width, -height => $height);
  my $gen = App::MathImage::Generator->new
    (step_time       => 0.5,
     step_figures    => 1000,
     %$gen_options,
     width => $width,
     height => $height,
     # background => $background,
     # foreground => $foreground,
    );
  my $image = App::MathImage::Image::Base::Tk::Photo->new (-tkphoto => $photo);
  $gen->draw_Image_start ($image);
  $self->configure (-image => $photo);
  $self->{'draw_id'} = $self->afterIdle(sub { _update_draw_steps($self,$gen,$photo) });
  $self->configure(-cursor => 'watch');
}
sub _update_draw_steps {
  my ($self,$gen,$photo) = @_;
  ### _update_draw_steps()
  if ($gen->draw_Image_steps) {
    ### _update_draw_steps() more
    $self->{'draw_id'} = $self->afterIdle(sub { _update_draw_steps($self,$gen,$photo) });
  } else {
    ### _update_draw_steps() finished
    $self->configure (-cursor => undef);
  }
}

1;
