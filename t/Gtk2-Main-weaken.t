#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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

use 5.008;
use strict;
use warnings;
use List::Util;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

use Gtk2;
Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';
MyTestHelpers::glib_gtk_versions();

# Test::Weaken 3 for "contents"
eval "use Test::Weaken 3; 1"
  or plan skip_all => "Test::Weaken 3 not available -- $@";

plan tests => 1;

require App::MathImage::Gtk2::Main;

#-----------------------------------------------------------------------------
# Test::Weaken

require Test::Weaken::Gtk2;
require Test::Weaken::ExtraBits;

{
  my $path_parameter_list;
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $main = App::MathImage::Gtk2::Main->new;
         $main->show_all;
         $path_parameter_list = $main->{'path_params'}->get('parameter-list');
         return $main;
       },
       destructor => \&Test::Weaken::Gtk2::destructor_destroy,
       contents => \&Test::Weaken::Gtk2::contents_container,
       ignore => sub {
         my ($ref) = @_;
         return ($ref == $path_parameter_list
                 || List::Util::first{$ref==$_} @$path_parameter_list);
       },
     });
  is ($leaks, undef, 'Test::Weaken deep garbage collection');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

exit 0;
