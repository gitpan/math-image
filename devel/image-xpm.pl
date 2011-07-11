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

use 5.010;
use strict;
use warnings;

use Smart::Comments;

{
  require Image::Base::Text;
  require App::MathImage::Image::Base::Other;

  my $image = Image::Base::Text->new (-width => 40, -height => 20);
  # $image->App::MathImage::Image::Base::Other::diamond (0,0, 16,4, '*', 0);
  $image->line (0,3, 14,0, '*', 0);
  print App::MathImage::Image::Base::Other::save_string($image);
  exit 0;
}

{
  my $image = Image::Base::Text->new (-width => 20, -height => 10);
  $image->App::MathImage::Image::Base::Other::diamond (0,0, 9,5, '*', 0);
  print App::MathImage::Image::Base::Other::save_string($image);
}

{
  require Image::Xpm;
  require App::MathImage::Image::Base::Other;
  my $image = Image::Xpm->new (-width => 50,
                               -height => 2);
  $image->line (0,0, 6,1, '#FFFF0000FFFF');
  print App::MathImage::Image::Base::Other::save_string($image);
  exit 0;
}

{
  require Image::Xpm;
  require App::MathImage::Image::Base::Other;
  my $image = Image::Xpm->new
    (-file => '/usr/share/emacs/22.3/etc/images/gud/up.xpm');
  $image->line (0,0, 6,1, 'orange');
  print App::MathImage::Image::Base::Other::save_string($image);
  exit 0;
}
