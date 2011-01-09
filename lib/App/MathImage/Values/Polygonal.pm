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

package App::MathImage::Values::Polygonal;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 40;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Polygonal Numbers');
# use constant description => __('');
use constant parameter_list => ({ name    => 'polygonal',
                                  display => __('Polygonal'),
                                  type    => 'integer',
                                  default => 5,
                                  minimum => 3,
                                  description => __('Which polygonal numbers to show.  3 is the triangular numbers, 4 the perfect squares, 5 the pentagonal numbers, etc.'),
                                },
                                App::MathImage::Values->parameter_common_pairs,
                               );

my @oeis = (undef, # 0
            undef, # 1
            undef, # 2
            { first  =>  'A000217' }, # 3 triangular
            { first  =>  'A000290' }, # 4 squares
            { first  => 'A000326',   # 5 pentagonal
              second => 'A005449',
              both   => 'A001318',
            },
            { first  => 'A000384',   # 6 hexagonal
              second => 'A014105',
              both   => '',
            },
            { first  => 'A000566' }, # 7 heptagonal
            { first  =>  'A000567' }, # 8 octagonal
            { first  =>  'A001106' }, # 9 nonagonal
            { first  =>  'A001107' }, # 10 decogaonal
            { first  =>  'A051682' }, # 11 hendecagonal
            { first  =>  'A051624' }, # 12-gonal
            { first  =>  'A051865' }, # 13 tridecagonal
            { first  =>  'A051866' }, # 14-gonal
            { first  =>  'A051867' }, # 15
            { first  =>  'A051868' }, # 16
            { first  =>  'A051869' }, # 17
            { first  =>  'A051870' }, # 18
            { first  =>  'A051871' }, # 19
            { first  =>  'A051872' }, # 20
            { first  =>  'A051873' }, # 21
            { first  =>  'A051874' }, # 22
            { first  =>  'A051875' }, # 23
            { first  =>  'A051876' }, # 24
           );
sub oeis {
  my ($class_or_self) = @_;
  my $k = (ref $class_or_self
           ? $class_or_self->{'k'}
           : $class_or_self->parameter_default('polygonal'));
  my $pairs = (ref $class_or_self
               ? $class_or_self->{'pairs'}
               : $class_or_self->parameter_default('pairs'));
  return $oeis[$k]->{$pairs};
}

# ($k-2)*$i*($i+1)/2 - ($k-3)*$i
# = ($k-2)/2*$i*i + ($k-2)/2*$i - ($k-3)*$i
# = ($k-2)/2*$i*i + ($k - 2 - 2*$k + 6)/2*$i
# = ($k-2)/2*$i*i + (-$k + 4)/2*$i
# = 0.5 * (($k-2)*$i*i + (-$k +4)*$i)
# = 0.5 * $i * (($k-2)*$i - $k + 4)

# 25*i*(i+1)/2 - 24i
# 25*i*(i+1)/2 - 48i/2
# i/2*(25*(i+1) - 48)
# i/2*(25*i + 25 - 48)
# i/2*(25*i - 23)
# 

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;

  my $k = $options{'polygonal'} || 2;
  my $add = - $k + 4;
  my $pairs = $options{'pairs'} || 'first';
  if ($k >= 5) {
    if ($pairs eq 'second') {
      $add = - $add;
    } elsif ($pairs eq 'both') {
      $add = - abs($add);
    }
  }
  return bless { pairs => $pairs,
                 k     => $k,
                 add   => $add,
                 i     => 0,
               }, $class;
}
sub next {
  my ($self) = @_;
  return $self->ith($self->{'i'}++);
}
sub ith {
  my ($self, $i) = @_;
  my $k = $self->{'k'};
  if ($k < 3) {
    if ($i == 0) {
      return 1;
    } else {
      return;
    }
  }
  if ($self->{'pairs'} eq 'both') {
    if ($i & 1) {
      $i = ($i+1)/2;
    } else {
      $i = -$i/2;
    }
  }
  ### $i
  return $i * (($k-2)*$i + $self->{'add'}) * 0.5;
}

# k=3  -1/2 + sqrt(2/1 * $n + 1/4)
# k=4         sqrt(2/2 * $n      )
# k=5   1/6 + sqrt(2/3 * $n + 1/36)
# k=6   2/8 + sqrt(2/4 * $n + 4/64)
# k=7  3/10 + sqrt(2/5 * $n + 9/100)
# k=8  4/12 + sqrt(2/6 * $n + 1/9)
sub pred {
  my ($self, $n) = @_;
  if ($n <= 0) {
    return ($n == 0);
  }
  my $k = $self->{'k'};
  my $sqrt = sqrt(8*($k-2) * $n + (4-$k)**2);
  if ($self->{'pairs'} eq 'both') {
    my $other = ($sqrt + $self->{'add'}) / (2*($k-2));
    if (int($other) == $other) {
      return 1;
    }
  }
  $sqrt = ($sqrt - $self->{'add'}) / (2*($k-2));
  return (int($sqrt) == $sqrt);

}

1;
__END__
