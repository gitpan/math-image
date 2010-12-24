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

package App::MathImage::Values::AbundantNumbers;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 37;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Abundant Numbers');
use constant description => __('Numbers N with sum of its divisors >= N, eg. 12 is divisible by 1,2,3,4,6 total 16 is >= 12.');
use constant oeis => 'A005101';

# A005100 deficient numbers sigma(n) < 2*n
# A000396 perfect sigma(n) == 2*n

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
sub next {
  my ($self) = @_;
  ### AbundantNumbers next(): $self->{'i'}

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
        return $i;
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
  ### AbundantNumbers pred(): $n
  if ($self->{'i'} <= $n) {
    ### extend from: $self->{'i'}
    my $i;
    while (($i = $self->next) && $i < $n) { }
  }
  return ($n >= 0 && $self->{'prods'}->[$n]);
}

1;
__END__
