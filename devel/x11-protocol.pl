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
use X11::Protocol;

use Smart::Comments;

{
  my $X = X11::Protocol->new;
  $X->GrabServer;
  $X->GrabServer;
  $X->UngrabServer;
  sleep 10;
  $X->QueryPointer ($X->{'root'});
  exit 0;
}

use constant XA_PIXMAP => 20;  # pre-defined atom
{
  my $X = X11::Protocol->new;
  my $rootwin = $X->{'root'};
  my $atom = $X->InternAtom('_MATH_IMAGE_SETROOT_ID', 0);

  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($rootwin, $atom,
                       0,  # AnyPropertyType
                       0,  # offset
                       1,  # length
                       0); # delete;
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
{
  my $X = X11::Protocol->new;
  my $rootwin = $X->{'root'};
  my $atom = $X->InternAtom('_MATH_IMAGE_SETROOT_ID', 0);

  my $resource_pixmap = $X->new_rsrc;
  ### resource_pixmap: sprintf('%#X', $resource_pixmap)
  $X->CreatePixmap ($resource_pixmap, $rootwin,
                    1,      # depth, bitmap
                    1, 1);  # width x height
  my $data = pack ('L', $resource_pixmap);

  $X->ChangeProperty($rootwin, $atom, XA_PIXMAP, 32, 'Replace', $data);
  $X->SetCloseDownMode('RetainPermanent');
  $X->QueryPointer($rootwin);  # sync
  undef $X; # close
  exit 0;
}
