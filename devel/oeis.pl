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

use 5.004;
use strict;
use warnings;
use POSIX;

use Smart::Comments;

{
  require App::MathImage::Values::OEIS::Catalogue;
  my @list = App::MathImage::Values::OEIS::Catalogue->num_list;
  ### @list
  exit 0;
}
{
  require App::MathImage::Values::OEIS::Catalogue::Plugin::Files;
  my $info = App::MathImage::Values::OEIS::Catalogue::Plugin::Files->num_to_info(32);
  ### $info
exit 0;
}

