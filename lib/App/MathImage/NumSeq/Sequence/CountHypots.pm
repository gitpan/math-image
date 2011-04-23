# Copyright 2011 Kevin Ryde

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

package App::MathImage::NumSeq::Sequence::CountHypots;
use 5.004;
use strict;
use POSIX 'floor', 'ceil';
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 52;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Count Hypotenuses');
use constant description => __('Count of how many ways a given N = A^2+B^2 occurs, for integer A,B >=0 (and no swaps, so B<=A).');
use constant type_hash => { count => 1 };
use constant values_min => 1;
use constant oeis_anum => 'A000161';

# sub new {
#   my ($class, %options) = @_;
#   my $lo = $options{'lo'} || 0;
#   my $hi = $options{'hi'};
#   $lo = max (0, $lo);
#   $hi = max (0, $hi);
# 
#   my $i = 0;
#   my $self = bless { i => $i,
#                    }, $class;
#   return $self;
# }

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub ith {
  my ($self, $i) = @_;
  ### CountHypots: $i

  my $count = 0;
  my $r = floor(sqrt($i));
  for (my $x = ceil(sqrt($i)/2); $x <= $r; $x++) {
    my $y = sqrt($i - $x*$x);
    $count += ($y <= $x && $y == int($y));
    ### add: "$x,$y  ".($y == int($y))
  }
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  ### CountHypots pred(): $value
  return ($value >= 0);
}

1;
__END__
