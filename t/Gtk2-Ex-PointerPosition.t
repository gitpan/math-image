#!/usr/bin/perl -w

# Copyright 2012, 2013 Kevin Ryde

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
BEGIN { MyTestHelpers::nowarnings() }

use Gtk2;
Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';
MyTestHelpers::glib_gtk_versions();

plan tests => 7;

require App::MathImage::Gtk2::Ex::Statusbar::PointerPosition;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 110;
{
  is ($App::MathImage::Gtk2::Ex::Statusbar::PointerPosition::VERSION, $want_version,
      'VERSION variable');
  is (App::MathImage::Gtk2::Ex::Statusbar::PointerPosition->VERSION, $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Gtk2::Ex::Statusbar::PointerPosition->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Gtk2::Ex::Statusbar::PointerPosition->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $dialog = App::MathImage::Gtk2::Ex::Statusbar::PointerPosition->new;
  is ($dialog->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $dialog->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $dialog->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#-----------------------------------------------------------------------------
# misc

{
  my $ppos = App::MathImage::Gtk2::Ex::Statusbar::PointerPosition->new;
  my $widget = Gtk2::DrawingArea->new;
  my $statusbar = Gtk2::Statusbar->new;
  $ppos->set (statusbar => $statusbar);
  $ppos->set (statusbar => undef);

  # set and unset to exercise weaken($self->{'widget'})
  $ppos->set (widget => $widget);
  $ppos->set (widget => undef);
  $ppos->set (widget => $widget);
  $ppos->set (widget => undef);
}

exit 0;
