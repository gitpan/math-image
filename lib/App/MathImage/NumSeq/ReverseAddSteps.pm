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

package App::MathImage::NumSeq::ReverseAddSteps;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use App::MathImage::NumSeq '__';
use base 'App::MathImage::NumSeq';
use App::MathImage::NumSeq::Base::Digits;

use vars '$VERSION';
$VERSION = 65;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Reverse Add Steps');
use constant description => __('How many steps of reverse and add until a palindrome, also called the 196-algorithm.');
use constant characteristic_count => 1;
use constant values_min => 0;
use constant i_start => 0;
use constant parameter_list => (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

my @oeis;
$oeis[10] = 'A030547';
sub oeis_anum {
  my ($self) = @_;
  return $oeis[$self->{'radix'}];
}
# OEIS-Catalogue: A030547 radix=10

sub rewind {
  my ($self) = @_;
  require Math::BigInt;
  Math::BigInt->import (try => 'GMP');
  $self->{'i'} = max(0,$self->{'lo'});
}
sub next {
  my ($self) = @_;
  ### ReverseAddSteps next(): $self->{'i'}
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}
sub pred {
  my ($class_or_self, $value) = @_;
  return ($value >= 0);
}
sub ith {
  my ($self, $k) = @_;
  ### ReverseAddSteps ith(): $k
  my $radix = $self->{'radix'};

  # $k = Math::BigInt->new($k);
  my $count = 1;
 OUTER: for ( ; $count < 30; $count++) {
    my @digits;
    ### $count
    ### k: "$k"

    if (ref $k) {
      my $d = $k->copy;
      while ($d) {
        push @digits, $d % $radix;
        $d->bdiv($radix);
      }
      ### big digits: join(',',@digits)

      for my $i (0 .. int(@digits/2)-1) {
        if ($digits[$i] != $digits[-1-$i]) {
          ### not a palindrome ...

          foreach my $i (0 .. $#digits) {
            $d->bmul($radix);
            $d->badd($digits[$i]);
          }
          ### k: "$k"
          ### d: "$d"
          $k += $d;
          ### sum now: "$k"
          next OUTER;
        }
      }
    } else {
      my $d = $k;
      while ($d) {
        push @digits, $d % $radix;
        $d = int($d/$radix);
      }
      ### small digits: join(',',@digits)

      for my $i (0 .. int(@digits/2)-1) {
        if ($digits[$i] != $digits[-1-$i]) {
          ### not a palindrome ...

          if (@digits >= 10) {
            $d = Math::BigInt->bzero;
          }
          foreach my $i (0 .. $#digits) {
            $d *= $radix;
            $d += $digits[$i];
          }
          ### k: "$k"
          ### d: "$d"
          $k += $d;
          ### sum now: "$k"
          next OUTER;
        }
      }
    }
    # palindrome
    last;
  }
  return $count;
}

1;
__END__
