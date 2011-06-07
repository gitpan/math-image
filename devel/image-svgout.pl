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

my $filename = '/tmp/x.svg';

{
  require App::MathImage::Image::Base::SVGout;
  my $image = App::MathImage::Image::Base::SVGout->new (-width => 400,
                                                        -height => 400);

  ### height: $image->get('-height')

  $image->xy (1,1, 'blue');
  $image->rectangle (30,40, 80,90, 'green');
  $image->rectangle (230,40, 280,90, 'green', 1);

  $image->ellipse (30,240, 80,290, 'red');
  $image->ellipse (230,240, 280,290, 'red', 1);

  $image->line (30,340, 380,390, 'white', 1);

  print $image->save($filename);
  system ("cat $filename");

  {
    use SVG::Parser 'Expat';
    my $parser = SVG::Parser->new (-debug => 1);
    my $svg = $parser->parsefile ($filename);
  }

  system ("xzgv $filename");
  #  require SVG;
  exit 0;
}
