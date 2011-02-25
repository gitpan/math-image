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


package App::MathImage::X11::Protocol::MoreUtils;
use 5.004;
use strict;
use Carp;

use vars '$VERSION', '@ISA', '@EXPORT_OK';
$VERSION = 45;

use Exporter;
@ISA = ('Exporter');
@EXPORT_OK = qw(InternAtoms
                atoms
                root_to_screen_info
                root_to_screen_number
                visual_is_dynamic
                visual_class_is_dynamic
                window_size
                window_visual);

# uncomment this to run the ### lines
#use Smart::Comments;

sub InternAtoms {
  my $X = shift;
  my @seq;
  my @reply;
  my @ret;
  while (@_) {
    $X->send ('InternAtom', shift);
    if (@seq > 100) {
      $X->handle_input_for (shift @seq);
      push @ret, $X->unpack_reply('InternAtom', shift @reply);
    }
  }
  while (@seq) {
    $X->handle_input_for (shift @seq);
    push @ret, $X->unpack_reply('InternAtom', shift @reply);
  }
  return @ret;
}

sub atoms {
  my $X = shift;
  my @fetch_names = grep {$X->{'atoms'}->{$_}} @_;
  my @fetch_ids = InternAtoms ($X, @fetch_names);
  foreach my $i (0 .. $#fetch_names) {
    $X->{'atoms'}->{$fetch_names[$i]} = $fetch_ids[$i];
  }
  return map {$X->atom($_)} @_;
}

sub window_size {
  my ($X, $window) = @_;
  ### MoreUtils window_size(): "$X $window"
  if (my $screen = root_to_screen_info($X,$window)) {
    return ($screen->{'width_in_pixels'}, $screen->{'height_in_pixels'});
  }
  my %geom = $X->GetGeometry ($window);
  return ($geom{'width'}, $geom{'height'});
}
sub window_visual {
  my ($X, $window) = @_;
  ### MoreUtils window_visual(): "$X $window"
  if (my $screen = root_to_screen_info($X,$window)) {
    return $screen->{'root_visual'};
  }
  my %attr = $X->GetWindowAttributes ($window);
  return $attr{'visual'};
}

sub root_to_screen_number {
  my ($X, $root) = @_;
  ### MoreUtils root_to_screen_number(): $root
  return ($X->{__PACKAGE__.'.root_to_screen_number'}
          ||= { map {($X->{'screens'}->[$_]->{'root'} => $_)}
                0 .. $#{$X->{'screens'}} })
    ->{$root};
}
sub root_to_screen_info {
  my ($X, $root) = @_;
  ### MoreUtils root_to_screen_info(): $root
  my $ret;
  if (defined ($ret = root_to_screen_number($X,$root))) {
    $ret = $X->{'screens'}->[$ret];
  }
  return $ret;

  # return ($X->{__PACKAGE__.'.root_to_screen_info'}
  #         ||= { map {($_->{'root'} => $_)} @{$X->{'screens'}} })->{$root}
}

# my %visual_class_is_dynamic = (StaticGray  => 0,  0 => 0,
#                                GrayScale   => 1,  1 => 1,
#                                StaticColor => 0,  2 => 0,
#                                PseudoColor => 1,  3 => 1,
#                                TrueColor   => 0,  4 => 0,
#                                DirectColor => 1,  5 => 1,
#                               );
sub visual_class_is_dynamic {
  my ($X, $visual_class) = @_;
  return $X->num('VisualClass',$visual_class) & 1;
}
# $visual is an X visual number
# return true if it has dynamic colour allocations
sub visual_is_dynamic {
  my ($X, $visual_id) = @_;
  my $visual_info = $X->{'visuals'}->{$visual_id}
    || croak "Unknown visual ",$visual_id;
  return visual_class_is_dynamic ($X, $visual_info->{'class'});
}


# # return true if $pixel is black or white in the default root window colormap
# sub pixel_is_black_or_white {
#   my ($X, $pixel) = @_;
#   return ($pixel == $X->{'black_pixel'} || $pixel == $X->{'white_pixel'});
# }
# 
# # return true if $colormap is one of the screen default colormaps
# sub colormap_is_default {
#   my ($X, $colormap) = @_;
#   return List::Util::first
#     {$colormap == $_->{'default_colormap'}} @{$X->{'screens'}};
# }

sub default_colormap_to_screen_info {
  my ($X, $colormap) = @_;
  ### default_colormap_to_screen_info(): $colormap
  return ($X->{__PACKAGE__.'.default_colormap_to_screen_info'}
          ||= { map {($_->{'default_colormap'} => $_)} @{$X->{'screens'}} })
    ->{$colormap};
}


1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::X11::Protocol::MoreUtils -- miscellaneous X11::Protocol helpers

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::MoreUtils;

=head1 DESCRIPTION

This is some extra helper functions for C<X11::Protocol>.

=head1 FUNCTIONS

=over 4

=item C<<  $number = App::MathImage::X11::Protocol::MoreUtils::root_to_screen_number ($X, $root) >>

=item C<<  $hashref = App::MathImage::X11::Protocol::MoreUtils::root_to_screen_info ($X, $root) >>

C<$root> should be an integer XID.  If it's one of the root windows of the
C<$X> server then return the screen number or the screen info hashref for
the screen of that root window, otherwise return C<undef>.

=item C<<  App::MathImage::X11::Protocol::MoreUtils::visual_is_dynamic ($X, $visual_id) >>

=item C<<  App::MathImage::X11::Protocol::MoreUtils::visual_class_is_dynamic ($X, $visual_class) >>

Return true if the given visual is dynamic, meaning its colormap entries can
be changed to change the colour of a given pixel value.

C<$visual_id> is one of the visual numbers, ie. one of the keys in
C<$X-E<gt>{'visuals'}>.  Or C<$visual_class> is a string like "PseudoColor"
or corresponding integer value for that constant such as 3.

=item C<<  ($width, $height) = App::MathImage::X11::Protocol::MoreUtils::window_size ($X, $window) >>

=item C<<  $visual_id = App::MathImage::X11::Protocol::MoreUtils::window_visual ($X, $window) >>

Return the size or visual ID of a given window.

C<$window> should be an integer XID.  If it's one of the root windows then
the information is obtained from the corresponding screen info in C<$X>,
otherwise the server is queried with C<GetGeometry> or
C<GetWindowAttributes>.

These functions are handy when there's a good chance that C<$window> might
be a root window and therefore not need a server round trip.

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
