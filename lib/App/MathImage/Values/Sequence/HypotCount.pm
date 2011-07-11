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

package App::MathImage::Values::Sequence::HypotCount;
use 5.004;
use strict;
use POSIX 'floor', 'ceil';
use List::Util 'min', 'max';

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';

use vars '$VERSION';
$VERSION = 63;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Count Hypotenuses');
use constant description => __('Count of how many ways a given N = A^2+B^2 occurs, for integer A,B >=0 (and no swaps, so B<=A).');
use constant characteristic_count => 1;
use constant values_min => 1;
use constant oeis_anum => 'A000161';

# sub new {
#   my ($class, %options) = @_;
#   ### HypotCount new()
# 
#   $options{'lo'} = max (0, $options{'lo'}||0);
#   my $hi = $options{'hi'} = max (0, $options{'hi'});
# 
#   my $str = "\0\0\0\0" x ($options{'hi'}+1);
#   for (my $j = 2; $j <= $hi; $j += 2) {
#     vec($str, $j,8) = 2*1-1;
#   }
#   return $class->SUPER::new (%options,
#                              string => $str);
# }
# 
# sub rewind {
#   my ($self) = @_;
#   ### HypotCount rewind()
#   $self->{'i'} = 0;
#   while ($self->{'i'} < $self->{'lo'}-1) {
#     $self->next;
#   }
# }
# 
# sub next {
#   my ($self) = @_;
#   ### HypotCount next() from: $self->{'i'}
# 
#   my $i = $self->{'i'}++;
#   my $hi = $self->{'hi'};
#   if ($i > $hi) {
#     return;
#   }
#   my $cref = \$self->{'string'};
# 
#   my $ret = vec ($$cref, $i,8);
#   if ($ret == 0 && $i >= 3 && ($i&3) == 1) {
#     ### prime 4k+1: $i
#     $ret = 1;
#     for (my $j = $i; $j <= $hi; $j += $i) {
#       vec($$cref, $j,8) ++;
#     }
# 
#     # print "applied: $i\n";
#     # for (my $j = 0; $j < $hi; $j++) {
#     #   printf "  %2d %2d\n", $j, vec($$cref, $j,8);
#     # }
#   }
#   return ($i, $ret);
# }
# 
# sub pred {
#   my ($self, $n) = @_;
#   ### HypotCount pred(): $n
#   return 1;
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
  ### HypotCount: $i

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
  ### HypotCount pred(): $value
  return ($value >= 0);
}

1;
__END__
