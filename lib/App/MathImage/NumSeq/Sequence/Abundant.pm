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

package App::MathImage::NumSeq::Sequence::Abundant;
use 5.004;
use strict;
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 62;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Abundant Numbers');
use constant description => __('Numbers N with sum of its divisors >= N, eg. 12 is divisible by 1,2,3,4,6 total 16 is >= 12.');
use constant values_min => 12;

use constant oeis_anum => 'A005101';

# cf
# A005100 deficient numbers sigma(n) < 2*n
# A000396 perfect sigma(n) == 2*n
#
# A091191 primitive abundants (no abundant divisor)
# A091192 non-primitives (at least one abundant divisor)

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max (0, $lo);
  $hi = max (0, $hi);

  my $i = 1;
  my @prods;
  $#prods = $hi; # pre-extend
  $prods[0] = 1; # not abundant
  $prods[1] = 1;
  my $self = bless { i => $i,
                     prods => \@prods,
                     hi     => $hi,
                   }, $class;
  while ($i < $lo-1) {
    $self->next;
  }
  return $self;
}
sub rewind {
  my ($self) = @_;
  $self->{'ith'} = 0;
}
sub next {
  my ($self) = @_;
  ### Abundant next(): $self->{'i'}

  my $hi = $self->{'hi'};
  my $prods = $self->{'prods'};

  for (;;) {
    my $i = $self->{'i'}++;
    if ($i > $hi) {
      return;
    }
    if (defined $prods->[$i]) {
      ### composite: $i, $prods->[$i]
      if ($prods->[$i] > 2*$i) {
        $prods->[$i] = 1;
        return ($self->{'ith'}++, $i);
      }
      if ($] >= 5.006) {
        delete $prods->[$i];
      } else {
        undef $prods->[$i];
      }
    } else {
      ### prime: $i
      my $prev = 1;
      for (my $power = 1; ; $power++) {
        my $step = $i ** $power;
        last if ($step > $hi);
        my $this = $prev + $step;
        ### $power
        ### $step
        ### $prev
        ### $this
        for (my $j = $step; $j <= $hi; $j += $step) {
          ### $j
          ### before: $prods->[$j]
          $prods->[$j] = ($prods->[$j]||1) / $prev * $this;
          ### after: $prods->[$j]
        }
        $prev = $this;
      }
      # print "applied: $i\n";
      # for (my $j = 0; $j < $hi; $j++) {
      #   printf "  %2d %2d\n", $j, ($prods->[$j]||0);
      # }
    }
  }
}

sub pred {
  my ($self, $n) = @_;
  ### Abundant pred(): $n
  if ($n > $self->{'hi'} || $n <= 0) {
    return 0;
  }
  while ($self->{'i'} <= $n) {
    $self->next;
  }
  # ### $self
  ### mod 12: $n % 12
  ### prods: $self->{'prods'}->[$n]
  ### pred result: ($self->{'prods'}->[$n] && $self->{'prods'}->[$n] > 2*$n)
  return (($self->{'prods'}->[$n]||0) == 1);
}

1;
__END__
