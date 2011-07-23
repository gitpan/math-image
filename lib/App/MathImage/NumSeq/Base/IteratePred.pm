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

package App::MathImage::NumSeq::Base::IteratePred;
use 5.004;
use strict;

use vars '$VERSION';
$VERSION = 65;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'value'} = 0;
}
sub next {
  my ($self) = @_;
  my $value = $self->{'value'};
  for (;;) {
    if ($self->pred(++$value)) {
      return ($self->{'i'}++, ($self->{'value'} = $value));
    }
  }
}
# sub ith {
#   my ($self, $i) = @_;
#   $i -= $self->i_start;
#   my $value = $self->value_min - 1;
#   while ($i >= 0) {
#     $value++;
#     if ($self->pred($value)) {
#       $i--;
#     }
#   }
#   return $value;    
# }

1;
__END__
