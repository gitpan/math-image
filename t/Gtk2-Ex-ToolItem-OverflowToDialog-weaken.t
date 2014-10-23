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

use 5.008;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
use Test::Weaken::ExtraBits;
BEGIN { MyTestHelpers::nowarnings() }

require App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog;

require Gtk2;
Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';

# Test::Weaken 3 for "contents"
eval "use Test::Weaken 3; 1"
  or plan skip_all => "due to Test::Weaken 3 not available -- $@";

eval "use Test::Weaken::Gtk2; 1"
  or plan skip_all => "due to Test::Weaken::Gtk2 not available -- $@";

plan tests => 6;


{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         return App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
       },
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'plain');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
         # $toolitem->signal_emit ('create-menu-proxy');
         my $menuitem = $toolitem->retrieve_proxy_menu_item;
         return [ $toolitem, $menuitem ];
       },
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'with menuitem');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
         my $menuitem1 = $toolitem->retrieve_proxy_menu_item;
         my $menuitem2 = $toolitem->retrieve_proxy_menu_item;
         return [ $toolitem, $menuitem1, $menuitem2 ];
       },
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'with menuitem twice');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
         my $menuitem = $toolitem->retrieve_proxy_menu_item;
         isa_ok ($menuitem, 'Gtk2::MenuItem');
         $menuitem->activate;
         my $dialog = $toolitem->{'dialog'};
         isa_ok ($dialog, 'App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog::Dialog');
         $dialog->present;
         MyTestHelpers::main_iterations();
         return [ $toolitem, $menuitem, $dialog ];
       },
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'with dialog open');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

exit 0;
