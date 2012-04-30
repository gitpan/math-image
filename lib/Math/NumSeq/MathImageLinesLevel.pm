# Copyright 2010, 2011, 2012 Kevin Ryde

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

package Math::NumSeq::MathImageLinesLevel;
use 5.004;
use strict;
use Locale::TextDomain 'App-MathImage';

use vars '$VERSION','@ISA';
$VERSION = 97;
use Math::NumSeq::All;
@ISA = ('Math::NumSeq::All');

use constant name => __('Line by Level');
use constant description => __('No numbers, instead lines showing the path taken.');
use constant parameter_info_array =>
  [ { name    => 'level',
      display => __('Level'),
      type    => 'integer',
      minimum => 1,
      maximum => 999,
      default => 3,
      # description => __('.'),
    } ];

1;
__END__
