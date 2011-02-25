#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


use 5.008;
use strict;
use warnings;
use Glib 1.220;
use Gtk2 '-init';

use App::MathImage::Gtk2::Ex::Splash;

use FindBin;
my $progname = $FindBin::Script;

my $rootwin = Gtk2::Gdk->get_default_root_window;
my $pixmap = Gtk2::Gdk::Pixmap->new ($rootwin, 1000, 200, -1);
my $splash = App::MathImage::Gtk2::Ex::Splash->new
  (
   # pixmap => $pixmap,
   filename => '/usr/share/emacs/23.2/etc/images/gnus/gnus.png',
);

$splash->signal_connect (destroy => sub { Gtk2->main_quit });
$splash->signal_connect (button_press_event => sub {
                           print "$progname: button-press-event\n";
                         });
$splash->present;
sleep 5;
exit 0;
my $window = $splash->window;
my $xid = $window->XID;
system "xwininfo -events -id $xid";
# $window->set_events ([]);
# system "xwininfo -events -id $xid";

Glib::Timeout->add (5 * 1000,
                    sub {
                      $splash->destroy;
                      return Glib::SOURCE_REMOVE();
                    });
Gtk2->main;
