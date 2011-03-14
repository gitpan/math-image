# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::DirButton;
use 5.008;
use strict;
use warnings;
use Gtk2 1.220;
use Glib::Ex::SignalBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 48;

BEGIN {
  Glib::Type->register_enum ('App::MathImage::Gtk2::Ex::DirButton::Direction',
                             'up', 'down', 'left', 'right');
  Glib::Type->register_enum ('App::MathImage::Gtk2::Ex::DirButton::Amount',
                             'step', 'page');
}

use Glib::Object::Subclass
  'Gtk2::DrawingArea',
  signals => { expose_event        => \&_do_expose,
               motion_notify_event => \&_do_motion_or_enter,
               enter_notify_event  => \&_do_motion_or_enter,
               leave_notify_event  => \&_do_leave_notify,
               button_press_event  => \&_do_button_press,
               clicked => { param_types =>
                            [ 'App::MathImage::Gtk2::Ex::DirButton::Direction',
                              'App::MathImage::Gtk2::Ex::DirButton::Amount' ],
                          },
             },
  properties => [ Glib::ParamSpec->double
                  ('xalign',
                   (do {
                     my $str = 'Horizontal alignment';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   0, 1.0, # min,max
                   0.5,    # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->double
                  ('yalign',
                   (do {
                     my $str = 'Vertical alignment';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   0, 1.0, # min,max
                   0.5,    # default
                   Glib::G_PARAM_READWRITE),

                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->{'square'} = 1;
  $self->{'drawn_dir'} = '';
  $self->add_events (['button-press-mask',
                      'pointer-motion-mask',
                      'enter-notify-mask',
                      'leave-notify-mask']);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;
  ### Enum SET_PROPERTY: $pname, $newval

  $self->queue_draw;
}

sub _do_expose {
  my ($self, $event) = @_;
  ### DirButton _do_expose()
  ### fg: $self->style->fg('normal')->to_string, $self->style->fg('prelight')->to_string
  ### bg: $self->style->bg('normal')->to_string, $self->style->bg('prelight')->to_string

  my $dir = _xy_to_direction ($self, $self->{'x'}, $self->{'y'});
  $self->{'drawn_dir'} = $dir;
  ### $dir

  my $win = $self->window;
  my $state = $self->state;
  my $style = $self->get_style;
  my (undef,undef, $width, $height) = $self->allocation->values;

  # $win->draw_rectangle ($style->bg_gc($$state),
  #                       1, # filled
  #                       0,0, $width,$height);

  if ($self->{'square'}) {
    my $w2 = int($width/2);
    my $h2 = int($height/2);

    if ($dir) {
      $win->draw_rectangle ($style->bg_gc('prelight'),
                            1, # fill,
                            ($dir eq 'left' || $dir eq 'right' ? 0 : $width-$w2),
                            ($dir eq 'left' || $dir eq 'up' ? 0 : $height-$h2),
                            $w2,$h2);
    }


    $style->paint_arrow ($win,   # window
                         $state,  # state
                         'none',  # shadow
                         $event->area,
                         $self,        # widget
                         __PACKAGE__,  # detail
                         'left',        # arrow type
                         1,             # fill
                         0,0,
                         $w2,$h2);

    $style->paint_arrow ($win,   # window
                         $state,  # state
                         'none',  # shadow
                         $event->area,
                         $self,        # widget
                         __PACKAGE__,  # detail
                         'right',        # arrow type
                         1,             # fill
                         0,$height-$h2,
                         $w2,$h2);

    $style->paint_arrow ($win,   # window
                         $state,  # state
                         'none',  # shadow
                         $event->area,
                         $self,        # widget
                         __PACKAGE__,  # detail
                         'up',        # arrow type
                         1,             # fill
                         $width-$w2,0,
                         $w2,$h2);

    $style->paint_arrow ($win,   # window
                         $state,  # state
                         'none',  # shadow
                         $event->area,
                         $self,        # widget
                         __PACKAGE__,  # detail
                         'down',        # arrow type
                         1,             # fill
                         $width-$w2,$height-$h2,
                         $w2,$h2);

  } else {
    my $xc = int($width/2);
    my $yc = int($height/2);
    my $xmid = int(.28 * $width);
    my $ymid = int(.28 * $height);
    my $xw = int(.32 * $width);
    my $yw = int(.32 * $height);

    {
      my @points_fg = ($xc, 0,
                       $xw, $ymid,
                       $width-1-$xw, $ymid,
                       $width-1-$xc, 0,
                       $xc, 0);
      my @points_bg = (0,0,
                       $width,0,
                       $xc,$yc,
                       0,0);
      my $this_dir = 'up';
      foreach (0, 1) {
        {
          my $gc = $style->bg_gc($dir eq $this_dir ? 'prelight' : $state);
          $win->draw_polygon ($gc, 0, @points_bg);
          $win->draw_polygon ($gc, 1, @points_bg);
        }
        {
          my $gc = $style->fg_gc($dir eq $this_dir ? 'prelight' : $state);
          $win->draw_polygon ($gc, 0, @points_fg);
          $win->draw_polygon ($gc, 1, @points_fg);
        }
        for (my $i = 1; $i < @points_fg; $i+=2) {
          $points_fg[$i] = $height-1-$points_fg[$i];
        }
        for (my $i = 1; $i < @points_bg; $i+=2) {
          $points_bg[$i] = $height-1-$points_bg[$i];
        }
        $this_dir = 'down';
      }
    }
    {
      my @points_fg = (0, $yc,
                       $xmid, $yw,
                       $xmid, $height-1-$yw,
                       0, $height-1-$yc,
                       0, $yc);
      my @points_bg = (0,0,
                       0,$height,
                       $xc,$yc,
                       0,0);
      my $this_dir = 'left';
      foreach (0, 1) {
        {
          my $gc = $style->bg_gc($dir eq $this_dir ? 'prelight' : $state);
          $win->draw_polygon ($gc, 0, @points_bg);
          $win->draw_polygon ($gc, 1, @points_bg);
        }
        {
          my $gc = $style->fg_gc($dir eq $this_dir ? 'prelight' : $state);
          $win->draw_polygon ($gc, 0, @points_fg);
          $win->draw_polygon ($gc, 1, @points_fg);
        }
        for (my $i = 0; $i < @points_fg; $i+=2) {
          $points_fg[$i] = $width-1-$points_fg[$i];
        }
        for (my $i = 0; $i < @points_bg; $i+=2) {
          $points_bg[$i] = $width-1-$points_bg[$i];
        }
        $this_dir = 'right';
      }
    }
  }

  return Gtk2::EVENT_PROPAGATE;
}

sub _xy_to_direction {
  my ($self, $x, $y) = @_;
  my (undef,undef, $width, $height) = $self->allocation->values;

  if (defined $x && defined $y) {
    if ($self->{'square'}) {
      if ($y >= 0 && $y < $height/2
          && $x >= 0 && $x < $width/2) {
        return 'left';
      }
      if ($y >= 0 && $y < $height/2
          && $x >= $width/2 && $x < $width) {
        return 'up';
      }
      if ($y >= $height/2 && $y < $height
          && $x >= 0 && $x < $width/2) {
        return 'right';
      }
      if ($y >= $height/2 && $y < $height
          && $x >= $width/2 && $x < $width) {
        return 'down';
      }
    }

    if ($y >= 0 && $y < $height/2
        && abs($width/2 - $x) < $width/2-$y) {
      return 'up';
    }

    if ($x >= 0 && $x < $width/2
        && abs($height/2 - $y) < $width/2-$x) {
      return 'left';
    }

    if ($y < $height && $y > $height/2
        && abs($width/2 - $x) < $width/2-($height-1-$y)) {
      return 'down';
    }

    if ($x < $width && $x > $width/2
        && abs($height/2 - $y) < $height/2-($width-1-$x)) {
      return 'right';
    }
  }
  return '';
}

sub _do_motion_or_enter {
  my ($self, $event) = @_;
  my $x = $self->{'x'} = $event->x;
  my $y = $self->{'y'} = $event->y;
  if ($self->{'drawn_dir'} ne _xy_to_direction ($self, $x, $y)) {
    $self->queue_draw;
  }
  return Gtk2::EVENT_PROPAGATE;
}

sub _do_leave_notify {
  my ($self, $event) = @_;
  ### DirButton _do_leave()
  undef $self->{'x'};
  undef $self->{'y'};
  if ($self->{'drawn_dir'}) {
    $self->queue_draw;
  }
  return Gtk2::EVENT_PROPAGATE;
}

sub _do_button_press {
  my ($self, $event) = @_;
  ### DirButton _do_button_press(): $event->x.','.$event->y
  ### dir: _xy_to_direction ($self, $event->x, $event->y)

  if ($event->button == 1
      && (my $dir = _xy_to_direction ($self, $event->x, $event->y))) {
    $self->signal_emit ('clicked',
                        $dir,
                        ($event->state & ['control-mask','shift-mask']
                         ? 'page' : 'step'));
  }
}

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::DirButton -- group of buttons up, down, left, right

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::DirButton;
 my $qb = App::MathImage::Gtk2::Ex::DirButton->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::DirButton> is a subclass of
C<Gtk2::DrawingArea>, but don't rely on more than C<Gtk2::Widget> for now.

    Gtk2::Widget
      Gtk2::DrawingArea
        App::MathImage::Gtk2::Ex::DirButton

# =head1 DESCRIPTION
# 
=head1 FUNCTIONS

=over 4

=item C<< $qb = App::MathImage::Gtk2::Ex::DirButton->new (key=>value,...) >>

Create and return a new C<DirButton> widget.  Optional key/value pairs set
initial properties per C<< Glib::Object->new >>.

    my $qb = App::MathImage::Gtk2::Ex::DirButton->new;

=back

# =head1 PROPERTIES
# 
# =over 4
# 
# =item C<combobox> (C<Gtk2::ComboBox> object, default C<undef>)
# 
# =back

=head1 SEE ALSO

L<Gtk2::Button>,
L<Gtk2::Arrow>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see L<http://www.gnu.org/licenses/>.

=cut
