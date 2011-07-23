#!/usr/bin/perl -w

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

use strict;
use Tk;
use Tk::WinPhoto;

my $mw = MainWindow->new;
my $button;
$button = $mw->Button
  (-text => 'click me when partly off-screen',
   -command =>
   sub {
     print "update() ...\n";
     $button->update;
     print "Photo() ...\n";
     my $photo = $button->Photo (-format => 'window',
                                 -data => oct($button->id));
     print "ok\n";
     exit 0;
   });
$button->pack;
MainLoop;
exit 0;
