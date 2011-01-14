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

plan tests => 4;


#------------------------------------------------------------------------------
# child property

{
  my $child_widget = Gtk2::Button->new ('XYZ');
  my $toolitem =  App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new
    (child => $child_widget);
  is ($toolitem->get_child, $child_widget);
}

#------------------------------------------------------------------------------
# add()

{
  my $child_widget = Gtk2::Button->new ('XYZ');
  my $toolitem =  App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
  $toolitem->add ($child_widget);
  is ($toolitem->get_child, $child_widget);
}

#------------------------------------------------------------------------------
# child-widget property

{
  my $child_widget = Gtk2::Button->new ('XYZ');
  my $toolitem =  App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new
    (child_widget => $child_widget);
  is ($toolitem->get_child, $child_widget);
}
{
  my $child_widget = Gtk2::Button->new ('XYZ');
  my $toolitem =  App::MathImage::Gtk2::Ex::ToolItem::OverflowToDialog->new;
  $toolitem->set_child_widget ($child_widget);
  is ($toolitem->get_child, $child_widget);
}

exit 0;
