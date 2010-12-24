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

package App::MathImage::Values::Polygonal;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 37;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Polygonal Numbers');
# use constant description => __('');

my @oeis = (undef, # 0
            undef, # 1
            undef, # 2
            'A000217', # 3 triangular
            'A000290', # 4 squares
            'A000326', # 5 pentagonal
            'A000384', # 6 hexagonal
            'A000566', # 7 heptagonal
            'A000567', # 8 octagonal
            'A001106', # 9 nonagonal
            'A001107', # 10 decogaonal
            'A051682', # 11 hendecagonal
            'A051624', # 12-gonal
            'A051865', # 13 tridecagonal
            'A051866', # 14-gonal
            'A051867', # 15
            'A051868', # 16
            'A051869', # 17
            'A051870', # 18
            'A051871', # 19
            'A051872', # 20
            'A051873', # 21
            'A051874', # 22
            'A051875', # 23
            'A051876', # 24
           );
sub oeis {
  my ($class_or_self) = @_;
  return $oeis[ref $class_or_self
               ? $class_or_self->{'k'}
               : 2];
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
  return bless { i => 0,
                 k => $options{'polygonal'} || 2,
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
  return 0.5 * $i * (($k-2)*$i - $k + 4);
}

# k=3  -1/2 + sqrt(2/1 * $n + 1/4)
# k=4         sqrt(2/2 * $n      )
# k=5   1/6 + sqrt(2/3 * $n + 1/36)
# k=6   2/8 + sqrt(2/4 * $n + 4/64)
# k=7  3/10 + sqrt(2/5 * $n + 9/100)
# k=8  4/12 + sqrt(2/6 * $n + 1/9)
sub pred {
  my ($self, $n) = @_;
  return ($n <= 0
          ? ($n == 0)
          : do {
            my $k = $self->{'k'};
            my $sqrt = (sqrt(8*($k-2) * $n + (4-$k)**2) + $k-4) / (2*($k-2));
            (int($sqrt) == $sqrt)
          });

}

1;
__END__
