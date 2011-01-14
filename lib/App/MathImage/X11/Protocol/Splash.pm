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


package App::MathImage::X11::Protocol::Splash;
use 5.004;
use strict;
use warnings;
use List::Util 'max';

use vars '$VERSION';
$VERSION = 41;

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %self) = @_;
  return bless \%self, $class;
}

sub DESTROY {
  my ($self) = @_;
  if (my $win = $self->{'window'}) {
    $self->{'X'}->DestroyWindow ($win);
  }
}

sub popup {
  my ($self) = @_;
  $self->{'X'}->MapWindow ($self->create_window);
}

sub create_window {
  my ($self) = @_;
  if (! $self->{'window'}) {
    my $X = $self->{'X'};
    my $pixmap = $self->{'pixmap'};
    my $width = $self->{'width'};
    my $height = $self->{'height'};
    if (! defined $width || ! defined $height) {
      my %geom = $X->GetGeometry($pixmap);
      $width = $self->{'width'} =  $geom{'width'};
      $height = $self->{'height'} = $geom{'height'};
    }
    my $x = int (max (0, $X->{'width_in_pixels'} - $width) / 2);
    my $y = int (max (0, $X->{'height_in_pixels'} - $height) / 2);

    ### sync: $X->QueryPointer($X->{'root'})
    my $win = $X->new_rsrc;
    $X->CreateWindow ($win,
                      $X->{'root'},     # parent
                      'InputOutput',
                      0,                # depth
                      'CopyFromParent', # visual
                      $x,$y,
                      $width,$height,
                      0,                # border
                      background_pixmap => $pixmap,
                      override_redirect => 1,
                      save_under => 1);
    ### sync: $X->QueryPointer($X->{'root'})
    $self->{'window'} = $win;
  }
  return $self->{'window'};
}

sub popdown {
  my ($self) = @_;
  if (my $win = $self->{'window'}) {
    $self->{'X'}->UnmapWindow ($win);
  }
}

1;
__END__

=for stopwords Math-Image Ryde

=head1 NAME

App::MathImage::X11::Protocol::Splash -- temporary splash window

=for test_synopsis my ($X, $id)

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::Splash;
 my $splash = App::MathImage::X11::Protocol::Splash->new
                (X => $X,
                 pixmap => $id);
 $splash->popup;
 # ...
 $splash->popdown;

=head1 DESCRIPTION

...

=head1 FUNCTIONS

=over 4

=item C<< $splash = App::MathImage::X11::Protocol::Splash->new (key=>value,...) >>

Create and return a new C<Splash> object.  The key/value parameters are

    X         X11::Protocol object (mandatory)
    pixmap    xid of pixmap to display
    width     integer (optional)
    height    integer (optional)

=item C<< $splash->popup >>

=item C<< $splash->popdown >>

=back

=head1 SEE ALSO

L<X11::Protocol>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see L<http://www.gnu.org/licenses/>.

=cut
