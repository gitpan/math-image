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

package App::MathImage::Values::Base4Without3;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 26;

use constant name => __('Base 4 Without 3');
use constant description => __('The integers without any 3 digits when written out in base 4.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => -1,
               }, $class;
}
sub next {
  my ($self) = @_;
  my $i = ++$self->{'i'};
  my $mask = 3;
  while ($mask <= $i) {
    if (($i & $mask) == $mask) {
      $i += $mask/3;
    }
    $mask <<= 2;
  }
  return (($self->{'i'} = $i),
          1);
}
sub pred {
  my ($self, $n) = @_;
  while ($n) {
    if (($n & 3) == 3) {
      return 0;
    }
    $n >>= 2;
  }
  return 1;
}

1;
__END__
