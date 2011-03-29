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
use X11::Protocol::Other;

use vars '$VERSION';
$VERSION = 50;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant _XA_PIXMAP => 20;  # pre-defined atom

# _XSETROOT_ID the same as xsetroot and other rootwin programs do
sub set_background {
  my ($class, %option) = @_;
  ### XSetRoot set_background(): do { my %o = %option; delete $o{'X'}; %o }

  my $display;
  my $X = $option{'X'};
  if (! $X) {
    $display = $option{'display'};
    ### display: $display
    require X11::Protocol;
    $X = X11::Protocol->new (defined $display ? ($display) : ());
    $display ||= '';  # so not undef
  }
  ### X: "$X"

  my $screen_info;
  my $root = $option{'root'};
  if (! defined $root) {
    if (defined (my $screen_number = $option{'screen'})) {
      $screen_info = $X->{'screens'}->[$screen_number];
      $root = $screen_info->{'root'};
    } else {
      $root = $X->{'root'};
    }
  }
  ### $root
  my $allocated;

  my @change;
  my $pixmap;
  if (defined ($pixmap = $option{'pixmap'})) {
    ### $pixmap
    @change = (background_pixmap => $pixmap);
    $allocated = $option{'pixmap_allocated_colors'};

  } else {
    $screen_info ||= X11::Protocol::Other::root_to_screen_info($X,$root);
    my $pixel;
    if (defined ($pixel = $option{'pixel'})) {
      ### pixel: $pixel

    } elsif (defined (my $color_name = $option{'color_name'})) {
      ($pixel) = _alloc_named_or_hex_color($X,
                                           $screen_info->{'default_colormap'},
                                           $color_name);
      $option{'X'} = 1;
    } else {
      croak "No color, pixel or pixmap for background";
    }
    @change = (background_pixel => $pixel);

    $allocated = ($pixel != $screen_info->{'black_pixel'}
                  && $pixel != $screen_info->{'black_pixel'});
  }
  ### $root
  ### @change

  if ($allocated) {
    if (X11::Protocol::Other::visual_is_dynamic
        ($X, X11::Protocol::Other::window_visual($X,$root))) {
      unless ($option{'X'}) {
        croak 'Need X connection to set background from allocated pixel or pixmap';
      }
    } else {
      $allocated = 0;
    }
  }

  # atomic replacement of _XSETROOT_ID
  require X11::Protocol::GrabServer;
  my $grab = X11::Protocol::GrabServer->new ($X);

  _kill_current ($class, $X, $root);

  $X->ChangeWindowAttributes ($root, @change);
  if ($pixmap) { # and also don't free $pixmap==0 "None"
    ### FreePixmap: $pixmap
    $X->FreePixmap($pixmap);
  }
  $X->ClearArea ($root, 0,0,0,0);

  if ($allocated) {
    my $id_pixmap = $X->new_rsrc;
    ### save id_pixmap: sprintf('%#X', $id_pixmap)
    $X->CreatePixmap ($id_pixmap,
                      $root,
                      1,      # depth
                      1,1);  # width,height
    $X->ChangeProperty($root,
                       $X->atom('_XSETROOT_ID'),
                       _XA_PIXMAP,
                       32,  # format
                       'Replace',
                       pack ('L', $id_pixmap));
    $X->SetCloseDownMode('RetainPermanent');
  }

  # check for errors with a QueryPointer round trip, either if allocated
  # because the application will do nothing more, or if $display opened here
  if ($allocated || defined $display) {
    ### sync with QueryPointer
    $X->QueryPointer($root);
  }
}

# =item C<<  App::MathImage::X11::Protocol::XSetRoot->kill_current ($X) >>
#
# =item C<<  App::MathImage::X11::Protocol::XSetRoot->kill_current ($X, $root) >>
#
# Kill any existing C<_XSETROOT_ID> on the given C<$root> XID.  If
# C<$root> is C<undef> or omitted then the C<$X> default root is used.
#
# This is normally only wanted when replacing C<_XSETROOT_ID> in the way
# C<set_background> above does.
#
sub _kill_current {
  my ($class, $X, $root) = @_;
  ### XSetRoot kill_current()
  $root ||= $X->{'root'};

  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty($root,
                      $X->atom('_XSETROOT_ID'),
                      0,  # AnyPropertyType
                      0,  # offset
                      1,  # length
                      1); # delete
  if ($type == _XA_PIXMAP && $format == 32) {
    my $xid = unpack 'L', $value;
    ### $value
    ### kill id_pixmap: sprintf('%#X', $xid)
    if ($xid) { # watch out for $xid==None, ie. 0, maybe
      $X->KillClient($xid);
    }
  }
}

sub _alloc_named_or_hex_color {
  my ($X, $colormap, $str) = @_;
  if (my @exact = _hexstr_to_rgb($str)) {
    my ($pixel, @actual) = $X->AllocColor($colormap, @exact);
    return ($pixel, @exact, @actual);
  } else {
    return $X->AllocNamedColor($colormap, $str);
  }
}

# =item ($red16, $green16, $blue16) = hexstr_to_rgb($str)
#
# Parse a given RGB colour string like "#FF00FF" into its red, green, blue
# components as 16-bit values.  The strings recognised are 1, 2, 3 or 4
# digit hex.
#
#     #RGB
#     #RRGGBB
#     #RRRGGGBBB
#     #RRRRGGGGBBBB
#
# If C<$str> is unrecognised then the return is an empty list.
#
#     my @rgb = hexstr_to_rgb($str);
#     if (! @rgb) { die "Unrecognised colour: $str" }
#
# The return values are in the range 0 to 65535.  The digits of the 1, 2 and
# 3 forms are replicated as necessary to give a 16-bit range.  For example
# 3-digit "#321FFF000" gives 0x3213, 0xFFFF, 0.  Or 1-digit "#F0F" is
# 0xFFFF, 0, 0xFFFF.
#
# Would it be worth recognising the Xcms style "rgb:RR/GG/BB"?  Perhaps
# that's best left to full Xcms, or general colour conversion modules.  The
# X11R6 X(7) man page describes that "rgb:", but just "#" is much more
# common.

# cf XcmsLRGB_RGB_ParseString()
sub _hexstr_to_rgb {
  my ($str) = @_;
  ### $str
  # Crib: [:xdigit:] new in 5.6, so only 0-9A-F
  $str =~ /^#(([0-9A-F]{3}){1,4})$/i or return;
  my $len = length($1)/3;
  return (map {hex(substr($_ x 4, 0, 4))}
          substr ($str, 1, $len),
          substr ($str, 1+$len, $len),
          substr ($str, -$len));
}

# my %hex_factor = (1 => 0x1111,
#                   2 => 0x101,
#                   3 => 0x10 + 1/0x100,
#                   4 => 1);
#   my $factor = $hex_factor{$len} || return;
#   ### $len
#   ### $factor

1;
__END__

=for stopwords Ryde pixmap colormap RetainPermanent pre-defined lookup XID Pixmap

=head1 NAME

App::MathImage::X11::Protocol::XSetRoot -- set root window background

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::XSetRoot;
 App::MathImage::X11::Protocol::XSetRoot->set_background
                             (color_name => 'green');

 # or given $X, which then can't be used any more
 App::MathImage::X11::Protocol::XSetRoot->set_background
                             (X       => $X,
                              pixmap  => $pixmap_xid,
                              pixmap_allocated_colors => 1);

=head1 DESCRIPTION

This module uses an C<X11::Protocol> connection object to set the root
window background in the style of the C<xsetroot> program.

The simplest is a named colour, interpreted by the server generally per its
F</etc/X11/rgb.txt> file, or a 2 or 4 digit hex string "#RRGGBB" or
"#RRRRGGGGBBBB".

    App::MathImage::X11::Protocol::XSetRoot->set_background
                               (color_name => 'green');

    App::MathImage::X11::Protocol::XSetRoot->set_background
                               (color_name => '#FF0000'); # red

Or a black and white pattern in a little pixmap,

    # draw $pixmap with black_pixel and white_pixel ...
    App::MathImage::X11::Protocol::XSetRoot->set_background
                               (X      => $X,
                                pixmap => $pixmap);

C<set_background> considers that it owns the given C<$pixmap> and will free
it with C<FreePixmap> once put into the window background.

=head2 Allocated Pixels

If the background pixmap has pixels allocated with C<AllocColor> etc then
those colours are preserved in the root colormap using "RetainPermanent" and
a client ID recorded in an C<_XSETROOT_ID> property on the root window.

When this happens any subsequent C<xsetroot> or similar will free the
colours by killing the client in that C<_XSETROOT_ID>.  This could happen
immediately after setting the background, which means that after setting a
background with allocated colours the C<$X> connection cannot be used for
anything more.

    # draw $pixmap with AllocColor colours
    App::MathImage::X11::Protocol::XSetRoot->set_background
                               (X      => $X,
                                pixmap => $pixmap,
                                pixmap_allocated_colors => 1);
    # don't use $X any more

C<pixmap_allocated_colors> indicates whether colours were allocated in
C<$pixmap>, as opposed to using just the pre-defined black and white pixels.

If the root visual is static such as C<TrueColor> then C<AllocColor> is just
a lookup, not an actual allocation.  On a static visual C<set_background>
skips the RetainPermanent and C<_XSETROOT_ID>.

Currently there's nothing returned to say whether RetainPermanent was or
wasn't done and an application should assume any given C<$X> cannot be used
after a C<pixmap_allocated_colors> or an allocated C<pixel>.

=head1 FUNCTIONS

=over 4

=item C<<  App::MathImage::X11::Protocol::XSetRoot->set_background (key=>value, ...) >>

Set the root window background to a pixmap or a pixel.  The key/value
parameters are

    X        => X11::Protocol object
    display  => string ":0:0" etc

    screen   => integer, eg. 0
    root     => XID of root window

    color_name => string
    pixel      => integer pixel value
    pixmap     => XID of pixmap to display
    pixmap_allocated_colors => boolean, default false

The server is given by an C<X> connection, or C<display> name to connect to,
or otherwise the default C<DISPLAY> environment variable.

The root window to set is given by C<root> or C<screen>, or otherwise the
C<$X> "chosen" screen or the C<display> default.

What to display is given by a colour name, pixel, or pixmap.  C<color_name>
can be anything understood by the server C<AllocNamedColor>, plus 2 or 4
digit hex "#RRGGBB" or "#RRRRGGGGBBBB".

C<pixel> is an integer pixel value in the root window colormap.  It's taken
to be an "allocated" pixel if it's the screen pre-defined black or white
pixels.

C<pixmap> is the XID integer.  C<set_background> considers it owns this
pixmap and will C<FreePixmap> at the right time.  Pixmap 0 means no pixmap,
which gives the server's default root background.

C<pixmap_allocated_colors> should be true if any of the pixels in C<pixmap>
were allocated with C<AllocColor> etc, as opposed to just the screen
pre-defined black and white pixels.

When an allocated pixel or a pixmap with allocated pixels is set as the
background the C<_XSETROOT_ID> mechanism described above means the C<$X>
could be killed by another C<xsetroot> at any time, so the C<$X> connection
should not be used any more.  The easiest thing is to make C<set_background>
the last thing done on C<$X>.

Setting a C<pixel> or C<pixmap> can only be done on a given C<X> connection,
not from a newly opened connection with the C<display> option.  This is
because "retaining" with C<_XSETROOT_ID> can only be done from the client
connection which created them, not a new connection.

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

