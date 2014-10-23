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

package App::MathImage::Iterator::Simple::Aronson;
use 5.004;
use strict;
use warnings;
use Math::Aronson;
use Iterator::Simple;

use vars '$VERSION';
$VERSION = 29;

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my $class = shift;
  my $it = Math::Aronson->new (@_);
  return Iterator::Simple::iterator (sub { $it->next });
}

1;
__END__
