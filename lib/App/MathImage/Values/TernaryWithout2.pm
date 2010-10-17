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

package App::MathImage::Values::TernaryWithout2;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 26;

use constant name => __('Ternary without 2s');
use constant description => __('The integers without any 2 digits when written out in base 3.');

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
  ### TernaryWithout2 next(): $self->{'i'}+1
  my $i = ++$self->{'i'};
  my $digit = 1;
  my $x = $i;
  while ($x) {
    ### x mod 3: $x%3
    if (($x % 3) == 2) {
      ### add: $digit
      $i += $digit;
      $x++;
    }
    $x = int($x/3);
    $digit *= 3;
  }
  return (($self->{'i'} = $i),
          1);
}
sub pred {
  my ($self, $n) = @_;
  while ($n) {
    if (($n % 3) == 2) {
      return 0;
    }
    $n = int ($n / 3);
  }
  return 1;
}

1;
__END__
