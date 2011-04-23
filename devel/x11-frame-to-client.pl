#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use X11::Protocol;
use X11::AtomConstants;
use App::MathImage::X11::Protocol::Splash;

use lib 'devel', '.';

# uncomment this to run the ### lines
use Smart::Comments;

{
  my $X = X11::Protocol->new (':0');

  my ($root, $parent, @children) = $X->QueryTree ($X->root);
  ### $root
  ### $parent
  ### @children
  foreach my $child (@children) {
    printf "%X", $child;
    my $client = App::MathImage::X11::Protocol::Splash::frame_window_to_client
      ($X, $child);
    if ($client != $child) {
      printf "  client %X", $client;
    }
    print "\n";
    system 'xprop', '-d', ':0', '-id', $child;
    print "\n";
  }
  exit 0;
}
