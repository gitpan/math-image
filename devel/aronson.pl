#!/usr/bin/perl -w

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
use App::MathImage::Aronson;
use Lingua::Any::Numbers;
# Lingua::ES::Numeros;

use Smart::Comments;

{
  my $aronson = App::MathImage::Aronson->new (lang => 'fr');

  foreach (1 .. 50) {
    say $aronson->next//last;
  }
  exit 0;
}

{
  say Lingua::Any::Numbers::to_string(12345,'eu');
  $,=' ';
  say Lingua::Any::Numbers::available();
  exit 0;
}


# http://www.research.att.com/~njas/sequences/A080520
#
# 1, 2, 9, 12, 14, 16, 20, 22, 24, 28, 30, 36, 38, 47, 49, 51, 55, 57, 64,
# 66, 73, 77, 79, 91, 93, 104, 106, 109, 113, 115, 118, 121, 126, 128, 131,
# 134, 140, 142, 150, 152, 156, 158, 166, 168, 172, 174, 183, 184, 189, 191,
# 200, 207, 209, 218, 220, 224, 226, 234, 241
