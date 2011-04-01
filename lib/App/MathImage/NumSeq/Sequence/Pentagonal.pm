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

package App::MathImage::NumSeq::Sequence::Pentagonal;
use 5.004;
use strict;
use warnings;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence::Polygonal';

use vars '$VERSION';
$VERSION = 51;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Pentagonal Numbers');
use constant description => __('The pentagonal numbers 1,5,12,22,etc, (3k-1)*k/2.');
use constant values_min => 1;
use constant parameter_list => (App::MathImage::NumSeq::Sequence->parameter_common_pairs);

sub new {
  my $class = shift;
  return $class->SUPER::new (@_,
                             polygonal => 5);
  # , %options) = @_;
  #   my $lo = $options{'lo'} || 0;
  #   my $pairs = $options{'pairs'} || 'first';
  #   if ($pairs eq 'second') {
  #     $add = - $add;
  #   }
  #   return bless { i => 0,
  #
  #                }, $class;
}
# sub next {
#   my ($self) = @_;
#   return $self->ith($self->{'i'}++);
# }
# sub ith {
#   my ($class_or_self, $i) = @_;
#   return (3*$i-1)*$i/2;
# }
# 
# # i = 1/6 + sqrt(2/3 * $n + 1/36)
# #   = 1/6 * (1 + 6*sqrt(2/3 * $n + 1/36))
# #   = 1/6 * (1 + sqrt(36 * (2/3 * $n + 1/36)))
# #   = 1/6 * (1 + sqrt(24*$n + 1)))
# #
# sub pred {
#   my ($self, $n) = @_;
#   return ($n <= 0
#           ? ($n == 0)
#           : do {
#             my $sqrt = (sqrt(24*$n+1) + 1) / 6;
#             (int($sqrt) == $sqrt)
#           });
# }


1;
__END__
