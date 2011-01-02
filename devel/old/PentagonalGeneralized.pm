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

package App::MathImage::Values::PentagonalGeneralized;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 38;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Pentagonal Numbers, generalized');
use constant description => __('The generalized pentagonal numbers 1, 2, 5, 7, 15, 22, 22, 26, etc, (3k-1)*k/2 for k positive and negative.  This is the plain pentagonal and second pentagonals taken together.');
use constant oeis => 'A001318';

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => 0,
                 neg => 1,
               }, $class;
}
sub next {
  my ($self) = @_;
  if ($self->{'neg'} ^= 1) {
    my $i = $self->{'i'};
    return (3*-$i+1)*-$i/2;
  } else {
    my $i = $self->{'i'}++;
    return (3*$i+1)*$i/2;
  }
}
# sub pred {
#   my ($self, $n) = @_;
#   return ($n & 1);
# }

1;
__END__
