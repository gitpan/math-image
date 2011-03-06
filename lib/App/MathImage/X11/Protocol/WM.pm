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


# rootwin for ewmh virtual root?

package App::MathImage::X11::Protocol::WM;
use 5.004;
use strict;
use List::Util 'max';  # 5.6 ?

use vars '$VERSION', '@ISA', '@EXPORT_OK';
$VERSION = 47;

use Exporter;
@ISA = ('Exporter');
@EXPORT_OK = qw(set_transient_for
                set_netwm_window_type);

# uncomment this to run the ### lines
#use Smart::Comments;

use constant _XA_ATOM => 4;
use constant _XA_WINDOW => 33;
use constant _XA_WM_HINTS => 35;
use constant _XA_WM_TRANSIENT_FOR => 68;

sub set_transient_for {
  my ($X, $window, $transient_for) = @_;
  if (defined $transient_for) {
    $X->ChangeProperty ($window,
                        _XA_WM_TRANSIENT_FOR,  # prop name
                        _XA_WINDOW,            # type
                        32,                    # format
                        'Replace',
                        pack ('L', $transient_for));
  } else {
    $X->DeleteProperty ($window, _XA_WM_TRANSIENT_FOR);
  }
}

sub set_netwm_window_type {
  my ($X, $window, $type) = @_;
  my ($akey, $atype) = _atoms ($X,
                               '_NET_WM_WINDOW_TYPE',
                               "_NET_WM_WINDOW_TYPE_$type");
  $X->ChangeProperty($window,
                     $akey,     # prop name
                     _XA_ATOM,  # type
                     32,        # format
                     'Replace',
                     pack ('L', $atype));
}

sub _atoms {
  my $X = shift;
  return map {$X->atom($_)} @_;
}

1;
__END__
