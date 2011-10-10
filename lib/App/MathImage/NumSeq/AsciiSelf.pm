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

# math-image --values=AsciiSelf

package App::MathImage::NumSeq::AsciiSelf;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 76;

use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant description => Math::NumSeq::__('Self in ASCII.');
use constant characteristic_monotonic => 1;
use constant i_start => 1;
use constant values_min => 48;
sub values_max {
  my ($self) = @_;
  return 47 + $self->{'radix'};
}

use Math::NumSeq::Base::Digits;
*parameter_info_array = \&Math::NumSeq::Base::Digits::parameter_info_array;

# cf A109648 ascii with comma and space
#
my @oeis_anum;
$oeis_anum[10] = 'A109733';
# OEIS-Catalogue: A109733
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'radix'}];
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  undef $self->{'pending'};

  my $radix = $self->{'radix'};
  my $initial;
  foreach my $i (48 .. 47+$radix) {
    my $r = $self->{'map'}->[$i] = [ _radix_ascii($radix,$i) ];
    if ($r->[0] == $i) {
      $initial ||= $r;
    }
  }
  $self->{'pending'} = [@{$initial||[48]}];
  ### $self
}

sub next {
  my ($self) = @_;
  ### AsciiSelf next(): "$self->{'i'}"

  my $pending = $self->{'pending'};
  my $ret = shift @$pending;
  if ($self->{'i'} > 1) {
    push @$pending, @{$self->{'map'}->[$ret]};
  }

  ### $ret
  ### now pending: @$pending
  return ($self->{'i'}++, $ret);
}

sub _radix_ascii {
  my ($radix, $n) = @_;
  my @digits;
  while ($n) {
    push @digits, ($n % $radix) + 48;
    $n = int($n/$radix);
  }
  return reverse @digits;
}

1;
__END__
