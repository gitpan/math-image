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

package App::MathImage::LinesTree;
use 5.004;
use strict;
use Locale::TextDomain 'App-MathImage';

# uncomment this to run the ### lines
#use Smart::Comments;


use vars '$VERSION','@ISA';
$VERSION = 99;
use Math::NumSeq::All;
@ISA = ('Math::NumSeq::All');

use constant name => __('Lines by Tree');
use constant description => __('No numbers, instead lines showing the path taken.');
use constant parameter_info_array => [ { name    => 'branches',
                                         display => __('Branches'),
                                         type    => 'integer',
                                         default => 3,
                                         minimum => 2,
                                         width   => 3,
                                         # description => __('...'),
                                       },
                                     ];

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::LinesTree -- tree line drawing

=head1 DESCRIPTION

This is a special kind of "values" which draws lines between the points of
the path in a tree structure.

The current code might be a bit broken.

=head1 SEE ALSO

L<App::MathImage::Lines>,
L<App::MathImage::LinesLevel>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011, 2012 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
