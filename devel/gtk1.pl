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

use 5.004;
use strict;

use blib '/so/gtk1/Gtk-Perl-0.7009/GdkPixbuf/blib/';

# uncomment this to run the ### lines
use Devel::Comments;

{
  require Gtk;
  Gtk->init;
  require Gtk::Gdk::Pixbuf;
  Gtk::Gdk::Pixbuf->init;
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());

  # my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
  #   ("\0\0\0",
  #    'rgb',  # colorspace rgb
  #    0,  # has_alpha,
  #    8,  # bits_per_sample
  #    1,1,3);   # width,height,rowstride
  # # $pixbuf->get_from_drawable ($rootwin, undef, 0,0, 0,0, 1,1);

  my $newp = Gtk::Gdk::Pixbuf::get_from_drawable (undef, $rootwin, undef, 0,0, 0,0, 1,1);
  # my $p2 = $pixbuf->copy;
  # $pixbuf->add_alpha(0);
  exit 0;
}

{
  require Gtk;
  Gtk->init;
  require Gtk::Gdk::Pixbuf;
  Gtk::Gdk::Pixbuf->init;
  my $pixbuf = Gtk::Gdk::Pixbuf->new_from_data
    ("\0\0\0",
     'rgb',  # colorspace rgb
     0,  # has_alpha,
     8,  # bits_per_sample
     1,1,3);   # width,height,rowstride
  # my $pixbuf = Gtk::Gdk::Pixbuf->new
  #   ('rgb',  # colorspace rgb
  #    0,  # has_alpha,
  #    8,  # bits_per_sample
  #    10,10);   # width,height
  ### $pixbuf
  my $colorobj = Gtk::Gdk::Color->parse_color ('blue');
  ### $colorobj
  exit 0;
}

{
  $ENV{DISPLAY} ||= ':0';
  require App::MathImage::Gtk1::Ex::Units;
  Gtk->init;
  my $label = Gtk::Label->new;
  print App::MathImage::Gtk1::Ex::Units::em($label),"\n";
  print App::MathImage::Gtk1::Ex::Units::char_width($label),"\n";
  print App::MathImage::Gtk1::Ex::Units::digit_width($label),"\n";

  print "ex ", App::MathImage::Gtk1::Ex::Units::ex($label),"\n";
  print "line_height ", App::MathImage::Gtk1::Ex::Units::line_height($label),"\n";

  exit 0;
}

{
  $ENV{DISPLAY} ||= ':0';
  require App::MathImage::Image::Base::Gtk::Gdk::Pixbuf;
  use lib 't';
  require MyTestImageBase;
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixbuf->new
    (-width  => 21,
     -height => 10);

  my $pixbuf = $image->get('-pixbuf');
  my $bytes = $pixbuf->get_pixels(0,0);
  ### rowstride: $pixbuf->get_rowstride
  ### width: $pixbuf->get_width
  ### height: $pixbuf->get_height
  ### bytes len: length($bytes)

  # $image->line(3,2,3,2,'white');

  $pixbuf->put_pixels ("\xFF\xFF\xFF", 3,2);
  ### row0: $pixbuf->get_pixels(0,0)
  ### row1: $pixbuf->get_pixels(1,0)
  ### row2: $pixbuf->get_pixels(2,0)
  ### row3: $pixbuf->get_pixels(3,0)

  MyTestImageBase::dump_image($image);
  exit 0;
}
{
  require App::MathImage::Gtk1::AboutDialog;
  Gtk->init;
  my $dialog = App::MathImage::Gtk1::AboutDialog->new;
  ### $dialog
  $dialog->show;
  Gtk->main;
  exit 0;
}
{
  Gtk->init;
  Gtk::Window->register_subtype('App::MathImage::Gtk1::Main');
  my $win = Gtk::Window->new;
  $win->show;
  Gtk->main;
  exit 0;
}
