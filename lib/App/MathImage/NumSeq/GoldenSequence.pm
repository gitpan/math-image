# Copyright 2010, 2011 Kevin Ryde

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


# vogel 1/1.6 arc

package App::MathImage::NumSeq::GoldenSequence;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 79;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant values_min => 0;
use constant values_max => 1;
# use constant characteristic_boolean => 1;
# use constant description => Math::NumSeq::__('');

# cf A096270 expressed as 01 and 011
#    A114986
#    A003622, A076662 - positions of 1s
#    A076662
#    A005614 inverse, starting from 1
#    A014675 with values 1/2 instead of 0/1
#    A003842, A008352 values 1/2 inverse
#    A178482 Golden Patterns Phi-antipalindromic
#    A036299
#    A001468
use constant oeis_anum => 'A003849';  # 0/1 values

sub ith {
  my ($self, $i) = @_;
  my $f0 = ($i * 0) + 1;  # inherit bignum 1
  my $f1 = $f0 + 1;       # inherit bignum 2
  my $level = 0;
  while ($i > $f1) {
    ($f1,$f0) = ($f1+$f0,$f1);
    $level++;
  }
  ### above: "$f1,$f0  level=$level"

  do {
    ### at: "$f1,$f0  i=$i"
    if ($i >= $f1) {
      $i -= $f1;
    }
    ($f1,$f0) = ($f0,$f1-$f0);
  } while ($level--);

  ### ret: $i
  return $i;
}

sub pred {
  my ($self, $value) = @_;
  return ($value == 0 || $value == 1);
}

1;
__END__

# Local variables:
# compile-command: "math-image --values=GoldenSequence"
# End:
