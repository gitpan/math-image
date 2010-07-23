#!/usr/bin/perl

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
  #   require Prima;
  #   require Prima::Const;
  Prima->import('Application');
  use Prima 'Application';

  #  Prima::MainWindow->new;

  #   use Prima::StdDlg;
  #   use Prima::FileDialog;
  #   my $dialog = Prima::FileDialog->create;
  #   $dialog->execute;

  require App::MathImage::Prima::About;
  my $about = App::MathImage::Prima::About->popup;
#  $about->execute;

  Prima->run;
  exit 0;
}
{
  require Prima;

  printf "white %X\n", cl::White();
  my $coderef = cl->can('White');
  printf "white coderef %s  %X\n", $coderef, &$coderef();

  require App::MathImage::Image::Base::Prima::Drawable;
  my $d = Prima::Image->create (width => 100,
                                height => 100,
                                type => im::bpp8(),
                                # type => im::RGB(),
                               );
  # $d-> palette([0,255,0],[255,255,255], [0xFF,0x00,0xFF], [0x00,0xFF,0x00]);
  $d-> palette([0,255,0, 255,255,255, 0xFF,0x00,0xFF, 0x00,0xFF,0x00]);
  # $d-> palette(0x000000, 0xFF00FF, 0xFFFFFF, 0x00FF00);
  ### palette: $d-> palette

  ### bpp: $d->get_bpp

  my $image = App::MathImage::Image::Base::Prima::Drawable->new
    (-drawable => $d);
  print "width ", $image->get('-width'), "\n";
  $image->set('-width',50);
  print "width ", $image->get('-width'), "\n";

  # $image->ellipse(5,5, 15,15, 'white');
  $image->rectangle(0,0,10,10, 'green');

  $image->xy(0,0, '#00FF00');
  $image->xy(1,1, '#FFFF0000FFFF');
  print "xy ", $image->xy(0,0), "\n";
  say $d->pixel(0,0);

  exit 0;
}
