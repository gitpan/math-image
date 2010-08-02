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


package App::MathImage::Image::Base::X::Pixmap;
use strict;
use warnings;
use Carp;
use base 'App::MathImage::Image::Base::X::Drawable';

use vars '$VERSION';
$VERSION = 13;

sub new {
  my ($class, %params) = @_;
  ### X-Pixmap new: \%params

  if (my $win = $params{'-pixmap'}) {
    $params{'-drawable'} = delete $params{'-pixmap'};
  }
  if (! exists $params{'-drawable'}) {
    my $display = $params{'-display'};
    my $for_drawable = (delete $params{'-for_window'}
                        || delete $params{'-for_pixmap'});
    $params{'-drawable'} = X::CreatePixmap ($params{'-display'},
                                          $for_drawable,
                                          $params{'-width'},
                                          $params{'-height'},
                                          $params{'-depth'});
  }
  return $class->SUPER::new (%params);
}

sub DESTROY {
  my ($self) = @_;
  if (my $gc = delete $self->{'-gc_created'}) {
    $self->{'-X'}->FreeGC ($gc);
  }
}

1;
