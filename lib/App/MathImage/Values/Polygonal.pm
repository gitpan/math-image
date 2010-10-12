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

package App::MathImage::Values::Polygonal;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 25;

use constant name => __('Polygonal Numbers');
# use constant description => __('');

# uncomment this to run the ### lines
#use Smart::Comments;


# ($k-2)*$i*($i+1)/2 - ($k-3)*$i
# = ($k-2)/2*$i*i + ($k-2)/2*$i - ($k-3)*$i
# = ($k-2)/2*$i*i + ($k - 2 - 2*$k + 6)/2*$i
# = ($k-2)/2*$i*i + (-$k + 4)/2*$i
# = 0.5 * (($k-2)*$i*i + (-$k +4)*$i)
# = 0.5 * $i * (($k-2)*$i - $k + 4)

# 25*i*(i+1)/2 - 24i
# 25*i*(i+1)/2 - 48i/2
# i/2*(25*(i+1) - 48)
# i/2*(25*i + 25 - 48)
# i/2*(25*i - 23)
# 

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => 0,
                 k => $options{'polygonal'},
               }, $class;
}
sub next {
  my ($self) = @_;
  my $k = $self->{'k'};
  my $i = $self->{'i'}++;
  if ($k < 3) {
    if ($i == 0) {
      return (1, 1);
    } else {
      return;
    }
  }
  return (0.5 * $i * (($k-2)*$i - $k + 4),
          1);
}
sub pred {
  my ($self, $n) = @_;
  return ($n & 1);
}

1;
__END__
