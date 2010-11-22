#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use Test::More tests => 12;

use App::MathImage::Image::Base::Other;

# whether to mark repeat-drawn pixels as "X" (repeat drawn pixels being
# wasteful and undesirable if they can be avoided reasonably easily).
my $MyGrid_flag_overlap = 1;

{
  package MyGrid;
  use Image::Base;
  use vars '@ISA';
  @ISA = ('Image::Base');
  sub new {
    my $class = shift;
    my $self = bless { @_}, $class;
    my $horiz = '+' . ('-' x $self->{'-width'}) . "+\n";
    $self->{'str'} = $horiz
      . (('|' . (' ' x $self->{'-width'}) . "|\n") x $self->{'-height'})
        . $horiz;
    return $self;
  }
  sub xy {
    my ($self, $x, $y, $colour) = @_;
    my $pos = $x+1 + ($y+1)*($self->{'-width'}+3);

    if ($MyGrid_flag_overlap) {
      if (substr ($self->{'str'}, $pos, 1) ne ' ') {
        # doubled up pixel, undesirable, treated as an error
        $colour = 'X';
      }
    }
    substr ($self->{'str'}, $pos, 1) = $colour;
  }
}


#------------------------------------------------------------------------------
# diamon()

foreach my $elem (

                  # one pixel
                  [0,0, 0,0, 1, <<'HERE'],
+--------------------+
|*                   |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  # horizontal
                  [3,3, 13,3, 1, <<'HERE'],
+--------------------+
|                    |
|                    |
|                    |
|   ***********      |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  # vertical
                  [3,3, 3,9, 1, <<'HERE'],
+--------------------+
|                    |
|                    |
|                    |
|   *                |
|   *                |
|   *                |
|   *                |
|   *                |
|   *                |
|   *                |
+--------------------+
HERE

                  # two pixels
                  [1,3, 2,4, 1, <<'HERE'],
+--------------------+
|                    |
|                    |
|                    |
| **                 |
| **                 |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  # 4x2
                  [1,3, 4,4, 1, <<'HERE'],
+--------------------+
|                    |
|                    |
|                    |
| ****               |
| ****               |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  # 2x4
                  [1,3, 2,6, 1, <<'HERE'],
+--------------------+
|                    |
|                    |
|                    |
| **                 |
| **                 |
| **                 |
| **                 |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  # bit of overlap yet
                  [0,0, 2,2, 0, <<'HERE'],
+--------------------+
| X                  |
|X X                 |
| X                  |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE
                  [0,0, 2,2, 1, <<'HERE'],
+--------------------+
| *                  |
|XXX                 |
| *                  |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  [0,0, 3,3, 0, <<'HERE'],
+--------------------+
| **                 |
|*  *                |
|*  *                |
| **                 |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE
                  [0,0, 3,3, 1, <<'HERE'],
+--------------------+
| **                 |
|****                |
|****                |
| **                 |
|                    |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE

                  # bit of overlap yet
                  [0,0, 4,4, 0, <<'HERE'],
+--------------------+
|  X                 |
| * *                |
|X   X               |
| * *                |
|  X                 |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE
                  [0,0, 4,4, 1, <<'HERE'],
+--------------------+
|  *                 |
| ***                |
|XXXXX               |
| ***                |
|  *                 |
|                    |
|                    |
|                    |
|                    |
|                    |
+--------------------+
HERE
                 ) {
  my ($x0,$y0, $x1,$y1, $fill, $want) = @$elem;

  my $image = MyGrid->new (-width => 20, -height => 10);
  App::MathImage::Image::Base::Other::diamond
      ($image, $x0,$y0, $x1,$y1, '*', $fill);
  my $got = $image->{'str'};
  is ("\n$got", "\n$want", "line $x0,$y0, $x1,$y1");

  ($x0,$y0, $x1,$y1) = ($x1,$y1, $x0,$y0);
}


exit 0;
