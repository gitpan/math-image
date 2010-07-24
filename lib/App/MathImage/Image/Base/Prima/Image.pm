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


package App::MathImage::Image::Base::Prima::Image;
use 5.004;
use strict;
use warnings;
use Carp;
use base 'App::MathImage::Image::Base::Prima::Drawable';

# uncomment this to run the ### lines
#use Smart::Comments '###';

use vars '$VERSION';
$VERSION = 12;

sub load {
  my ($self, $filename) = @_;
  ### Prima-Drawable load()
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  ### $filename

  $self->{'-drawable'}->load ($filename);
}

sub save {
  my ($self, $filename) = @_;
  ### Prima-Drawable save(): @_
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename

  $self->{'-drawable'}->save ($filename);
}

1;
__END__
