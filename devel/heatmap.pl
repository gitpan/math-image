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
use List::Util 'min', 'max';

use Smart::Comments;


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
    my $hsv = Convert::Color::HSV->new($hue*360, 1, 1);
    my $rgb = $hsv->convert_to('rgb16');
    my $colour = '#' . $rgb->hex;

    # my $hsv = Graphics::Color::HSV->new ({ hue => $hue*360,
    #                                        saturation => 1,
    #                                        value => 1});
    # my $rgb = $hsv->to_rgb;
    # my $colour = $rgb->as_hex_string('#');
    $image->line ($x,0, $x,$h-1, $colour);
  }
  $image->save('/tmp/x.png');
  system ('xzgv /tmp/x.png');
  exit 0;
}

# black
# blue    = B
# green   = G
# cyan    = B+G
# red     = R
# orange  = R+G/2
# pink    = R+G
# yellow  = R+B
# white   = R+B+G
#
# ----------------------                   --------
#           -----------------------        --------
#                       ---------------------------
{
  my $w = 256*3;
  my $h = 100;
  require Image::Base::Gtk2::Gdk::Pixbuf;
  my $image = Image::Base::Gtk2::Gdk::Pixbuf->new (-width => $w,
                                                   -height => $h);
  my $gs = int ($w * 1/3);
  my $gw = $w - $gs;
  my $rs = int ($w * 2/3);
  my $rw = $w - $rs;
  foreach my $x (0 .. $w-1) {
    my $f = $x / ($w-1);

    my $b = 0;
    if ($f < 1/4) {
      $b = $f * 4;
    } elsif ($f < 1/2) {
      $b = (1/2-$f) * 4;
    } elsif ($f > 3/4) {
      $b = ($f-3/4) * 4;
    }
    my $blue = int (max (0, min (1, $b)) * 255);

    my $g = 0;
    if ($f > 1/4 && $f < 1/2) {
      $g = ($f-1/4) * 4;
    } elsif ($f > 1/2 && $f < 3/4) {
      $g = (3/4-$f) * 4;
    } elsif ($f > 3/4) {
      $g = ($f-3/4) * 4;
    }
    my $green = int (max (0, min (1, $g)) * 255);

    my $r = 0;
    if ($f > 1/2) {
      $r = ($f-1/2) * 2;
    }
    my $red = int (max (0, min (1, $r)) * 255);

    my $colour = sprintf '#%02X%02X%02X', $red, $blue, $green;
    say $colour;
    $colour = '#00FFFF';
    $image->line ($x,0, $x,$h-1, $colour);
  }
  $image->save('/tmp/x.png');
  system ('xzgv /tmp/x.png');
  exit 0;
}

{
  require Convert::Color::X11;
  @Convert::Color::X11::RGB_TXT = ('/tmp/rgb.txt');
  @Convert::Color::X11::RGB_TXT = ('/tmp/rgb.txt');
  print scalar(Convert::Color::X11->colors),"\n";
  my $c = Convert::Color::X11->new('redfdjks');
  ### $c
  exit 0;
}


