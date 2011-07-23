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

package App::MathImage::NumSeq::Lines;
use 5.004;
use strict;

use App::MathImage::NumSeq '__';
use base 'App::MathImage::NumSeq::All';

use vars '$VERSION';
$VERSION = 65;

use constant name => __('Lines');
use constant description => __('No numbers, instead lines showing the path taken.');
use constant parameter_list => ({ name    => 'increment',
                                  display => __('Increment'),
                                  type    => 'integer',
                                  default => 0,
                                  minimum => 0,
                                  width   => 3,
                                  description => __('An N increment between line segments.  0 means the default for the path.'),
                                },
                               );

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  return bless { i => $lo,
               }, $class;
}
sub next {
  my ($self) = @_;
  return $self->{'i'}++;
}
use constant pred => 1;

1;
__END__
