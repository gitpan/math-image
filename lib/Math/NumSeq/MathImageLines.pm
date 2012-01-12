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

package Math::NumSeq::MathImageLines;
use 5.004;
use strict;
use Locale::TextDomain 'App-MathImage';

# uncomment this to run the ### lines
#use Smart::Comments;


use vars '$VERSION','@ISA';
$VERSION = 90;
use Math::NumSeq::All;
@ISA = ('Math::NumSeq::All');

use constant description => __('No numbers, instead lines showing the path taken.');
use constant parameter_info_array =>
  [ { name    => 'increment',
      display => __('Increment'),
      type    => 'integer',
      default => 0,
      minimum => 0,
      width   => 3,
      description => __('An N increment between line segments.  0 means the default for the path.'),
    },
    { name    => 'lines_type',
      type    => 'enum',
      default => 'integer',
      choices => ['integer','midpoint'],
    },
    { name        => 'midpoint_offset',
      type        => 'float',
      default     => 0.5,
      decimals    => 1,
      minimum     => 0,
      maximum     => 1.00,
      when_name   => 'lines_type',
      when_value  => 'midpoint',
    },
  ];

1;
__END__
