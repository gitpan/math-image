# oeis starts at i=1 value=0



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

package App::MathImage::NumSeq::RepdigitAny;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 79;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Numbers which are a "repdigit" like 1111, 222, 999 etc of 3 or more digits in some number base.');
use constant i_start => 1;
use constant values_min => 1;
use constant characteristic_monotonic => 2;

# cf A167783 - in more than one base
#    A053696 - repunit in some base
#    A158235 - square is a repdigit in some base
#
use constant oeis_anum => 'A167782';

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'done'} = 0;
  @{$self->{'ba'}} = (undef, undef, 7);
  @{$self->{'dig'}} = (undef, undef, 1);
}

sub next {
  my ($self) = @_;
  my $done;
  if ($done = $self->{'done'}) {
    my $min = $done*$done + 7;
    my $ba = $self->{'ba'};
    my $dig = $self->{'dig'};

    ### bases: @$ba
    foreach my $base (2 .. $#$ba) {
      ### $base
      my $prod;
      while (($prod = $ba->[$base] * $dig->[$base]) <= $done) {
        ### increase past done: $prod
        if (++$dig->[$base] >= $base) {
          $dig->[$base] = 1;
          $ba->[$base] = $ba->[$base] * $base + 1;
          ### digit wrap: $ba->[$base]
        } else {
          ### digit step: $dig->[$base]
        }
      }
      ### $prod
      if ($prod < $min) {
        ### min now: "$prod at $base"
        $min = $prod;
      }
    }
    for (;;) {
      my $nextbase = scalar(@$ba);
      if ((my $n = ($nextbase + 1) * $nextbase + 1) <= $min) {
        ### nextbase min: "$n at $nextbase"
        $min = $ba->[$nextbase] = $n;  # extend
        $dig->[$nextbase] = 2;
      } else {
        last;
      }
    }
    ### result: $min
    $self->{'done'} = $min;
    return ($self->{'i'}++, $min);
  } else {
    $self->{'done'} = 1;
    return ($self->{'i'}++, 0);
  }
}

1;
__END__

# b^2 + b + 1 = k
# (b+0.5)^2 + .75 = k
# (b+0.5)^2 = (k-0.75)
# b = sqrt(k-0.75)-0.5;
#  1+int(sqrt($hi-0.75))) {
#
# sub new {
#   my ($class, %options) = @_;
#   my $lo = $options{'lo'} || 0;
#   my $hi = $options{'hi'};
# 
#   ### bases to: 2+int(sqrt($hi-0.75))
#   my %ret = (0 => 1); # zero considered 000...
#   foreach my $base (2 .. 1+int(sqrt($hi-0.75))) {
#     my $n = ($base + 1) * $base + 1;  # 111 in $base
#     while ($n <= $hi) {
#       $ret{$n} = 1;
#       foreach my $digit (2 .. $base-1) {
#         if ((my $mult = $digit * $n) <= $hi) {
#           $ret{$mult} = 1;
#         }
#       }
#       $n = $n * $base + 1;
#     }
#   }
#   return $class->SUPER::new (%options,
#                              array => [ sort {$a <=> $b} keys %ret ]);
# }

  #   require Math::Prime::XS;
  #   my @upto;
  #   my $i = 1;
  #   my @primes = Math::Prime::XS::sieve_primes ($maxbase);
  #   return sub {
  #     for (;;) {
  #       $i++;
  #       my $base_limit = 1+int(sqrt($i/2));
  #       foreach my $base (@primes) {
  #         last if ($base > $base_limit);
  #         foreach my $digit (@primes) {
  #           last if ($digit >= $base);
  #           my $ref = \$upto[$base]->[$digit];
  #           $$ref ||= (($base * $digit) + $digit) * $base + $digit;
  #           while ($$ref < $i) {
  #             $$ref = $$ref * $base + $digit;
  #           }
  #           if ($$ref == $i) {
  #             return $i;
  #           }
  #         }
  #       }
  #     }
  #   };
