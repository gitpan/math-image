#!/usr/bin/perl -w

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

use 5.010;
use strict;
use warnings;

use Smart::Comments;

{
  require Convert::Color::X11;
  @Convert::Color::X11::RGB_TXT = ('/tmp/rgb.txt');
  print scalar(Convert::Color::X11->colors),"\n";
  my $c = Convert::Color::X11->new('redfdjks');
  ### $c
  exit 0;
}

# roygbiv
{
  my $w = 256*3;
  my $h = 100;
  require Image::Base::Gtk2::Gdk::Pixbuf;
  require Convert::Color::HSV;
  require Graphics::Color::HSV;
  my $image = Image::Base::Gtk2::Gdk::Pixbuf->new (-width => $w,
                                                   -height => $h);
  foreach my $x (0 .. $w-1) {
    my $hue = ($w-1 - $x)/$w;
    # $hue = int($hue * 7) / 7;
    # my $hsv = Convert::Color::HSV->new($hue*360, 1, 1);
    # my $rgb = $hsv->as_rgb16;
    # my $colour = '#' . $rgb->hex;

    my $hsv = Graphics::Color::HSV->new ({ hue => $hue*360,
                                           saturation => 1,
                                           value => 1});
    my $rgb = $hsv->to_rgb;
    my $colour = $rgb->as_hex_string('#');
    $image->line ($x,0, $x,$h-1, $colour);
  }
  $image->save('/tmp/x.png');
  system ('xzgv /tmp/x.png');
  exit 0;
}

