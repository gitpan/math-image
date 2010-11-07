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

package App::MathImage::Values::Factorials;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesSparse';

use vars '$VERSION';
$VERSION = 29;

use constant name => __('Factorials');
use constant description => __('The factorials 1, 2, 6, 24, 120, etc, 1*2*...*N.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  return bless { %options,
                 i => 1,
                 f => 1,
               }, $class;
}
sub next {
  my ($self) = @_;
  return ($self->{'f'} *= $self->{'i'}++);
}

1;
__END__
