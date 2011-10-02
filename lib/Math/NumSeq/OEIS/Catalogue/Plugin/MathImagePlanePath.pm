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

package Math::NumSeq::OEIS::Catalogue::Plugin::MathImagePlanePath;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 74;
use Math::NumSeq::OEIS::Catalogue::Plugin;
@ISA = ('Math::NumSeq::OEIS::Catalogue::Plugin');

use constant info_arrayref =>
  [
   {
    anum  => 'A059252',
    class => 'App::MathImage::NumSeq::PlanePath',
    parameters => [ planepath => 'HilbertCurve',
                    coord_type => 'Y' ],
   },
   {
    anum  => 'A059253',
    class => 'App::MathImage::NumSeq::PlanePath',
    parameters => [ planepath => 'HilbertCurve',
                    coord_type => 'X' ],
   },
   {
    anum  => 'A163538',
    class => 'App::MathImage::NumSeq::PlanePath',
    parameters => [ planepath => 'HilbertCurve',
                    coord_type => 'dY' ],
   },
   {
    anum  => 'A163539',
    class => 'App::MathImage::NumSeq::PlanePath',
    parameters => [ planepath => 'HilbertCurve',
                    coord_type => 'dX' ],
   },
  ];

1;
__END__
