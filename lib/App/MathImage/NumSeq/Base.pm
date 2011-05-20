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

package App::MathImage::NumSeq::Base;
use 5.006;
use strict;
use warnings;

use vars '@ISA', '@EXPORT_OK';
use Exporter;
@ISA = ('Exporter');
@EXPORT_OK = ('__');

use vars '$VERSION';
$VERSION = 57;

BEGIN {
  eval <<'HERE'
require Locale::Messages;
sub __ { Locale::Messages::dgettext('App-MathImage',$_[0]) }
1;
HERE
    || eval <<'HERE'
sub __ { $_[0] };
1;
HERE
  || die $@;
}

1;
__END__
