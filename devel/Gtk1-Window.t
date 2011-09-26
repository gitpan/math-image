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

use 5.008;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

require Gtk;
Gtk->init_check
  or plan skip_all => 'due to no DISPLAY available';

plan tests => 16;

use_ok ('App::MathImage::Image::Base::Gtk::Gdk::Window');
diag "Image::Base version ", Image::Base->VERSION;

# uncomment this to run the ### lines
#use Devel::Comments;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 72;
is ($App::MathImage::Image::Base::Gtk::Gdk::Window::VERSION,
    $want_version, 'VERSION variable');
is (App::MathImage::Image::Base::Gtk::Gdk::Window->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Gtk::Gdk::Window->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Gtk::Gdk::Window->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new()

{
  my $rootwin = Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());
  ### $rootwin
  my $image = App::MathImage::Image::Base::Gtk::Gdk::Window->new
    (-window => $rootwin);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'App::MathImage::Image::Base::Gtk::Gdk::Drawable');
  isa_ok ($image, 'App::MathImage::Image::Base::Gtk::Gdk::Window');

  is ($image->VERSION,  $want_version, 'VERSION object method');
  ok (eval { $image->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $image->VERSION($check_version); 1 },
      "VERSION object check $check_version");

  is ($image->get('-drawable'), $rootwin, 'get() -drawable');
  is ($image->get('-window'),   $rootwin, 'get() -window');
  is ($image->get('-file'), undef, 'get() -file');
  # cmp_ok ($image->get('-depth'), '>', 0, 'get() -depth');
  is ($image->get('-colormap'), $rootwin->get_colormap, 'get() -colormap');
  my $visual = $rootwin->get_colormap->get_visual;
  ### $visual
}

exit 0;
