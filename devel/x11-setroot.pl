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
use X11::Protocol;

use lib "$ENV{HOME}/p/xpother/lib";

use Smart::Comments;

use constant XA_PIXMAP => 20;  # pre-defined atom

{
  require App::MathImage::X11::Protocol::XSetRoot;
  App::MathImage::X11::Protocol::XSetRoot->set_background
      (
       # color_name => '#F0FF00FFF0FF',
       # pixel => 0xFFFFFF,
       # pixel => 0xFF0000,
       # allocated_pixels => 1,
       pixmap => 0,
      );
  # now don't use $X11_protocol_object connection any more
  exit 0;
}
{
  my $X = X11::Protocol->new;
  $X->FreePixmap(0);
  ### sync: $X->QueryPointer($X->{'root'})
  exit 0;
}

{
  my $X = X11::Protocol->new;
  require App::MathImage::X11::Protocol::XSetRoot;

  # my $colormap = $X->{'default_colormap'};
  # my @ret = $X->AllocNamedColor($colormap, 'white');
  # ### @ret

  my $root = $X->{'root'};
  my $pixmap = $X->new_rsrc;
  $X->CreatePixmap ($pixmap,
                    $root,
                    $X->{'root_depth'},
                    2,2);  # width,height
  my $gc = $X->new_rsrc;
  $X->CreateGC ($gc, $pixmap, foreground => $X->{'white_pixel'});
  $X->PolyPoint ($pixmap, $gc, 'Origin', 0,0, 1,1);
  $X->ChangeGC($gc, foreground => $X->{'black_pixel'});
  $X->PolyPoint ($pixmap, $gc, 'Origin', 0,1, 1,0);
  App::MathImage::X11::Protocol::XSetRoot->set_background
      (X      => $X,
       pixmap => $pixmap);
  exit 0;
}
{
  my $X = X11::Protocol->new;
  my $rootwin = $X->{'root'};
  my $atom = $X->atom('_SETROOT_ID');

  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($rootwin, $atom,
                       0,  # AnyPropertyType
                       0,  # offset
                       1,  # length
                       0); # delete;
  ### GetProperty: $X->atom_name($atom)
  ### $value
  ### $type
  ### $format
  ### $bytes_after
  if ($type == XA_PIXMAP && $format == 32) {
    my $resource_pixmap = unpack 'L', $value;
    ### resource_pixmap: sprintf('%#X', $resource_pixmap)
    ### robust: $X->robust_req('KillClient',$resource_pixmap)
  }
  exit 0;
}
