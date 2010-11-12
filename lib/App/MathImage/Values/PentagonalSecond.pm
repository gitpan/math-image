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

package App::MathImage::Values::PentagonalSecond;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 30;

use constant name => __('Pentagonal Numbers, second type');
use constant description => __('The pentagonal numbers 2,7,15,26, etc, (3k+1)*k/2.  The formula is the same as the plain pentagonal numbers, but taking negative k.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => 0
               }, $class;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return (3*$i+1)*$i/2;
}
# sub pred {
#   my ($self, $n) = @_;
#   return ($n & 1);
# }

1;
__END__
