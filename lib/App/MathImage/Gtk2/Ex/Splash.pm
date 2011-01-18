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

our $VERSION = 42;

use Glib::Object::Subclass 'Gtk2::Window',
  signals => { realize => \&_do_realize,
               map => \&_do_map,
               map_event => \&_do_map_event,
               expose_event => \&_do_expose_event },
  properties => [ Glib::ParamSpec->object ('root',
                                           'Root Window',
                                           'Blurb.',
                                           'Gtk2::Gdk::Window',
                                           Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object ('pixmap',
                                           'Pixmap',
                                           'Blurb.',
                                           'Gtk2::Gdk::Pixmap',
                                           Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object ('pixbuf',
                                           'Pixbuf',
                                           'Blurb.',
                                           'Gtk2::Gdk::Pixbuf',
                                           Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->string ('filename',
                                           'Filename',
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
  $self->set_app_paintable (0);
  $self->can_focus (0);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  ### Splash SET_PROPERTY: $pspec->get_name
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;

  _update_pixmap ($self);
}

sub _do_expose_event {
  my $self = shift;
  ### _do_expose(), no chain to default
}

sub _do_realize {
  my $self = shift;
  ### _do_realize()
#   $self->signal_chain_from_overridden (@_);

  my $window = Gtk2::Gdk::Window->new ($self->{'root'} || Gtk2::Gdk->get_default_root_window,
                                       { window_type => 'temp',
                                         width => 100,
                                         height => 200,
                                         override_redirect => 1,
                                       });
  $self->window ($window);

  ### xwininfo: do { $self->get_display->flush; $self->window && system "xwininfo -events -id ".$self->window->XID }

  # my $window = $self->window;
  $window->set_events ([]);
  $window->set_override_redirect (1);
  $window->set_type_hint ('splashscreen');
  _update_pixmap ($self);

  #  ### back: $window->get_back_pixmap
}

sub _do_map {
  my $self = shift;
  ### _do_map()
  $self->signal_chain_from_overridden (@_);

  if ($self->can('get_display')) { # new in Gtk 2.2
    ### display sync
    $self->get_display->sync;
  } else {
    ### flush
    Gtk2::Gdk->flush;
  }

  #   Gtk2->main_iteration_do(1);
  # }

  $self->{'map_event'} = 0;
  while (Gtk2->events_pending && ! $self->{'map_event'}) {
    my $event = Gtk2::Gdk::Event->peek;
    ### event: $event
    ### type: $event && $event->type
    Gtk2->main_iteration_do(0);
  }
}

sub _do_map_event {
  my ($self) = @_;
  ### _do_map_event()
  $self->{'map_event'} = 1;
}

sub _update_pixmap {
  my ($self) = @_;
  ### _update_pixmap()

  if (my $window = $self->window) {

    my $pixmap = $self->{'pixmap'};
    if (! $pixmap) {
      my $pixbuf = $self->{'pixbuf'};

      if (! $pixbuf
          && defined (my $filename = $self->{'filename'})) {
        ### $filename
        $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file ($filename);
      }

      if ($pixbuf) {
        ### $pixbuf
        ### state: $self->state
        ### style: $self->get_style
        ### gc: $self->get_style->bg_gc($self->state)
        my $width = $pixbuf->get_width;
        my $height = $pixbuf->get_height;
        $pixmap = Gtk2::Gdk::Pixmap->new ($window, $width,$height, -1);

        my $gc = Gtk2::Gdk::GC->new($pixmap);
        $pixmap->draw_rectangle (
                                 # $self->get_style->bg_gc($self->state),
                                 $gc,
                                 1, # filled
                                 0,0,
                                 $width,$height);
        $pixbuf->render_to_drawable ($pixmap,
                                     $gc, # $self->get_style->black_gc,
                                     0,0,
                                     0,0,
                                     $width, $height,
                                     'none',  # dither
                                     0,0);
      }
    }

    my ($width, $height) = ($pixmap ? $pixmap->get_size : (1,1));
    my $root = $window->get_screen->get_root_window;
    my ($root_width, $root_height) = $root->get_size;
    $self->resize ($width, $height);
    ### resize to: "$width, $height"

    my $x = max (0, int (($root_width - $width) / 2));
    my $y = max (0, int (($root_height - $height) / 2));
    ### move to: "$x,$y"
    $self->move ($x, $y);

    ### Splash set_back_pixmap(): $pixmap
    $window->move_resize ($x, $y, $width, $height);
    $window->set_back_pixmap ($pixmap);
    $window->clear;
  }
}

# sub _window_invalidate_all {
#   my ($window, $invalidate_children) = @_;
#   $window->invalidate_rect (Gtk2::Gdk::Rectangle->new (0,0, $window->get_size),
#                             $invalidate_children);
# }

sub run {
  my ($class, %options) = @_;
  my $time = delete $options{'time'};
  my $self = $class->new (%options);
  $self->show;
  Glib::Timeout->add (($time||.75) * 1000, sub {
                        Gtk2->main_quit;
                        return Glib::SOURCE_REMOVE();
                      });
  Gtk2->main;
}

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde toplevel

=head1 NAME

App::MathImage::Gtk2::Ex::Splash -- toplevel splash widget

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::Splash;
 my $splash = App::MathImage::Gtk2::Ex::Splash->new;
 $splash->present;
 ...
 $splash->hide;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::Splash> is a subclass of C<Gtk2::Window>, but
don't rely on more than C<Gtk2::Widget> for now.

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Bin
          Gtk2::Window
            App::MathImage::Gtk2::Ex::Splash

=head1 DESCRIPTION

...

=head1 FUNCTIONS

=over 4

=item C<< $splash = App::MathImage::Gtk2::Ex::Splash->new (key=>value,...) >>

Create and return a new C<Splash> widget.  Optional key/value pairs set
initial properties per C<< Glib::Object->new >>.

    my $splash = App::MathImage::Gtk2::Ex::Splash->new;

=back

=head1 PROPERTIES

=over 4

=item C<pixmap> (C<Gtk2::Gdk::Pixmap> object, default C<undef>)

=back

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
