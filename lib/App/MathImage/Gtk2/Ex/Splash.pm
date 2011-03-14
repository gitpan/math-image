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


package App::MathImage::Gtk2::Ex::Splash;
use 5.008;
use strict;
use warnings;
use Glib 1.220;
use List::Util 'max';

our $VERSION = 48;

use Glib::Object::Subclass 'Gtk2::Window',
  signals => { realize      => \&_do_realize,
               map          => \&_do_map,
               map_event    => \&_do_map_event,
               expose_event => \&_do_expose_event },

  properties => [ Glib::ParamSpec->object ('pixmap',
                                           (do {
                                             my $str = 'Pixmap';
                                             eval { require Locale::Messages;
                                                    Locale::Messages::dgettext('gtk20-properties',$str)
                                                    } || $str }),
                                           'Blurb.',
                                           'Gtk2::Gdk::Pixmap',
                                           Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object ('pixbuf',
                                           (do {
                                             my $str = 'Pixbuf';
                                             eval { require Locale::Messages;
                                                    Locale::Messages::dgettext('gtk20-properties',$str)
                                                    } || $str }),
                                           'Blurb.',
                                           'Gtk2::Gdk::Pixbuf',
                                           Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string ('filename',
                                           (do {
                                             # as from GtkFileSelection and
                                             # GtkRecentManager
                                             my $str = 'Filename';
                                             eval { require Locale::Messages;
                                                    Locale::Messages::dgettext('gtk20-properties',$str)
                                                    } || $str }),
                                           'Blurb.',
                                           (eval {Glib->VERSION(1.240);1}
                                            ? undef # default
                                            : ''),  # no undef/NULL before Perl-Glib 1.240
                                           Glib::G_PARAM_READWRITE),
                ];

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my $class = shift;
  return $class->SUPER::new (type => 'popup', @_);
}

sub INIT_INSTANCE {
  my ($self) = @_;
  ### Splash INIT_INSTANCE()
  $self->set_app_paintable (0);
  $self->can_focus (0);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### Splash SET_PROPERTY: $pname

  $self->{$pname} = $newval;
  _update_pixmap ($self);
}

sub _do_expose_event {
  # my $self = shift;
  ### Splash _do_expose(), no chain to default
  # avoid GtkWindow handler gtk_window_expose() drawing the style background
  # colour ...
}

sub _do_realize {
  my $self = shift;
  ### Splash _do_realize()

  # Think window_type=>'temp' means override_redirect=>1 already.
  # my $rootwin = ($self->{'root_window'}
  #                || ($self->{'screen'} && $self->{'screen'}->get_root_window)
  #                || Gtk2::Gdk->get_default_root_window);
  # my $window = Gtk2::Gdk::Window->new ($rootwin,
  #                                      { window_type => 'temp',
  #                                        width  => 100,
  #                                        height => 100,
  #                                        override_redirect => 1,
  #                                      });
  # $self->window ($window);
  # my $style = $self->style;
  # $self->set_style ($style->attach($window)); # create gc's etc

  $self->signal_chain_from_overridden();
  my $window = $self->window;

  ### xwininfo: do { $self->get_display->flush; $self->window && system "xwininfo -events -id ".$self->window->XID }

  if ($window->can('set_type_hint')) { # new in Gtk 2.10
    $window->set_type_hint ('splashscreen');
  }
  $window->set_override_redirect (1);
  _update_pixmap ($self);
}

sub _do_map {
  my $self = shift;
  ### _do_map()
  $self->signal_chain_from_overridden ();

  # $self->window is override_redirect and therefore won't go to the window
  # manager.  A map_event should be received from the server simply after a
  # sync.
  #
  if ($self->can('get_display')) { # new in Gtk 2.2
    ### display sync
    $self->get_display->sync;
  } else {
    ### flush() is XSync in Gtk 2.0.x
    Gtk2::Gdk->flush;
  }
  # wait for map_event or no more events, whichever comes first
  $self->{'seen_map_event'} = 0;
  my $count = 1000;
  while (Gtk2->events_pending && ! $self->{'seen_map_event'} && --$count > 0) {
    # if (my $event = Gtk2::Gdk::Event->peek) {
    #   ### event: $event
    #   ### type: $event && $event->type
    # }
    Gtk2->main_iteration_do(0); # non-blocking
  }
}

sub _do_map_event {
  my $self = shift;
  ### _do_map_event()
  $self->{'seen_map_event'} = 1;
  $self->signal_chain_from_overridden (@_);
}

sub _update_pixmap {
  my ($self) = @_;
  ### _update_pixmap()

  ### pixmap: $self->{'pixmap'}
  ### pixbuf: $self->{'pixbuf'}
  ### filename: $self->{'filename'}

  my $window = $self->window || return;

  my $pixmap = $self->{'pixmap'};
  if (! $pixmap) {
    my $pixbuf = $self->{'pixbuf'};

    if (! $pixbuf
        && defined (my $filename = $self->{'filename'})) {
      ### $filename
      $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file ($filename);
    }

    ### $pixbuf
    if ($pixbuf) {
      ### state: $self->state
      ### style: $self->get_style
      ### bg-gc: $self->get_style->bg_gc($self->state)
      ### bg-color: $self->get_style->bg($self->state)->to_string

      my $width = $pixbuf->get_width;
      my $height = $pixbuf->get_height;
      $pixmap = Gtk2::Gdk::Pixmap->new ($window, $width,$height, -1);

      # my $bg_color = $self->get_style->bg($self->state);
      # my $gc = Gtk2::Gdk::GC->new($pixmap, { foreground => $bg_color });

      my $gc = $self->get_style->bg_gc($self->state);
      $pixmap->draw_rectangle ($gc,
                               1, # filled
                               0,0,
                               $width,$height);
      $pixbuf->render_to_drawable ($pixmap,
                                   $gc,
                                   0,0,
                                   0,0,
                                   $width, $height,
                                   'none',  # dither
                                   0,0);
    }
  }
  ### $pixmap

  my ($width, $height) = ($pixmap ? $pixmap->get_size : (1,1));
  $self->resize ($width, $height);
  ### resize to: "$width, $height"

  my $root = ($window->can('get_screen') # new in Gtk 2.2
              ? $window->get_screen->get_root_window
              : Gtk2::Gdk->default_root_window);
  my ($root_width, $root_height) = $root->get_size;
  my $x = max (0, int (($root_width - $width) / 2));
  my $y = max (0, int (($root_height - $height) / 2));
  ### move to: "$x,$y"
  $self->move ($x, $y);

  # the size is normally only applied under ->map(), or some such, force here
  $window->move_resize ($x, $y, $width, $height);

  ### Splash set_back_pixmap(): $pixmap
  $window->set_back_pixmap ($pixmap);
  $window->clear;
}

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde toplevel startup filename GdkPixbuf PNG JPEG Gtk

=head1 NAME

App::MathImage::Gtk2::Ex::Splash -- toplevel splash widget

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::Splash;
 my $splash = App::MathImage::Gtk2::Ex::Splash->new
                (filename => '/my/image.png');
 $splash->present;
 # do some things
 $splash->destroy;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::Splash> is a subclass of C<Gtk2::Window>, but
don't rely on more than C<Gtk2::Widget> just yet.

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::Window
            App::MathImage::Gtk2::Ex::Splash

=head1 DESCRIPTION

This is a splash window widget designed to show an image in a temporary
toplevel centred on the screen.  It can be used at program startup if some
initializations might be slow, or it can be used for a general purpose flash
or splash.

The window is non-interactive, so it doesn't take the keyboard focus away
from whatever the user is doing.  (Is that true in a focus follows mouse
window manager mode though?)  It does consume mouse button clicks though.

The image is drawn as the window background, so it requires no redraws from
the application program if blocked etc for a time.

=head1 FUNCTIONS

=over 4

=item C<< $splash = App::MathImage::Gtk2::Ex::Splash->new (key=>value,...) >>

Create and return a new Splash widget.  Optional key/value pairs set initial
properties per C<< Glib::Object->new >>.

    my $splash = App::MathImage::Gtk2::Ex::Splash->new;

=back

=head1 PROPERTIES

=over 4

=item C<pixmap> (C<Gtk2::Gdk::Pixmap> object, default C<undef>)

=item C<pixbuf> (C<Gtk2::Gdk::Pixmap> object, default C<undef>)

=item C<filename> (string, default C<undef>)

The image to display.

A filename is read with C<Gtk2::Gdk::Pixbuf> so can be any file format
supported by GdkPixbuf.  PNG and JPEG are supported in all Gtk2 versions.

=back

The usual C<Gtk2::Window> C<screen> property determines the screen the
window is displayed on.

=head1 SEE ALSO

L<Gtk2::Window>

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
