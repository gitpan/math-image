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

package App::MathImage::Values::ObstinateNumbers;
use 5.004;
use strict;
use warnings;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';
use App::MathImage::ValuesFile;
use App::MathImage::ValuesFileWriter;

use vars '$VERSION';
$VERSION = 28;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Obstinate Numbers');
use constant description => __('Odd numbers N not representable as prime+2^k.');

# each 2-bit vec() value is
#    bit 01 = 1 prime
#    bit 10 = 2 obstinate

sub new {
  my ($class, %options) = @_;
  ### ObstinateNumbers new()

  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  $lo = max (0, $lo);
  $hi = max (0, $hi);

  if (my $vf = App::MathImage::ValuesFile->new (package => __PACKAGE__,
                                                hi => $hi)) {
    ### use ValuesFile: $vf
    return $vf;
  }

  my $i = 1;
  my $vfw = App::MathImage::ValuesFileWriter->new
    (package => __PACKAGE__,
     hi      => $hi);

  my $self = bless { i  => $i,
                     hi => $hi,
                     vfw => $vfw,
                   }, $class;
  $self->{'string'} = "\377" x (($hi+1)/4);  # 4 of 2 bits each
  vec($self->{'string'}, 0,2) = 0;  # not prime, not obstinate
  vec($self->{'string'}, 1,2) = 0;  # not prime, not obstinate
  vec($self->{'string'}, 2,2) = 0;  # not prime, not obstinate
  vec($self->{'string'}, 3,2) = 1;  # is prime, not obstinate

  while ($i < $lo-2) {
    $self->next;
  }
  return $self;
}

sub next {
  my ($self) = @_;
  ### ObstinateNumbers next(): $self->{'i'}

  my $hi = $self->{'hi'};
  my $sref = \$self->{'string'};

  for (;;) {
    my $i = ($self->{'i'} += 2);
    if ($i > $hi) {
      $self->{'vfw'}->done;
      return;
    }

    my $ret = vec($$sref, $i,2);
    if ($ret & 1) {
      ### prime: $i
      for (my $power = 2; $power <= $hi; $power <<= 1) {
      ### not: $i+$power
        vec($$sref, $i+$power,2) &= 1; # not obstinate
      }
      for (my $j = $i; $j <= $hi; $j += $i) {
        vec($$sref, $j,2) &= 2; # not prime
      }
      # print "applied: $i\n";
      # for (my $j = 0; $j < $hi; $j++) {
      #   printf "  %2d %2d\n", $j, ($prods->[$j]||0);
      # }
    }
    if ($ret & 2) {
      ### obstinate: $i
      $self->{'vfw'}->write_n($i);
      return $i;
    }
  }
}

sub pred {
  my ($self, $n) = @_;
  ### ObstinateNumbers pred(): $n
  ### $self
  ### vec: vec($self->{'string'}, $n,2)
  ### obstinate: (vec($self->{'string'}, $n,2) & 2)
  while ($self->{'i'} <= $n) {
    $self->next or last;
  }
  return ($n >= 0
          && ($n & 1)
          && $n <= $self->{'hi'}
          && (vec($self->{'string'}, $n,2) & 2));
}

sub finish {
  my ($self) = @_;
  while (defined ($self->next)) { }
}

1;
__END__
