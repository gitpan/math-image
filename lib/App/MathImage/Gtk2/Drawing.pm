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


package App::MathImage::Gtk2::Drawing;
use 5.008;
use strict;
use warnings;
use Carp;
use List::Util qw(min max);
use POSIX ();
use Scalar::Util;
use Time::HiRes;
use List::MoreUtils;
use Module::Load;
use Glib 1.220; # for Glib::SOURCE_REMOVE and probably more
use Gtk2 1.220; # for Gtk2::EVENT_PROPAGATE and probably more
use Gtk2::Pango;
use Locale::TextDomain ('App-MathImage');

use Glib::Ex::SourceIds;
use Gtk2::Ex::SyncCall 12; # v.12 workaround gtk 2.12 bug
use Gtk2::Ex::GdkBits 23; # v.23 for window_clear_region()

use App::MathImage::Generator;
use App::MathImage::Gtk2::Drawing::Values;
use App::MathImage::Gtk2::Ex::AdjustmentBits;

# uncomment this to run the ### lines
#use Smart::Comments '###';

our $VERSION = 42;

use constant _IDLE_TIME_SLICE => 0.25;  # seconds
use constant _IDLE_TIME_FIGURES => 1000;  # drawing requests

BEGIN {
  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::Path',
                             App::MathImage::Generator->path_choices);

  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::Filters',
                             'All', 'Odd', 'Even', 'Primes');
  %App::MathImage::Gtk2::Drawing::Filters::EnumBits_to_display =
    (All    => __('No Filter'),
     Odd    => __('Odd'),
     Even   => __('Even'),
     Primes => __('Primes'));

  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::RotationType',
                             'phi', 'sqrt2', 'sqrt3', 'sqrt5', 'custom');

  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::Parity',
                             'odd', 'even');
  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::Pairs',
                             'first', 'second', 'both');

  Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::FigureType',
                             App::MathImage::Generator->figure_choices);
}

use Glib::Object::Subclass
  'Gtk2::DrawingArea',
  signals => { expose_event => \&_do_expose,
               size_allocate => \&_do_size_allocate,
               button_press_event => \&_do_button_press,
               scroll_event => \&App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_widget_event_vh,
             },
  properties => [ Glib::ParamSpec->enum
                  ('values',
                   'Values',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Values',
                   App::MathImage::Generator->default_options->{'values'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->enum
                  ('filter',
                   'Filter',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Filters',
                   App::MathImage::Generator->default_options->{'filter'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->enum
                  ('values-parity',
                   __('Parity'),
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Parity',
                   App::MathImage::Generator->default_options->{'parity'},
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->enum
                  ('values-pairs',
                   __('Pairs'),
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Pairs',
                   App::MathImage::Generator->default_options->{'pairs'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->enum
                  ('path',
                   'Path type',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::Path',
                   App::MathImage::Generator->default_options->{'path'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('scale',
                   'Scale pixels',
                   'Blurb.',
                   1, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'scale'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('values-fraction',
                   __('Fraction'),
                   'Blurb.',
                   App::MathImage::Generator->default_options->{'fraction'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('values-expression',
                   __('Expression'),
                   'Blurb.',
                   App::MathImage::Generator->default_options->{'expression'},
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->string
                  ('values-expression-evaluator',
                   'Expression Evaluator',
                   'Blurb.',
                   '',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('values-anum',
                   'A-number',
                   'Blurb.',
                   '',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string
                  ('values-aronson_lang',
                   'aronson-lang',
                   'Blurb.',
                   'en',      # default
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->string
                  ('values-aronson_letter',
                   'aronson-letter',
                   'Blurb.',
                   '', # default
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->boolean
                  ('values-aronson_conjunctions',
                   'aronson-conjunctions',
                   'Blurb.',
                   1,      # default
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->boolean
                  ('values-aronson_lying',
                   'aronson-lying',
                   'Blurb.',
                   0,      # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('values-sqrt',
                   'Square root',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'sqrt'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('values-polygonal',
                   __('Polygonal'),
                   'Blurb.',
                   2, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'polygonal'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->double
                  ('values-multiples',
                   'Multiples',
                   'Blurb.',
                   - POSIX::DBL_MAX(), POSIX::DBL_MAX(),
                   App::MathImage::Generator->default_options->{'multiples'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('values-radix',
                   'values-radix',
                   'Blurb.',
                   2, POSIX::INT_MAX(),
                   2, # App::MathImage::Generator->default_options->{'radix'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('values-digit',
                   'values-digit',
                   'Blurb.',
                   -1, POSIX::INT_MAX(),
                   -1, # App::MathImage::Generator->default_options->{'digit'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('values-level',
                   'values-level',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   0, # App::MathImage::Generator->default_options->{'level'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('path-wider',
                   'path-wider',
                   'Blurb.',
                   0, POSIX::INT_MAX(),
                   App::MathImage::Generator->default_options->{'path_wider'},
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->enum
                  ('path-rotation-type',
                   'path-rotation-type',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::RotationType',
                   App::MathImage::Generator->default_options->{'path_rotation_type'},
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->double
                  ('path-rotation-factor',
                   'path-rotation-factor',
                   'Blurb.',
                   - POSIX::DBL_MAX(), POSIX::DBL_MAX(),
                   0,
                   Glib::G_PARAM_READWRITE),
                  Glib::ParamSpec->double
                  ('path-radius-factor',
                   'path-radius-factor',
                   'Blurb.',
                   - POSIX::DBL_MAX(), POSIX::DBL_MAX(),
                   0,
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

                  Glib::ParamSpec->enum
                  ('figure',
                   'figure',
                   'Blurb.',
                   'App::MathImage::Gtk2::Drawing::FigureType',
                   'default',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->add_events (['button-press-mask','button-release-mask']);
  # background pixmap doesn't need double buffering
  $self->set_double_buffered (0);

  $self->{'hadjustment'} = Gtk2::Adjustment->new (0,0,0,0,0,0);
  $self->{'vadjustment'} = Gtk2::Adjustment->new (0,0,0,0,0,0);
  $self->set (hadjustment => $self->{'hadjustment'},
              vadjustment => $self->{'vadjustment'});

  $self->{'path_basis'} = [ _centre_basis($self) ];
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

  if ($pname eq 'hadjustment' || $pname eq 'vadjustment') {
    my $adj = $newval;
    Scalar::Util::weaken (my $weak_self = $self);
    $self->{"${pname}_ids"} = $adj && Glib::Ex::SignalIds->new
      ($adj, $adj->signal_connect (value_changed => \&_adjustment_value_changed,
                                   \$weak_self));
    _update_adjustment_extents($self);
  }
  if ($pname eq 'scale' || $pname eq 'path') {
    _update_adjustment_extents($self);
  }

  if ($pname eq 'scale') {
    _update_adjustment_values ($self,
                               $self->allocation->width / $oldval,
                               $self->allocation->height / $oldval,
                               $self->allocation->width / $newval,
                               $self->allocation->height / $newval);
  }

  if ($pname eq 'path') {
    my ($x, $y) = _centre_basis($self);
    my ($old_x, $old_y) = @{$self->{'path_basis'}};
    if ($x != $old_x) {
      my $hadj = $self->{'hadjustment'};
      my $width = $self->allocation->width;
      my $scale = $self->get('scale');
      ### new basis hadj
      ### $x
      ### $old_x
      ### add: ($x-$old_x)*(-$width/$scale/2 - -1/2)
      $hadj->set_value ($hadj->value + ($x-$old_x)*(-$width/$scale/2 - -1/2));
    }
    if ($y != $old_y) {
      my $vadj = $self->{'vadjustment'};
      my $height = $self->allocation->height;
      my $scale = $self->get('scale');
      ### new basis vadj
      ### $y
      ### $old_y
      ### add: ($y-$old_y)*(-$height/$scale/2 - -1/2)
      $vadj->set_value ($vadj->value + ($y-$old_y)*(-$height/$scale/2 - -1/2));
    }
    $self->{'path_basis'} = [$x,$y];
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

sub _do_size_allocate {
  my ($self, $alloc) = @_;
  my $old_width = $self->allocation->width;
  my $old_height = $self->allocation->height;
  ### _do_size_allocate(): $alloc->width."x".$alloc->height
  ### $old_width
  ### $old_height

  shift->signal_chain_from_overridden(@_);

  _update_adjustment_extents($self);
  my $scale = $self->get('scale');
  _update_adjustment_values ($self,
                             $old_width / $scale,
                             $old_height / $scale,
                             $self->allocation->width / $scale,
                             $self->allocation->height / $scale);
}

sub _update_adjustment_values {
  my ($self, $old_hpage,$old_vpage, $new_hpage,$new_vpage) = @_;
  {
    my $hadj = $self->{'hadjustment'};
    my $value = $hadj->value;
    my $dec = ($new_hpage - $old_hpage) / 2;
    unless ($self->x_negative) {
      if ($dec >= 0) {
        # don't float in the air when expand
        if ($value >= -0.5) {
          $dec = min ($value + .5, $dec);
        }
      } else {
        # don't go negative when shrink
        $dec = max ($value + .5, $dec);
      }
    }
    ### hadj value: $value
    ### hadj dec: $dec
    $hadj->set_value ($value - $dec);
  }
  {
    my $vadj = $self->{'vadjustment'};
    my $value = $vadj->value;
    my $dec = ($new_vpage - $old_vpage) / 2;
    my $factor = 1;
    unless ($self->y_negative) {
      if ($value < -0.5) {
        # already negative, stay relative to bottom edge
        $factor = $new_vpage / $old_vpage;
        $dec = 0;
      } elsif ($dec >= 0) {
        if ($value >= -0.5) {
          # don't float in the air when expand
          $dec = min ($value + .5, $dec);
        }
      } else {
        # don't go negative when shrink
        $dec = max (- ($value + .5), $dec);
      }
    }
    ### vadj old page: $old_vpage
    ### vadj new page: $new_vpage
    ### vadj value: $value
    ### vadj dec: $dec
    ### vadj factor: $factor
    $vadj->set_value ($factor*$value - $dec);
  }
}

sub _adjustment_value_changed {
  my ($adj, $ref_weak_self) = @_;
  ### _adjustment_value_changed(): $adj->value
  my $self = $$ref_weak_self || return;
  _update_adjustment_extents($self);
  delete $self->{'pixmap'}; # new image
  $self->queue_draw;
}

sub _do_expose {
  my ($self, $event) = @_;
  ### Image _do_expose(): $event->area->values
  ### _pixmap_is_good says: _pixmap_is_good($self)
  #### $self
  my $win = $self->window;
  $self->pixmap;
  Gtk2::Ex::GdkBits::window_clear_region ($win, $event->region);
  $win->clear_area ($event->area->values);
  if (my $pixmap = $self->{'generator'}->{'pixmap'}) {
    $win->draw_drawable ($self->style->black_gc, $pixmap,
                         $event->area->x,
                         $event->area->y,
                         $event->area->values);
  }
  return Gtk2::EVENT_PROPAGATE;
}

sub _pixmap_is_good {
  my ($self) = @_;
  ### _pixmap_is_good() pixmap: $self->{'pixmap'}
  my $pixmap = $self->{'pixmap'};
  return ($pixmap && _drawable_size_equal($pixmap,$self->window));
}

sub pixmap {
  my ($self) = @_;
  ### pixmap()
  if (! _pixmap_is_good($self)) {
    ### new pixmap
    $self->start_drawing_window ($self->window);
  }
  return $self->{'pixmap'};
}

sub gen_object {
  my ($self) = @_;
  my (undef, undef, $width, $height) = $self->allocation->values;
  my $background_colorobj = $self->style->bg($self->state);
  my $foreground_colorobj = $self->style->fg($self->state);
  my $undrawnground_colorobj = Gtk2::Gdk::Color->new
    (map {0.9 * $background_colorobj->$_()
            + 0.1 * $foreground_colorobj->$_()}
     'red', 'blue', 'green');
  my $path_rotation_type = $self->get('path-rotation-type');
  return App::MathImage::Generator->new
    (step_time       => _IDLE_TIME_SLICE,
     step_figures    => _IDLE_TIME_FIGURES,
     values          => $self->get('values'),
     path            => $self->get('path'),
     scale           => $self->get('scale'),
     figure          => $self->get('figure'),
     parity          => $self->get('values-parity'),
     pairs           => $self->get('values-pairs'),
     fraction        => $self->get('values-fraction'),
     expression      => $self->get('values-expression'),
     expression_evaluator => $self->get('values-expression-evaluator'),
     anum            => $self->get('values-anum'),
     aronson_lang         => $self->get('values-aronson_lang'),
     aronson_letter       => $self->get('values-aronson_letter'),
     aronson_conjunctions => $self->get('values-aronson_conjunctions'),
     aronson_lying        => $self->get('values-aronson_lying'),
     sqrt            => $self->get('values-sqrt'),
     polygonal       => $self->get('values-polygonal'),
     multiples       => $self->get('values-multiples'),
     radix           => $self->get('values-radix'),
     digit           => $self->get('values-digit'),
     level           => $self->get('values-level'),
     ($path_rotation_type eq 'custom'
      ? (path_rotation_factor => $self->get('path-rotation-factor'))
      : (path_rotation_type  => $path_rotation_type)),
     path_radius_factor  => $self->get('path-radius-factor'),
     pyramid_step    => $self->get('pyramid-step'),
     rings_step      => $self->get('rings-step'),
     path_wider      => $self->get('path-wider'),
     width           => $width,
     height          => $height,
     foreground      => $foreground_colorobj->to_string,
     background      => $background_colorobj->to_string,
     undrawnground   => $undrawnground_colorobj->to_string,
     filter          => $self->get('filter'),
     x_left          => $self->{'hadjustment'}->value,
     y_bottom        => $self->{'vadjustment'}->value,
    );
}
sub x_negative {
  my ($self) = @_;
  return $self->gen_object->path_object->x_negative;
}
sub y_negative {
  my ($self) = @_;
  return $self->gen_object->path_object->y_negative;
}

sub start_drawing_window {
  my ($self, $window) = @_;

  require Gtk2::Ex::WidgetCursor;
  Gtk2::Ex::WidgetCursor->busy;

  my (undef, undef, $width, $height) = $self->allocation->values;
  my $path_rotation_type = $self->get('path-rotation-type');

  my $style = $self->style;
  my $background_colorobj = $style->bg($self->state);
  my $foreground_colorobj = $style->fg($self->state);
  $window->set_background ($background_colorobj);

  my $undrawnground_colorobj = Gtk2::Gdk::Color->new
    (map {0.9 * $background_colorobj->$_()
            + 0.1 * $foreground_colorobj->$_()}
     'red', 'blue', 'green');
  if (my $colormap = $window->get_colormap) {
    $colormap->rgb_find_color ($undrawnground_colorobj);
  }

  require App::MathImage::Gtk2::Generator;
  my $gen = $self->{'generator'} = App::MathImage::Gtk2::Generator->new
    (widget  => $self,
     window => $window,
     gtkmain => $self->get_ancestor('Gtk2::Window'),

     foreground       => $foreground_colorobj->to_string,
     background       => $background_colorobj->to_string,
     undrawnground    => $undrawnground_colorobj->to_string,
     draw_progressive => $self->get('draw-progressive'),

     values          => $self->get('values'),
     path            => $self->get('path'),
     scale           => $self->get('scale'),
     figure          => $self->get('figure'),
     parity          => $self->get('values-parity'),
     pairs           => $self->get('values-pairs'),
     fraction        => $self->get('values-fraction'),
     expression      => $self->get('values-expression'),
     expression_evaluator => $self->get('values-expression-evaluator'),
     anum            => $self->get('values-anum'),
     aronson_lang         => $self->get('values-aronson_lang'),
     aronson_letter       => $self->get('values-aronson_letter'),
     aronson_conjunctions => $self->get('values-aronson_conjunctions'),
     aronson_lying        => $self->get('values-aronson_lying'),
     sqrt            => $self->get('values-sqrt'),
     polygonal       => $self->get('values-polygonal'),
     multiples       => $self->get('values-multiples'),
     radix           => $self->get('values-radix'),
     digit           => $self->get('values-digit'),
     level           => $self->get('values-level'),
     ($path_rotation_type eq 'custom'
      ? (path_rotation_factor => $self->get('path-rotation-factor'))
      : (path_rotation_type  => $path_rotation_type)),
     path_radius_factor  => $self->get('path-radius-factor'),
     pyramid_step    => $self->get('pyramid-step'),
     rings_step      => $self->get('rings-step'),
     path_wider      => $self->get('path-wider'),
     width           => $width,
     height          => $height,
     filter          => $self->get('filter'),
     x_left          => $self->{'hadjustment'}->value,
     y_bottom        => $self->{'vadjustment'}->value,
    );

  $self->{'path_object'} = $gen->path_object;
  $self->{'coord'} = $gen->coord_object;

  if ($self->window && $window == $self->window) {
    $self->{'pixmap'} = $gen->{'pixmap'}; # not if drawing to root window
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

sub centre {
  my ($self) = @_;
  ### Drawing centre()
  my ($x, $y) = _centre_values($self);
  $self->{'hadjustment'}->set_value ($x);
  $self->{'vadjustment'}->set_value ($y);
}
sub _centre_values {
  my ($self) = @_;
  my ($x, $y) = _centre_basis($self);
  my $scale = $self->get('scale');
  my (undef, undef, $width, $height) = $self->allocation->values;
  return (($x ? -$width/$scale/2 : -1/2),
          ($y ? -$height/2/$scale : -1/2));
}
sub _centre_basis {
  my ($self) = @_;
  return ($self->x_negative,
          $self->y_negative);
  # return (($self->x_negative || $path eq 'MultipleRings'),
  #         ($self->y_negative || $path eq 'MultipleRings'));
}

# AdjustmentBits ...
#
# my %scroll_direction_to_vh = (left  => 'h',
#                               right => 'h',
#                               up   => 'v',
#                               down => 'v');
# my %scroll_direction_to_inv = (left  => 1,
#                                right => 0,
#                                up   => 1,
#                                down => 0);
# # 'scroll-event' class closure
# sub _do_scroll_event {
#   my ($self, $event) = @_;
#   ### Drawing _do_scroll_event(): "$self->{'hadjustment'}, $self->{'vadjustment'}"
#   # my $dir = $event->direction;
#   # my $vh = $scroll_direction_to_vh{$dir};
#   # App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_increment
#   #     ($self->get_property("${vh}adjustment"),
#   #      $event->state & 'control-mask' ? 'page' : 'step',
#   #      $scroll_direction_to_inv{$dir} ^ ($vh eq 'v'));
# 
#   App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_widget_event_vhi
#       ($self, $event);
#   return $self->signal_chain_from_overridden ($event);
# }

# 'button-press-event' class closure
sub _do_button_press {
  my ($self, $event) = @_;
  ### Drawing _do_button_press(): $event->button
  my $button = $event->button;
  if ($button == 1) {
    _do_start_drag ($self, $button, $event);
  }
  return shift->signal_chain_from_overridden(@_);
}
sub _do_start_drag {
  my ($self, $button, $event) = @_;
  my $dragger = ($self->{'dragger'} ||= do {
    require Gtk2::Ex::Dragger;
    Gtk2::Ex::Dragger->new (widget => $self,
                            hadjustment => $self->{'hadjustment'},
                            vadjustment => $self->{'vadjustment'},
                            vinverted   => 1,
                            cursor      => 'fleur')
    });
  $dragger->start ($event);
}

sub _update_adjustment_extents {
  my ($self) = @_;
  my (undef, undef, $width, $height) = $self->allocation->values;
  my $scale = $self->get('scale');
  ### _update_adjustment_extents()
  ### $width
  ### $height
  ### $scale
  {
    my $hadj = $self->{'hadjustment'};
    my $page = $width / $scale;
    $hadj->set (page_size      => $page,
                page_increment => $page * .8,
                step_increment => $page * .2,
                upper          => max ($hadj->upper, $hadj->value + 2.5*$page),
                lower          => min ($hadj->lower, $hadj->value - 1.5*$page),
               );
    ### hadj: $hadj->value.' of '.$hadj->lower.' to '.$hadj->upper.' page='.$hadj->page_size
  }
  {
    my $vadj = $self->{'vadjustment'};
    my $page = $height / $scale;
    $vadj->set (page_size      => $page,
                page_increment => $page * .8,
                step_increment => $page * .2,
                upper          => max ($vadj->upper, $vadj->value + 2.5*$page),
                lower          => min ($vadj->lower, $vadj->value - 1.5*$page),
               );
    ### vadj: $vadj->value.' of '.$vadj->lower.' to '.$vadj->upper
  }
  #   my $coord = $self->{'coord'};
  #   my ($value,       undef) = $coord->untransform(0,0);
  #   my ($value_upper, undef) = $coord->untransform($width,0);
  #   my $page_size = $value_upper - $value;
  #   ### hadj: "$value to $value_upper"
  #   $hadj->set (lower     => min (0, $value - 1.5 * $page_size),
  #               upper     => max (0, $value_upper + 1.5 * $page_size),
  #               page_size => $page_size);
  # }
}

#------------------------------------------------------------------------------
# generic

sub draw_text_centred {
  my ($widget, $drawable, $str) = @_;
  ### draw_text_centred(): $str
  ### $drawable
  my ($width, $height) = $drawable->get_size;
  my $layout = $widget->create_pango_layout ($str);
  $layout->set_wrap ('word-char');
  $layout->set_width ($width * Gtk2::Pango::PANGO_SCALE());
  my ($str_width, $str_height) = $layout->get_pixel_size;
  my $x = max (0, int (($width  - $str_width)  / 2));
  my $y = max (0, int (($height - $str_height) / 2));

  ### paint: "$x,$y  $str_width x $str_height of $width x $height"
  my $style = $widget->get_style;
  $style->paint_layout ($drawable,
                        $widget->state,
                        0, # use foreground gc
                        undef,
                        $widget,
                        'centred-text',
                        $x, $y, $layout);
}

1;
