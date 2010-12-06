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

package App::MathImage::Values::FractionBits;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 36;

use constant name => __('Fraction Bits');
use constant description => __('A given fraction number written out in binary.');

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  ### $lo

  my $num = 0;  # 0/0 if unrecognised
  my $den = 0;
  ($num, $den) = ($options{'fraction'} =~ m{^\s*
                                            ([.[:digit:]]+)?
                                            \s*
                                            (?:/\s*
                                              ([.[:digit:]]+)?
                                            )?
                                            \s*$}x);
  if (! defined $num) { $num = 1; }
  if (! defined $den) { $den = 1; }
  ### $num
  ### $den

  my $num_decimals = 0;
  my $den_decimals = 0;
  if ($num =~ m{(\d*)\.(\d+)}) {
    $num = $1 . $2;
    $num_decimals = length($2);
  }
  if ($den =~ m{(\d*)\.(\d+)}) {
    $den = $1 . $2;
    $den_decimals = length($2);
  }
  $num .= '0' x max(0, $den_decimals - $num_decimals);
  $den .= '0' x max(0, $num_decimals - $den_decimals);

  while ($den != 0 && $num >= 2*$den) {
    $den *= 2;
  }
  while ($num && $num < $den) {
    $num *= 2;
  }

  ### create
  ### $num
  ### $den
  return bless { num => $num,
                 den => $den,
                 i   => 0,
               }, $class;
}
sub next {
  my ($self) = @_;

  my $num = $self->{'num'} || return;  # num==0 exact binary frac
  my $den = $self->{'den'} || return;  # den==0 invalid
  my $i = $self->{'i'};
  ### FractionBits next(): "$i  $num/$den"

  for (;;) {
    ### frac: "$num / $den"
    $i++;
    if ($num >= $den) {
      $self->{'num'} = ($num - $den) * 2;
      return ($self->{'i'} = $i);
    } else {
      $num *= 2;
    }
  }
}
# sub pred {
#   my ($self, $n) = @_;
#   return ($n & 1);
# }

1;
__END__

