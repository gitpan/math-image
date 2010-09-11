# Copyright 2010 Kevin Ryde

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


package App::MathImage::Gtk2::Drawing;
use 5.008;
use strict;
use warnings;
use Carp;
use POSIX ();
use Scalar::Util;
use Time::HiRes;
use Gtk2 1.220; # for Gtk2::EVENT_PROPAGATE and probably more
use Locale::TextDomain ('App-MathImage');

use Glib::Ex::SourceIds;
use Gtk2::Ex::GdkBits 23; # version 23 for window_clear_region

use App::MathImage::Generator;
use App::MathImage::Gtk2::Drawing::Values;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 19;

use constant _IDLE_TIME_SLICE => 0.25;  # seconds

BEGIN {
  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::Path',
                             App::MathImage::Generator->path_choices);

  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::AronsonLang',
                             'en', 'fr');
  %App::MathImage::Gtk2::Drawing::AronsonLang::EnumBits_to_text
    = (en => __('English'),
       fr => __('French'));
}

use Glib::Object::Subclass
  'Gtk2::DrawingArea',
  signals => { expose_event => \&_do_expose,
             },
  properties => [ Glib::ParamSpec->enum
                  ('values',
                   'values',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Values',
                   App::MathImage::Generator->default_options->{'values'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->enum
                  ('path',
                   'path',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Path',
                   App::MathImage::Generator->default_options->{'path'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('scale',
                   'scale',
                   'Blurb.',
                   1, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'scale'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('fraction',
                   'fraction',
                   'Blurb.',
                   App::MathImage::Generator->default_options->{'fraction'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('expression',
                   'expression',
                   'Blurb.',
                   App::MathImage::Generator->default_options->{'expression'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('aronson-lang',
                   'aronson-lang',
                   'Blurb.',
                   'en',      # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('aronson-letter',
                   'aronson-letter',
                   'Blurb.',
                   '', # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->boolean
                  ('aronson-conjunctions',
                   'aronson-conjunctions',
                   'Blurb.',
                   1,      # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('sqrt',
                   'sqrt',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'sqrt'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('polygonal',
                   'polygonal',
                   'Blurb.',
                   1, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'polygonal'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->double
                  ('multiples',
                   'multiples',
                   'Blurb.',
                   - POSIX::DBL_MAX(), POSIX::DBL_MAX(),
                   App::MathImage::Generator->default_options->{'multiples'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('path-wider',
                   'path-wider',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'path_wider'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('pyramid-step',
                   'pyramid-step',
                   'Blurb.',
                   1, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'pyramid_step'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('rings-step',
                   'rings-step',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'rings_step'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->boolean
                  ('draw-progressive',
                   'draw-progressive',
                   'Blurb.',
                   1,      # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('prime-quadratic',
                   'prime-quadratic',
                   'Blurb.',
                   App::MathImage::Generator->default_options->{'prime_quadratic'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('hadjustment',
                   'hadjustment',
                   'Blurb.',
                   'Gtk2::Adjustment',
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->object
                  ('vadjustment',
                   'vadjustment',
                   'Blurb.',
                   'Gtk2::Adjustment',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  # background pixmap doesn't need double buffering
  $self->set_double_buffered (0);
}
sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### SET_PROPERTY: $pname, $newval

  my $oldval = $self->get($pname);
  $self->{$pname} = $newval;
  if (defined($oldval) != defined($newval)
      || (defined $oldval && $oldval ne $newval)) {

    if ($pname ne 'draw_progressive') {
      delete $self->{'path_object'};
      delete $self->{'pixmap'};
      $self->queue_draw;
    }
  }
}
sub _drawable_size_equal {
  my ($d1, $d2) = @_;
  # ### _drawable_size_equal: $d1->get_size, $d2->get_size

  my ($w1, $h1) = $d1->get_size;
  my ($w2, $h2) = $d2->get_size;
  # ### result: ($w1 == $w2 && $h1 == $h2)
  return ($w1 == $w2 && $h1 == $h2);
}

sub _do_expose {
  my ($self, $event) = @_;
  ### Image _do_expose(): $event->area->values
  ### _pixmap_is_good: _pixmap_is_good($self)
  my $win = $self->window;
  $self->pixmap;
  Gtk2::Ex::GdkBits::window_clear_region ($win, $event->region);
  $win->clear_area ($event->area->values);
  if (my $pixmap = $self->{'drawing'}->{'pixmap'}) {
    $win->draw_drawable ($self->style->black_gc, $pixmap,
                         $event->area->x,
                         $event->area->y,
                         $event->area->values);
  }
  return Gtk2::EVENT_PROPAGATE;
}
#   if (! _pixmap_is_good($self) && ! $self->{'idle_ids'}) {
#     $win->set_back_pixmap (undef);
#     $win->clear_area ($event->area->values);
#     Gtk2::Ex::WidgetCursor->busy;
#     Scalar::Util::weaken (my $weak_self = $self);
#     $self->get_display->sync;
#     $self->{'idle_ids'}= Glib::Ex::SourceIds->new
#       (Glib::Idle->add (\&_do_idle, \$weak_self,
#                         Gtk2::GDK_PRIORITY_REDRAW() + 2000));
#   }
# sub _do_idle {
#   my ($ref_weak_self) = @_;
#   my $self = $$ref_weak_self || return;
#   ### _do_idle()
#   ### _pixmap_is_good: _pixmap_is_good($self)
#   delete $self->{'idle_ids'};
#   if (! _pixmap_is_good($self)) {
#     $self->pixmap;
#     $self->queue_draw;
#   }
#   return 0; # Glib::SOURCE_REMOVE
# }
#   $self->pixmap;
#     $self->get_display->sync;
#       $win->set_back_pixmap (undef);
#       $win->draw_rectangle ($self->style->bg_gc($self->state), 1,
#                             $event->area->values);
#   my $pixmap = $self->{'pixmap'};
#   ### win size: $win->get_size
#   ### pixmap size: $pixmap && $pixmap->get_size
#   ### equal: $pixmap && _drawable_size_equal($pixmap,$win)
#   if ($pixmap && _drawable_size_equal($pixmap,$win)) {
#     $win->clear_area ($event->area->values);
#   } else {
#     ### queue idle
#     $self->{'idle_ids'} ||= do {
#       $win->set_back_pixmap (undef);
#       $win->draw_rectangle ($self->style->bg_gc($self->state), 1,
#                             $event->area->values);
#       Gtk2::Ex::WidgetCursor->busy;
#       $self->get_display->sync;
#     }
#   }

sub _pixmap_is_good {
  my ($self) = @_;
  my $pixmap = $self->{'pixmap'};
  return ($pixmap && _drawable_size_equal($pixmap,$self->window));
}

sub pixmap {
  my ($self) = @_;
  ### pixmap()
  if (! _pixmap_is_good($self)) {
    ### new pixmap
    $self->start_drawing_window ($self->window);
    $self->{'pixmap'} = $self->{'drawing'}->{'pixmap'};
  }
  return $self->{'pixmap'};
}

sub start_drawing_window {
  my ($self, $window) = @_;

  require Gtk2::Ex::WidgetCursor;
  Gtk2::Ex::WidgetCursor->busy;

  # stop previous, so as to do nothing if draw_Image_start() fails
  delete $self->{'drawing'}->{'idle_ids'};

  my ($width, $height) = $window->get_size;
  my $background_colorobj = $self->style->bg($self->state);
  my $foreground_colorobj = $self->style->fg($self->state);
  $window->set_background ($background_colorobj);

  my $undrawnground_colorobj = Gtk2::Gdk::Color->new
    (map {0.9 * $background_colorobj->$_()
            + 0.1 * $foreground_colorobj->$_()}
     'red', 'blue', 'green');
  my $colormap = $self->get_colormap;
  $colormap->rgb_find_color ($undrawnground_colorobj);

  my $gen = $self->{'drawing'}->{'gen'} = App::MathImage::Generator->new
    (values          => $self->get('values'),
     path            => $self->get('path'),
     scale           => $self->get('scale'),
     fraction        => $self->get('fraction'),
     expression      => $self->get('expression'),
     aronson_lang         => $self->get('aronson-lang'),
     aronson_letter       => $self->get('aronson-letter'),
     aronson_conjunctions => $self->get('aronson-conjunctions'),
     sqrt            => $self->get('sqrt'),
     polygonal       => $self->get('polygonal'),
     multiples       => $self->get('multiples'),
     prime_quadratic => $self->get('prime_quadratic'),
     pyramid_step    => $self->get('pyramid-step'),
     rings_step      => $self->get('rings-step'),
     path_wider      => $self->get('path-wider'),
     width           => $width,
     height          => $height,
     foreground      => $foreground_colorobj->to_string,
     background      => $background_colorobj->to_string,
     undrawnground   => $undrawnground_colorobj->to_string,
    );
  ### $gen
  $self->{'path_object'} = $gen->path_object;
  $self->{'coord'} = $gen->{'coord'};

  if (my $vadj = $self->{'vadjustment'}) {
    my $coord = $self->{'coord'};
    my (undef, $lower) = $coord->untransform(0,$height);
    my (undef, $upper) = $coord->untransform(0,0);
    ### vadj: "$lower to $upper"
    $vadj->set (lower     => $lower,
                upper     => $upper,
                page_size => ($upper - $lower),
                value     => $lower);
  }
  if (my $hadj = $self->{'hadjustment'}) {
    my $coord = $self->{'coord'};
    my ($lower, undef) = $coord->untransform(0,0);
    my ($upper, undef) = $coord->untransform($width,0);
    ### hadj: "$lower to $upper"
    $hadj->set (lower     => $lower,
                upper     => $upper,
                page_size => ($upper - $lower),
                value     => $lower);
  }

  require Image::Base::Gtk2::Gdk::Pixmap;
  my $image = $self->{'drawing'}->{'image'}
    = Image::Base::Gtk2::Gdk::Pixmap->new
      (-for_widget => $self,
       -width      => $width,
       -height     => $height);
  $self->{'drawing'}->{'pixmap'} = $image->get('-pixmap');
  ### new pixmap: $self->{'drawing'}->{'pixmap'}
  $self->{'drawing'}->{'window'} = $window;

  my $progressive = $self->get('draw-progressive');
  if ($progressive) {
    require Image::Base::Gtk2::Gdk::Window;
    my $image_window = Image::Base::Gtk2::Gdk::Window->new
      (-window => $window);

    require Image::Base::Multiplex;
    $image = $self->{'drawing'}->{'image'}
      = Image::Base::Multiplex->new
        (-images => [ $image, $image_window ]);
  }
  ### $image
  if (! eval { $gen->draw_Image_start ($image); 1 }) {
    my $err = $@;
    ### $err;
    my $main;
    if (($main = $self->get_ancestor('Gtk2::Window'))
        && (my $statusbar = $main->{'statusbar'})) {
      require Gtk2::Ex::Statusbar::MessageUntilKey;
      $err =~ s/\n+$//;
      Gtk2::Ex::Statusbar::MessageUntilKey->message($statusbar, $err);
    }
    undef $self->{'path_object'};
    undef $self->{'coord'};
    return;
  }

  $self->{'drawing'}->{'steps'} = ($progressive ? 1000 : undef);
  Scalar::Util::weaken (my $weak_self = $self);
  $self->{'drawing'}->{'idle_ids'}
    = Glib::Ex::SourceIds->new
      (Glib::Idle->add (\&_idle_handler_draw, \$weak_self,
                        Gtk2::GDK_PRIORITY_REDRAW() + 10));
  # ### start_drawing_window: $self->{'drawing'}
}

sub _idle_handler_draw {
  my ($ref_weak_self) = @_;
  my $self = $$ref_weak_self || return 0; # Glib::SOURCE_REMOVE
  ### _idle_handler_draw(): $self
  if (my $drawing = $self->{'drawing'}) {
    my $image = $drawing->{'image'};
    my $gen   = $drawing->{'gen'};
    my $steps = $drawing->{'steps'};
    ### $steps
    my $t1 = _gettime();
    if ($gen->draw_Image_steps ($image, $steps)) {
      my $t = _gettime() - $t1;
      ### step took: $t
      if ($t < 0) {
        # time of day change or something
      } elsif ($t == 0) {
        $steps *= 10;
      } else {
        $steps = 1 + int($steps * _IDLE_TIME_SLICE / $t);
      }
      $drawing->{'steps'} = $steps;
      ### new steps: $drawing->{'steps'}
      return 1; # Glib::SOURCE_CONTINUE
    }
    ### done, install pixmap
    my $pixmap = $drawing->{'pixmap'};
    my $window = $drawing->{'window'};
    $window->set_back_pixmap ($pixmap);
    ### set_back_pixmap: "$pixmap"

    if ($drawing->{'window'} == $self->window) {
      $self->queue_draw;
    } else {
      $window->clear;  # for root window
    }
    delete $self->{'drawing'};
  }
  ### _idle_handler_draw() end
  return 0; # Glib::SOURCE_REMOVE
}

# _gettime() returns a floating point count of seconds since some fixed but
# unspecified origin time.
#
# clock_gettime(CLOCK_REALTIME) is preferred.  clock_gettime() always
# exists, but it croaks if there's no such C library func.  In that case
# fall back on the hires time(), which is whatever best thing Time::HiRes
# can do, probably gettimeofday() normally.
#
# Maybe it'd be worth checking clock_getres() to see it's a decent
# resolution.  It's conceivable some old implementations might do
# CLOCK_REALTIME just from the CLK_TCK times() counter, giving only 10
# millisecond resolution.  That's enough for _IDLE_TIME_SLICE of 250 ms
# though.
#
sub _gettime {
  return Time::HiRes::clock_gettime (Time::HiRes::CLOCK_REALTIME());
}
BEGIN {
  unless (eval { _gettime(); 1 }) {
    ### _gettime() no clock_gettime(): $@
    no warnings;
    *_gettime = \&Time::HiRes::time;
  }
}

sub pointer_xy_to_image_xyn {
  my ($self, $x, $y) = @_;
  ### pointer_xy_to_image_xyn(): "$x,$y"
  my $coord = $self->{'coord'} || return;
  my ($px,$py) = $coord->untransform($x,$y);
  ### $px
  ### $py
  my $path_object =  $self->{'path_object'}
    || return ($px, $py);
  if ($path_object->figure eq 'square') {
    $px = POSIX::floor ($px + 0.5);
    $py = POSIX::floor ($py + 0.5);
  }
  return ($px, $py, $path_object->xy_to_n($px,$py));
}

1;
