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


package App::MathImage::Image::Base::Other;
use strict;
use warnings;

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 30;

sub _save_to_tempfh {
  my ($image) = @_;
  require File::Temp;
  my $tempfh = File::Temp->new;
  my $old_filename = $image->get('-file');
  # Image::Xpm doesn't like -file => undef
  if (! defined $old_filename) { $old_filename = ''; }
  require Scope::Guard;
  my $guard = Scope::Guard->new (sub { $image->set (-file => $old_filename) });
  $image->save($tempfh->filename);
  return $tempfh;
}

sub save_fh {
  my ($image, $fh) = @_;
  require File::Copy;
  my $tempfh = _save_to_tempfh ($image);
  File::Copy::copy ($tempfh, $fh);
}

sub save_string {
  my ($image) = @_;
  my $tempfh = _save_to_tempfh ($image);
  return do { local $/; <$tempfh> }; # slurp
}


sub _load_from_tempfh {
  my ($image, $tempfh) = @_;
  my $old_filename = $image->get('-file');
  my $guard = Scope::Guard->new (sub { $image->set (-file => $old_filename) });
  $image->load ($tempfh->filename);
}

sub load_fh {
  my ($image, $fh) = @_;
  require File::Copy;
  require File::Temp;
  my $tempfh = File::Temp->new;
  File::Copy::copy ($fh, $tempfh);
  return _load_from_tempfh ($image, $tempfh);
}

sub load_string {
  my ($image, $str) = @_;
  require File::Temp;
  my $tempfh = File::Temp->new;
  (print $tempfh $str
   and close $tempfh) or die;
  return _load_from_tempfh ($image, $tempfh);
}


sub xy_points {
  my ($image) = @_;
  if (my $coderef = $image->can('Image_Base_Other_xy_points')) {
    goto &$coderef;
  }
  shift;  # $image
  my $colour = shift;
  ### points: @_
  while (@_) {
    $image->xy (shift, shift, $colour);
  }
}

sub rectangles {
  my ($image) = @_;
    ### Other rectangles()
  if (my $coderef = $image->can('Image_Base_Other_rectangles')) {
    ### goto: $coderef
    goto &$coderef;
  }
    ### iterate
  shift;  # $image
  my $colour = shift;
  my $fill = shift;
  ### rectangles: @_
  while (@_) {
    $image->rectangle (shift,shift,shift,shift, $colour, $fill);
  }
}

sub diamond {
  my ($self, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  my $w = int (($x2 - $x1) / 2);
  my $h = int (($y2 - $y1) / 2);
  ### $w
  ### $h
  ### x1+w: $x1+$w
  ### x2-w: $x2-$w
  ### y1+h: $y1+$h
  ### y2-h: $y2-$h

  my $x = $w;
  my $rem = - int($h/2);
  for (my $y = 0; $y <= $h; $y++) {
    ### $x
    ### $y
    ### $rem
    ### hline: ($x1+$x)." to ".($x2-$x)
    if ($fill) {
      $self->line ($x1+$x,$y1+$y, $x2-$x,$y1+$y, $colour); # upper
      $self->line ($x1+$x,$y2-$y, $x2-$x,$y2-$y, $colour); # lower
    } else {
      $self->xy ($x1+$x,$y1+$y, $colour); # upper left
      $self->xy ($x2-$x,$y1+$y, $colour); # upper right

      $self->xy ($x1+$x,$y2-$y, $colour); # lower left
      $self->xy ($x2-$x,$y2-$y, $colour); # lower right
    }
    if (($rem += $w) > 0) {
      do {
        $rem -= $h;
        $x--;
      } while ($rem > 0);
    }
  }
  # if ($fill) {
  # } else {
  #   $self->line ($x1,$y1+$h, $x1+$w,$y1, 'a'); # top left
  #   $self->line ($x2-$w,$y1, $x2,$y1+$h, 'b'); # top right
  #
  #   $self->line ($x1,$y2-$h, $x1+$w,$y2, 'x'); # bottom left
  #   $self->line ($x2-$w,$y2, $x2,$y2-$h, 'y'); # bottom right
  # }
}

1;
