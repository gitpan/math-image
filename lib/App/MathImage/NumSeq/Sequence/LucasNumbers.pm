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

package App::MathImage::NumSeq::Sequence::LucasNumbers;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sparse';

use vars '$VERSION';
$VERSION = 47;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Lucas Numbers');
use constant description => __('Lucas numbers 1, 3, 4, 7, 11, 18, 29, etc, being L(i) = L(i-1) + L(i-2) starting from 1,3.  This is the same recurrance as the Fibonacci numbers, but a different starting point.');
use constant values_min => 1;
use constant oeis => 'A000204';
# OeisCatalogue: A000204 # starting at 1,3,...

sub new {
  my ($class, %options) = @_;
  return $class->SUPER::new (%options,
                             f0 => 1,
                             f1 => 3);
}
sub next {
  my ($self) = @_;
  ### LucasNumbers next(): $self->{'i'}
  (my $ret, $self->{'f0'}, $self->{'f1'})
   = ($self->{'f0'}, $self->{'f1'}, $self->{'f0'}+$self->{'f1'});
  return $ret;
}
# sub pred {
#   my ($self, $n) = @_;
#   return (($n >= 0)
#           && do {
#             $n = sqrt($n);
#             $n == int($n)
#           });
# }

1;
__END__
