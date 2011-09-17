#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use Gtk '-init';

use Smart::Comments;


{
  require App::MathImage::Image::Base::Gtk::Gdk::Window;
  Gtk->init;
  my $win = Gtk::Gdk::Window->new ({ window_type => 'temp',
                                     event_mask => [],
                                     x => 800, y => 100,
                                     width => 50, height => 25,
                                   });
  $win->show;
  $win->raise;
  Gtk::Gdk->flush;
  sleep 1;
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Window->new
    (-window => $win);
  $image->rectangle (0,0, 49,24, 'black', 1);

  $image->diamond (1,1,6,6, 'white');
  $image->diamond (11,1,16,6, 'white', 1);
  $image->diamond (1,10,7,16, 'white');
  $image->diamond (11,10,17,16, 'white', 1);
  Gtk::Gdk->flush;
  sleep 1;

  my $window = $image->get('-drawable');
  print "id ",$window->XWINDOW,"\n";
  system ("xwd -id ".$window->XWINDOW." >/tmp/x.xwd && convert /tmp/x.xwd /tmp/x.xpm && cat /tmp/x.xpm");
  exit 0;
}

{
  require Image::Base::Gtk::Gdk::Drawable;
  require Gtk;
  Gtk->init;
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $image = Image::Base::Gtk::Gdk::Drawable->new
    (-drawable => $rootwin);
  say $image->xy(0,0);
  say $image->xy(1149,3);
  exit 0;
}

{
  require Image::Base::Gtk::Gdk::Drawable;
  require Gtk;
  Gtk->init;
my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $bitmap = Gtk::Gdk::Pixmap->new (undef, 10,10, 1);
  my $image = Image::Base::Gtk::Gdk::Drawable->new
    (-drawable => $bitmap);
  ### colormap: $bitmap->get_colormap
  $image->xy(0,0, '#FFFFFF');
  $image->xy(0,0, 'set');
  $image->xy(0,0, 'clear');
  say $image->xy(0,0);
  exit 0;
}

{
  require Gtk;
  Gtk->init;
  #  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $rootwin = Gtk::Gdk::Window->foreign_new (0x65);
  my $gc = Gtk::Gdk::GC->new ($rootwin);
  ### colormap: $gc->get_colormap
  exit 0;
}


{
  require Image::Base::Gtk::Gdk::Window;
  require Gtk;
  Gtk->init;
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $image = Image::Base::Gtk::Gdk::Window->new
    (-window => $rootwin);
  say $image->xy(00,0);
  exit 0;
}

{
  require Image::Base::Gtk::Gdk::Window;
  require Gtk;
  Gtk->init;
  my $win = Gtk::Gdk::Window->new (undef, { window_type => 'temp',
                                             x => 800, y => 100,
                                             width => 100, height => 100,
                                           });
  $win->show;
  my $image = Image::Base::Gtk::Gdk::Window->new
    (-window => $win);

  # $image->rectangle (10,10, 50,50, 'None', 1);
  #   # $image->rectangle (0,0, 50,50, 'None', 1);
  foreach my $i (0 .. 10) {
    # $image->ellipse (0+$i,0+$i, 50-2*$i,50-2*$i, 'None', 1);
    $image->line (0+$i,0, 50-$i,50, 'None', 1);
  }

  Gtk->main;
  exit 0;
}

{
  require Gtk;
  Gtk->init;
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $pixbuf = Gtk::Gdk::Pixbuf->get_from_drawable
    ($rootwin, undef, 800,0, 0,0, 1,1);
  ### $pixbuf
  $pixbuf->save ('/tmp/x.png', 'png');
  system ("convert  -monochrome /tmp/x.png /tmp/x.xpm && cat /tmp/x.xpm");
  exit 0;
}

{
  require Gtk;
  Gtk->init;
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $colormap = $rootwin->get_colormap;
  ### $rootwin
  ### $colormap
  my $pixmap = Gtk::Gdk::Pixmap->new ($rootwin, 10,10, -1);
  $pixmap->set_colormap($colormap);
  # $pixmap->set_colormap(undef);
  ### $pixmap
  ### colormap: $pixmap->get_colormap
  exit 0;
}


{
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  my $pixmap = Gtk::Gdk::Pixmap->new ($rootwin, 1, 1, -1);
  my @properties = $pixmap->list_properties;
  ### properties: \@properties
  exit 0;
}

{
  my $X = X11::Protocol->new;
  my $colormap = $X->{'default_colormap'};
  my $colour = 'nosuchcolour';

  print "AllocNamedColor $colormap $colormap\n";
  my @ret = $X->AllocNamedColor ($colormap, $colour);
  exit 0;
}



