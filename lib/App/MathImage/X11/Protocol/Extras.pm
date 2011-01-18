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


package App::MathImage::X11::Protocol::Extras;
use 5.004;
use strict;
use warnings;
use Carp;
use List::Util;

use vars '$VERSION', '@ISA', '@EXPORT_OK';
$VERSION = 42;

use Exporter;
@ISA = ('Exporter');
@EXPORT_OK = qw(InternAtoms
                atoms
                rootwin_to_screen_info
                visual_is_dynamic
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
  ### window_size(): "$X $window"
  if (my $screen = rootwin_to_screen_info($X,$window)) {
    return ($screen->{'width_in_pixels'}, $screen->{'height_in_pixels'});
  }
  my %geom = $X->GetGeometry ($window);
  return ($geom{'width'}, $geom{'height'});
}
sub window_visual {
  my ($X, $window) = @_;
  ### window_visual(): "$X $window"
  if (my $screen = rootwin_to_screen_info($X,$window)) {
    return $screen->{'root_visual'};
  }
  my %attr = $X->GetWindowAttributes ($window);
  return $attr{'visual'};
}

sub rootwin_to_screen_info {
  my ($X, $rootwin) = @_;
  ### rootwin_to_screen_info(): $rootwin
  return ($X->{__PACKAGE__.'.root_to_screen_info'}
          ||= { map {($_->{'root'} => $_)} @{$X->{'screens'}} })
    ->{$rootwin};
}
sub rootwin_to_screen_number {
  my ($X, $rootwin) = @_;
  ### rootwin_to_screen_number(): $rootwin
  return ($X->{__PACKAGE__.'.root_to_screen_number'}
          ||= { map {($X->{'screens'}->[$_]->{'root'} => $_)}
                0 .. $#{$X->{'screens'}} })
    ->{$rootwin};
}

my %visual_class_is_static = (StaticGray => 1,
                              StaticColor => 1,
                              TrueColor => 1);
# $visual is an X visual number
# return true if it has dynamic colour allocations
sub visual_is_dynamic {
  my ($X, $visual) = @_;
  my $visual_info = $X->{'visuals'}->{$visual}
    || croak "Unknown visual $visual";
  return $visual_class_is_static{$visual_info->{'class'}};
}


# # return true if $pixel is one of the screen default colormaps
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
