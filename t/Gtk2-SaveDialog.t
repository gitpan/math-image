#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Gtk2-Ex-WidgetBits.
#
# Gtk2-Ex-WidgetBits is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Gtk2-Ex-WidgetBits is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Gtk2-Ex-WidgetBits.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
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

plan tests => 8;

require App::MathImage::Gtk2::SaveDialog;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 25;
{
  is ($App::MathImage::Gtk2::SaveDialog::VERSION,
      $want_version,
      'VERSION variable');
  is (App::MathImage::Gtk2::SaveDialog->VERSION,
      $want_version,
      'VERSION class method');

  ok (eval { App::MathImage::Gtk2::SaveDialog->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { App::MathImage::Gtk2::SaveDialog->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $dialog = do {
    # avoid spam from Gtk trying to make you buy the gnome icons
    local $SIG{'__WARN__'} = \&MyTestHelpers::warn_suppress_gtk_icon;
    App::MathImage::Gtk2::SaveDialog->new
    };
  is ($dialog->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $dialog->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $dialog->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}


#-----------------------------------------------------------------------------
# Scalar::Util::weaken

{
  my $dialog = App::MathImage::Gtk2::SaveDialog->new;
  $dialog->destroy;
  require Scalar::Util;
  Scalar::Util::weaken ($dialog);
  is ($dialog, undef, 'garbage collect when weakened');
}
exit 0;
