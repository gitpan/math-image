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
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Devel::Comments;

require App::MathImage::Image::Base::Gtk::Gdk::Pixbuf;
diag "Image::Base version ", Image::Base->VERSION;

require Gtk;
Gtk->init_check
  or plan skip_all => 'due to no DISPLAY available';

if (! eval { require Gtk::Gdk::Pixbuf; 1 }) {
  diag 'Gtk::Gdk::Pixbuf not available -- ',$@;
  plan skip_all => 'due to Gtk::Gdk::Pixbuf not available';
}

plan tests => 1983;

my $have_File_Temp = eval { require File::Temp; 1 };
if (! $have_File_Temp) {
  diag 'File::Temp not available -- ',$@;
}

#------------------------------------------------------------------------------
# VERSION

my $want_version = 80;
is ($App::MathImage::Image::Base::Gtk::Gdk::Pixbuf::VERSION,
    $want_version, 'VERSION variable');
is (App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->VERSION($check_version); 1 },
    "VERSION class check $check_version");


#------------------------------------------------------------------------------
# new() -pixbuf

# with alpha
{
  require Gtk::Gdk::Pixbuf;
  my $pixbuf = Gtk::Gdk::Pixbuf->new (0,      # format rgb
                                      1,      # has_alpha
                                      8,      # bits per sample
                                      8,9);   # width,height
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-pixbuf => $pixbuf);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'App::MathImage::Image::Base::Gtk::Gdk::Pixbuf');

  is ($image->VERSION, $want_version, 'VERSION object method');
  ok (eval { $image->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $image->VERSION($check_version); 1 },
      "VERSION object check $check_version");

  is ($image->get('-file'), undef, 'get() -file');
  is ($image->get('-width'),  8, 'get() -width');
  is ($image->get('-height'), 9, 'get() -height');
}

# without alpha
{
  my $pixbuf = Gtk::Gdk::Pixbuf->new (0,      # format rgb
                                      0,      # has_alpha
                                      8,      # bits per sample
                                      8,9);   # width,height
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-pixbuf => $pixbuf);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'App::MathImage::Image::Base::Gtk::Gdk::Pixbuf');
}


#------------------------------------------------------------------------------
# new() create pixbuf

{
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width  => 8,
     -height => 9);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'App::MathImage::Image::Base::Gtk::Gdk::Pixbuf');

  is ($image->get('-file'), undef, 'create pixbuf, get() -file');
  is ($image->get('-width'),  8, 'create pixbuf, get() -width');
  is ($image->get('-height'), 9, 'create pixbuf, get() -height');
}

#------------------------------------------------------------------------------
# new() copy image object

{
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width  => 8,
     -height => 9);
  my $new_image = $image->new;

  is ($new_image->get('-file'), undef, 'dup image, get() -file');
  is ($new_image->get('-width'),  8, 'dup image, get() -width');
  is ($new_image->get('-height'), 9, 'dup image, get() -height');
  isnt ($image->get('-pixbuf'), $new_image->get('-pixbuf'),
        'dup image, different -pixbuf');
}

#------------------------------------------------------------------------------
# load_string() xpm

{
  require MyTestImageBase;
  my $str = <<'HERE';
/* XPM */
static char *x[] = {
"2 3 1 1 0 1",
"  c white",
"  ",
"  ",
"  "
};
HERE
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new (-width => 1, -height => 1);
  $image->load_string ($str);
  is ($image->get('-width'),  2, 'get() xpm -width');
  is ($image->get('-height'), 3, 'get() xpm -height');
}

#------------------------------------------------------------------------------
# load_string() ico

{
  my $str =
    ("\x{00}\x{00}\x{02}\x{00}\x{01}\x{00}\x{02}\x{03}"
     . "\x{00}\x{00}\x{00}\x{00}\x{01}\x{00}\x{4C}\x{00}"
     . "\x{00}\x{00}\x{16}\x{00}\x{00}\x{00}\x{28}\x{00}"
     . "\x{00}\x{00}\x{02}\x{00}\x{00}\x{00}\x{06}\x{00}"
     . "\x{00}\x{00}\x{01}\x{00}\x{18}\x{00}\x{00}\x{00}"
     . "\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}"
     . "\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}"
     . "\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{AA}"
     . "\x{FF}\x{00}\x{AA}\x{FF}\x{00}\x{00}\x{00}\x{AA}"
     . "\x{FF}\x{00}\x{AA}\x{FF}\x{00}\x{00}\x{00}\x{AA}"
     . "\x{FF}\x{00}\x{AA}\x{FF}\x{00}\x{00}\x{00}\x{00}"
     . "\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}\x{00}"
     . "\x{00}\x{00}");
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new (-width => 1, -height => 1);
  $image->load_string ($str);
  is ($image->get('-width'),  2, 'get() ico -width');
  is ($image->get('-height'), 3, 'get() ico -height');
}


#------------------------------------------------------------------------------
# colour_to_colorobj

# {
#   my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
#     ("\x00\00\00\xFF" x (10*10),
#      0,      # format rgb
#      1,      # has_alpha
#      8,      # bits per sample
#      10,10,  # width,height
#      10*4);  # rowstride
#   my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
#     (-pixbuf => $pixbuf);
#   foreach my $colour ('black',
#                       'white',
#                       '#FF00FF',
#                       '#0000AAAAbbbb',
#                       'set',
#                       # 'SET',
#                       'clear',
#                       # 'CLEAR'
#                      ) {
#     my $c = $image->colour_to_colorobj($colour);
#     my $c2 = $image->colour_to_colorobj($colour);
#     ok ($c, "colour_to_colorobj() $colour");
#   }
# }

#------------------------------------------------------------------------------
# xy

{
  my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
    ("\x00\00\00\xFF" x (5*5),
     0,      # format rgb
     1,      # has_alpha
     8,      # bits per sample
     5,5,    # width,height
     5*4);   # rowstride
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-pixbuf => $pixbuf);
  $image->xy (1,2, 'black');
  $image->xy (3,4, 'white');
  is ($image->xy (1,2), '#000000', 'xy() black');
  is ($image->xy (3,4), '#FFFFFF', 'xy() white');

  $image->xy (2,2, 'none');
  is ($image->xy (2,2), 'None', 'xy() none');
}

#------------------------------------------------------------------------------
# xy() colour bytes

foreach my $has_alpha (0, 1) {
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width => 1, -height => 1, -has_alpha => $has_alpha);

  foreach my $elem (['#123456', "\x12\x34\x56"],
                    ['#abcdef', "\xAB\xCD\xEF"],
                   ) {
    my ($colour, $want_bytes) = @$elem;
    $image->xy(0,0,$colour);

    my $got_bytes = $image->get('-pixbuf')->get_pixels(0,0);
    $got_bytes = substr($got_bytes,0,3);
    is ($got_bytes, $want_bytes, "get_pixels() bytes");
    my $got_colour = $image->xy(0,0);
    is ($got_colour, uc($colour), "get_pixels() colour");
  }
}


#------------------------------------------------------------------------------
# line

{
  my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
    ("\xFF\xFF\xFF\xFF" x (20*10),
     0,      # format rgb
     1,      # has_alpha
     8,      # bits per sample
     20,10,  # width,height
     20*4);  # rowstride
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-pixbuf => $pixbuf);
  $image->rectangle (0,0, 19,9, 'black', 1);
  $image->line (5,5, 7,7, 'white', 0);
  is ($image->xy (4,4), '#000000', 'line not 4,4');
  is ($image->xy (5,5), '#FFFFFF', 'line at 5,5');
  is ($image->xy (5,6), '#000000');
  is ($image->xy (6,6), '#FFFFFF');
  is ($image->xy (7,7), '#FFFFFF');
  is ($image->xy (8,8), '#000000');
}
{
  my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
    ("\x00\x00\x00\xFF" x (20*10),
     0,      # format rgb
     1,      # has_alpha
     8,      # bits per sample
     20,10,  # width,height
     20*4);  # rowstride
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-pixbuf => $pixbuf);
  $image->rectangle (0,0, 19,9, 'black', 1);
  $image->line (0,0, 2,2, 'white', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (1,1), '#FFFFFF');
  is ($image->xy (2,1), '#000000');
  is ($image->xy (3,3), '#000000');
}

# horizontal line
{
  my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
    ("\x00\x00\x00" x (20*10),
     0,      # format rgb
     0,      # has_alpha
     8,      # bits per sample
     20,10,  # width,height
     20*3);  # rowstride
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-pixbuf => $pixbuf);
  $image->rectangle (0,0, 19,9, 'black', 1);
  $image->line (3,2, 13,2, 'white', 1);
  is ($image->xy (2,2),  '#000000');
  is ($image->xy (3,2),  '#FFFFFF');
  is ($image->xy (13,2), '#FFFFFF');
  is ($image->xy (14,2), '#000000');
  is ($image->xy (2,0),  '#000000');
}

#------------------------------------------------------------------------------
# rectangle

{
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width  => 20,
     -height => 10);
  $image->rectangle (0,0, 19,9, 'black', 1);
  $image->rectangle (5,5, 7,7, 'white', 0);
  is ($image->xy (4,5), '#000000');
  is ($image->xy (5,5), '#FFFFFF');
  is ($image->xy (8,5), '#000000');
  is ($image->xy (6,6), '#000000');
  is ($image->xy (7,6), '#FFFFFF');
  is ($image->xy (8,8), '#000000');
}
{
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width  => 20,
     -height => 10);
  $image->rectangle (0,0, 19,9, 'black', 1);
  $image->rectangle (0,0, 2,2, '#FFFFFF', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (1,1), '#FFFFFF');
  is ($image->xy (2,1), '#FFFFFF');
  is ($image->xy (3,3), '#000000');
}

#------------------------------------------------------------------------------
# rectangle() colour bytes

foreach my $has_alpha (0, 1) {
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width => 1, -height => 1, -has_alpha => $has_alpha);

  foreach my $elem (['#123456', "\x12\x34\x56"],
                    ['#abcdef', "\xAB\xCD\xEF"],
                   ) {
    my ($colour, $want_bytes) = @$elem;
    $image->rectangle(0,0,0,0,$colour,1); # fill

    my $got_bytes = $image->get('-pixbuf')->get_pixels (0,0);
    $got_bytes = substr($got_bytes,0,3);
    is ($got_bytes, $want_bytes, "get_pixels() bytes");
    my $got_colour = $image->xy(0,0);
    is ($got_colour, uc($colour), "get_pixels() colour");
  }
}

#------------------------------------------------------------------------------

{
  require MyTestImageBase;
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width  => 21,
     -height => 10);
  local $MyTestImageBase::white = 'white';
  local $MyTestImageBase::black = 'black';
  local $MyTestImageBase::white = 'white';
  local $MyTestImageBase::black = 'black';
  MyTestImageBase::check_image ($image);
}

exit 0;
