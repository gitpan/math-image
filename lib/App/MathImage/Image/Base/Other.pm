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


package App::MathImage::Image::Base::Other;
use strict;

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 50;

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

# draw a + shape in the rectangle top-left x1,y1, bottom-right x2,y2
sub plus {
  my ($image, $x1,$y1, $x2,$y2, $colour) = @_;
  {
    my $xmid = int(($x1+$x2)/2);
    $image->line ($xmid,$y1, $xmid,$y2, $colour);
  }
  {
    my $ymid = int(($y1+$y2)/2);
    $image->line ($x1,$ymid, $x2,$ymid, $colour);
  }
}

# draw an X in the rectangle top-left x1,y1, bottom-right x2,y2
sub draw_X {
  my ($image, $x1,$y1, $x2,$y2, $colour) = @_;
  $image->line ($x1,$y1, $x2,$y2, $colour);
  $image->line ($x2,$y1, $x1,$y2, $colour);
}

# draw an L in the rectangle top-left x1,y1, bottom-right x2,y2,
# meaning simply the left and bottom edges
sub draw_L {
  my ($image, $x1,$y1, $x2,$y2, $colour) = @_;
  if ($y1 != $y2) {
    $image->line ($x1,$y1, $x1,$y2-1, $colour);  # left
  }
  $image->line ($x1,$y2, $x2,$y2, $colour);  # bottom
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
  ### diamond(): "$x1,$y1, $x2,$y2, $colour fill=".($fill||0)
  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }

  my $a = $x2 - $x1;
  my $b = $y2 - $y1;
  if ($a < 2 || $b < 2) {
    $self->rectangle ($x1,$y1, $x2,$y2, $colour, 1);
    return;
  }
  $a = int ($a / 2);
  $b = int ($b / 2);
  ### $a
  ### $b
  ### x1+a: $x1+$a
  ### x2-a: $x2-$a
  ### y1+b: $y1+$b
  ### y2-b: $y2-$b

  my $x = $a;
  my $y = 0;

  my $whole = int ($a / $b);
  $a -= $whole * $b;
  ### $whole
  ### $a
  ### $b

  my $rem = - int(($b+1)/2);
  if ($fill) {
    my $quad = sub {
      ### fill: "x=$x y=$y   x ".($x1+$x).' to '.($x2-$x).' y='.($y1+$y)
      $self->line ($x1+$x,$y1+$y, $x2-$x,$y1+$y, $colour); # upper
      $self->line ($x1+$x,$y2-$y, $x2-$x,$y2-$y, $colour); # lower
    };

    while ($y <= $b) {
      ### $x
      ### $y
      ### $rem

      &$quad ();
      $x -= $whole;
      if (($rem += $a) > 0) {
        $rem -= $b;
        $x--;
      }
      $y++;
    }

  } else {
    my $quad = sub {
      ### points: ($x1+$x).','.($y1+$y)
      $self->xy ($x1+$x,$y1+$y, $colour); # upper left
      $self->xy ($x2-$x,$y1+$y, $colour); # upper right

      $self->xy ($x1+$x,$y2-$y, $colour); # lower left
      $self->xy ($x2-$x,$y2-$y, $colour); # lower right
    };

    while ($y <= $b) {
      ### $x
      ### $y
      ### $rem
      for (my $i = $whole; $i > 0; $i--) {
        &$quad ();
        $x--;
      }
      if (($rem += $a) > 0) {
        $rem -= $b;
        &$quad ();
        $x--;
      }
      $y++;
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
__END__
