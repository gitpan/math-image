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

package App::MathImage::NumSeq::Totient;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 68;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Totient function, the count of how many numbers coprime to N.');
use constant characteristic_count => 1;
use constant characteristic_smaller => 1;
use constant characteristic_monotonic => 0;
use constant values_min => 0;
use constant i_start => 1;

use constant oeis_anum => 'A000010';

sub ith {
  my ($self, $i) = @_;
  ### TotientSum ith(): $i
  return _totient_by_sieve($self,$i);
}
# sub pred {
#   my ($self, $value) = @_;
#   ### Totient pred(): $value
# }

sub _totient_by_sieve {
  my ($self, $i) = @_;
  ### _totient_by_sieve(): $i

  if ($i < 2) {
    return $i;
  }

  my $array = $self->{'array'};
  if (! $array || $i > $#$array) {
    $array = $self->{'array'} = [ 0 .. 2*$i ];
    $self->{'sieve_done'} = 1;
  }
  if ($self->{'sieve_done'} < $i) {
    ### extend past done: $self->{'sieve_done'}

    my $done = $self->{'sieve_done'};
    do {
      $done++;
      if ($array->[$done] == $done) {
        ### prime: $done
        for (my $m = $done; $m <= $#$array; $m += $done) {
          ### array change: $m.' from '.$array->[$m].' to '.($array->[$m] / $done) * ($done-1)
          ($array->[$m] /= $done) *= $done-1;
        }
      }
    } while ($done < $i);
    $self->{'sieve_done'} = $done;
    ### done now: $done
    ### array now: $array
  }
  my $ret = $self->{'array'}->[$i];
  return $ret - ($ret == $i);  # 1 less if a prime
}

# sub _totient {
#   my ($x) = @_;
#   my $count = (($x >= 1)                    # y=1 always
#                + ($x > 2 && ($x&1))         # y=2 if $x odd
#                + ($x > 3 && ($x % 3) != 0)  # y=3
#                + ($x > 4 && ($x&1))         # y=4 if $x odd
#               );
#   for (my $y = 5; $y < $x; $y++) {
#     $count += _coprime($x,$y);
#   }
#   return $count;
# }
# sub _coprime {
#   my ($x, $y) = @_;
#   #### _coprime(): "$x,$y"
#   if ($y > $x) {
#     return 0;
#   }
#   for (;;) {
#     if ($y <= 1) {
#       return ($y == 1);
#     }
#     ($x,$y) = ($y, $x % $y);
#   }
# }

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
