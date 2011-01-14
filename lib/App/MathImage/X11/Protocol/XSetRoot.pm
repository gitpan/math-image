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


package App::MathImage::X11::Protocol::XSetRoot;
use strict;
use warnings;
use Carp;
use App::MathImage::X11::Protocol::Extras
  'visual_is_dynamic', 'window_visual';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 41;

use constant XA_PIXMAP => 20;  # pre-defined atom

# _XSETROOT_ID the same as xsetroot and other rootwin programs do
sub set_background {
  my ($class, %opt) = @_;
  ### XSetRoot set_background()

  my $X = $opt{'X'} || do {
    require X11::Protocol;
    X11::Protocol->new ($opt{'display'})
    };

  my $rootwin = $opt{'rootwin'};
  if (! defined $rootwin) {
    $rootwin = $X->{'root'};
  }
  my @args;
  my $pixmap;
  if (defined ($pixmap = $opt{'pixmap'})) {
    @args = (background_pixmap => $pixmap);
  } elsif (defined (my $pixel = $opt{'pixel'})) {
    @args = (background_pixel => $pixel);
  } else {
    croak "No pixmap or pixel for background";
  }
  ### $rootwin
  ### @args

  require App::MathImage::X11::Protocol::GrabServer;
  my $grab = App::MathImage::X11::Protocol::GrabServer->new ($X);

  $class->kill_id ($X, $rootwin);

  $X->ChangeWindowAttributes ($rootwin, @args);
  if (defined $pixmap) {
    $X->FreePixmap($pixmap);
  }
  $X->ClearArea ($rootwin, 0,0,0,0);

  if ($opt{'allocated_pixels'}
      && visual_is_dynamic($X, window_visual($X,$rootwin))) {
    my $resource_pixmap = $X->new_rsrc;
    ### save resource_pixmap: sprintf('%#X', $resource_pixmap)
    $X->CreatePixmap ($resource_pixmap,
                      $rootwin,
                      1,      # depth, bitmap
                      1, 1);  # width x height
    $X->ChangeProperty($rootwin,
                       $X->atom('_XSETROOT_ID'),
                       XA_PIXMAP,
                       32,  # format
                       'Replace',
                       pack ('L', $resource_pixmap));
    $X->SetCloseDownMode('RetainPermanent');
  }
}

sub kill_id {
  my ($class, $X, $rootwin) = @_;
  ### XSetRoot kill_id()
  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty($rootwin,
                      $X->atom('_XSETROOT_ID'),
                      0,  # AnyPropertyType
                      0,  # offset
                      1,  # length
                      1); # delete;
  if ($type == XA_PIXMAP && $format == 32) {
    my $resource_pixmap = unpack 'L', $value;
    ### $value
    ### kill resource_pixmap: sprintf('%#X', $resource_pixmap)
    if ($resource_pixmap) { # watch out for None, maybe
      $X->KillClient($resource_pixmap);
    }
  }
}

1;
__END__
