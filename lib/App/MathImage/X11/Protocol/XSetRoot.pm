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
use Carp;
use App::MathImage::X11::Protocol::MoreUtils
  'visual_is_dynamic', 'window_visual';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 45;

use constant _XA_PIXMAP => 20;  # pre-defined atom

# _XSETROOT_ID the same as xsetroot and other rootwin programs do
sub set_background {
  my ($class, %opt) = @_;
  ### XSetRoot set_background()

  my $X = $opt{'X'} || do {
    my $display = $opt{'display'};
    if (! defined $display) {
      $display = ''; # default $ENV{DISPLAY}
    }
    ### $display
    require X11::Protocol;
    X11::Protocol->new ($display)
    };
  ### X: "$X"

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
                       _XA_PIXMAP,
                       32,  # format
                       'Replace',
                       pack ('L', $resource_pixmap));
    $X->SetCloseDownMode('RetainPermanent');
  }
}

sub kill_id {
  my ($class, $X, $rootwin) = @_;
  ### XSetRoot kill_id()
  $rootwin ||= $X->{'root'};

  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty($rootwin,
                      $X->atom('_XSETROOT_ID'),
                      0,  # AnyPropertyType
                      0,  # offset
                      1,  # length
                      1); # delete;
  if ($type == _XA_PIXMAP && $format == 32) {
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

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::X11::Protocol::XSetRoot -- set root window background

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::XSetRoot;
 App::MathImage::X11::Protocol::XSetRoot->set_background
   (X       => $X11_protocol_object,
    rootwin => $root_xid,
    pixmap  => $pixmap_xid,
    allocated_pixels => $bool);
 # now don't use $X11_protocol_object connection any more

=head1 DESCRIPTION

This module uses an C<X11::Protocol> connection object to set the root
window background in the style of the C<xsetroot> program.

=head1 FUNCTIONS

=over 4

=item C<<  App::MathImage::X11::Protocol::XSetRoot->set_background (key=>value, ...) >>

Set the root window background to a pixmap or a pixel.  The key/value
parameters are

    X        => X11::Protocol object
    display  => string ":0:0" etc
    rootwin  => XID of root window, otherwise default
    pixmap   => XID of pixmap to display
    pixel    => integer pixel value
    allocated_pixels => boolean, default false

C<X> is the C<X11::Protocol> connection, or C<display> is a display name to
connect to, or otherwise the default display per C<$ENV{'DISPLAY'}> is used.

C<pixmap> is the XID of a pixmap to set as the background, or C<pixel> is an
integer pixel value.  One of the two is mandatory.

If C<allocated_pixels> is true then C<pixel> or some of the pixels in
C<pixmap> have been allocated in the root window's colormap.  Those
allocations are preserved if necessary using
C<SetCloseDownMode('RetainPermanent')> and an ID saved in the root window
C<_XSETROOT_ID> property.  In this case the C<$X> connection cannot be used
any more as it could be killed at any time by another C<xsetroot> freeing
the allocations.

=item C<<  App::MathImage::X11::Protocol::XSetRoot->kill_id ($X) >>

=item C<<  App::MathImage::X11::Protocol::XSetRoot->kill_id ($X, $rootwin) >>

Kill any existing C<_XSETROOT_ID> on the given C<$rootwin> XID.  If
C<$rootwin> is C<undef> or omitted then the C<$X> default root is used.

This is normally only wanted when replacing C<_XSETROOT_ID> in the way
C<set_background> above does.  

=back

=head1 SEE ALSO

L<math-image>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut


#   If the root
# window is C<PseudoColor> or other dynamic colormap visual, then those pixels
# are preserved using C<SetCloseDownMode('RetainPermanent')> and an ID saved
# in the root window C<_XSETROOT_ID> property.
# 
# A subsequent C<xsetroot> etc will free the allocated pixel resources by a
# C<KillClient>.  This could happen any time after this C<set_background>,
# perhaps immediately after, which means the given C<X> connection cannot be
# used for anything more.

