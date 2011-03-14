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

package App::MathImage::X11::Protocol::Splash;
use 5.004;
use strict;
use Carp;
use List::Util 'max';  # 5.6 ?
use App::MathImage::X11::Protocol::WM;

use vars '$VERSION';
$VERSION = 48;

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

sub popdown {
  my ($self) = @_;
  if (my $win = $self->{'window'}) {
    $self->{'X'}->UnmapWindow ($win);
  }
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
    my $window = $X->new_rsrc;
    $X->CreateWindow ($window,
                      $X->{'root'},     # parent
                      'InputOutput',
                      0,                # depth
                      'CopyFromParent', # visual
                      $x,$y,
                      $width,$height,
                      0,                # border
                      background_pixmap => $pixmap,
                      override_redirect => 1,
                      save_under        => 1);
    ### sync: $X->QueryPointer($X->{'root'})
    $self->{'window'} = $window;

    if (my $transient_for = $self->{'transient_for'}) {
      App::MathImage::X11::Protocol::WM::set_transient_for
          ($X, $window, $transient_for);
    }
    _wm_set_hints ($X, $window,
                   input => 0,
                   window_group => $self->{'window_group'});
    App::MathImage::X11::Protocol::WM::set_netwm_window_type ($X, $window, 'SPLASH');
  }
  return $self->{'window'};
}

use constant _XA_WM_HINTS => 35;

sub _wm_set_hints {
  my $X = shift;
  my $window = shift;
  $X->ChangeProperty($window,
                     _XA_WM_HINTS, # prop name
                     _XA_WM_HINTS, # type
                     32,           # format
                     'Replace',
                     _wm_pack_hints(@_));
}
{
  my $format = 'LLLLLllLL';
  # The C<urgency> hint was called "visible" in X11R5.  The name "urgency"
  # is used here per X11R6.  The actual field sent and received is the same.
  #
  my %state = (WithdrawnState => 0,
               DontCareState  => 0, # no longer in ICCCM
               NormalState    => 1,
               ZoomState      => 2, # no longer in ICCCM
               IconicState    => 3,
               InactiveState  => 4, # no longer in ICCCM
              );
  my %key_to_flag = (input         => 1,
                     initial_state => 2,
                     icon_pixmap   => 4,
                     icon_window   => 8,
                     icon_x        => 16,
                     icon_y        => 16,
                     icon_mask     => 32,
                     window_group  => 64,
                     message_hint  => 128, # obsolete
                     # urgency       => 256, # in the code
                    );
  sub _wm_pack_hints {
    my (%hint) = @_;
    my $flags = 0;
    foreach my $key (keys %hint) {
      my $bit = $key_to_flag{$key}
        || croak "Unrecognised WM_HINT field: ",$key;
      if (defined $hint{$key}) {
        $flags |= $key_to_flag{$key};
      }
    }
    if ($hint{'urgency'}) {
      $flags |= 256;
    }
    my $initial_state = $hint{'initial_state'} || 0;
    $initial_state = $state{$initial_state} || $initial_state;
    pack ($format,
          $flags,
          $hint{'input'} || 0,         # CARD32 bool
          $initial_state,              # CARD32 enum
          $hint{'icon_pixmap'} || 0,   # PIXMAP
          $hint{'icon_window'} || 0,   # WINDOW
          $hint{'icon_x'} || 0,        # INT32
          $hint{'icon_y'} || 0,        # INT32
          $hint{'icon_mask'} || 0,     # PIXMAP
          $hint{'window_group'} || 0,  # WINDOW
         )
  }

  # X11R2 Xlib had a bug were XSetWMHints() set a WM_HINTS property to only
  # 8 CARD32s, chopping off the window_group field.  In Xatomtype.h
  # NumPropWMHintsElements was 8 instead of 9.  Ignore any window_group bit
  # in the flags in that case, and don't return a window_group field.
  # (X11R2 source available at http://ftp.x.org/pub/X11R2/X.V11R2.tar.gz)
  #
  # FIXME: initial_state as symbol only under $X->{'do_interp'}
  # ...
  my @state = ('WithdrawnState', # 0
               # DontCareState  => 0, no longer ICCCM
               'NormalState',    # 1
               'ZoomState',      # 2, no longer ICCCM
               'IconicState',    # 3
               'InactiveState',  # 4, no longer in ICCCM
              );
  my @keys = ('input',
              'initial_state',
              'icon_pixmap',
              'icon_window',
              'icon_x',
              'icon_y',
              'icon_mask',
              'window_group',
              # 'message_hint',  # obsolete ...
              # 'urgency',       # in the code
             );
  sub _wm_unpack_hints {
    my ($bytes) = @_;
    my ($flags, @values) = unpack ($format, $bytes);
    my $bit = 1;
    my @ret;
    foreach my $i (0 .. $#keys) {
      my $value = $values[$i];
      if (! defined $value) {
        next;
      }
      if ($flags & $bit) {
        my $key = $keys[$i];
        if ($key eq 'initial_state') {
          $value = $state[$value] || $value;
        }
        push @ret, $key, $value;
      }
      if ($i != 4) {
        $bit <<= 1;
      }
    }
    if ($flags & 256) {
      push @ret, urgency => 1;
    }
    return @ret;
  }
}

# my %key_to_flag = (
#                    # USPosition  1     User-specified x, y
#                    # USSize      2     User-specified width, height
#                    # PPosition   4     Program-specified position
#                    # PSize       8     Program-specified size
#                    # PMinSize    16    Program-specified minimum size
#                    # PMaxSize    32    Program-specified maximum size
#                    width_inc  => 64,
#                    height_inc => 64,
#                    min_aspect     => 128,
#                    min_aspect_num => 128,
#                    min_aspect_den => 128,
#                    max_aspect     => 128,
#                    max_aspect_num => 128,
#                    max_aspect_den => 128,
#                    base_width  => 256,
#                    base_height => 256,
#                    win_gravity => 512,
#                   );
# sub _wm_normal_hints_set {
#   my ($X, $window, %hint) = @_;
# 
#   my $flags = 0;
#   foreach my $key (keys %hint) {
#     if (defined $hint{$key}) {
#       $flags |= $key_to_flag{$key};
#     }
#   }
#   my ($min_aspect_num, $min_aspect_den) = _aspect ('min', \%hint);
#   my ($max_aspect_num, $max_aspect_den) = _aspect ('min', \%hint);
#   
#   $X->ChangeProperty($window,
#                      _XA_WM_NORMAL_HINTS,  # key
#                      _XA_WM_NORMAL_HINTS,  # type
#                      32,                   # format
#                      'Replace',
#                      pack ('L*',
#                            $flags,
#                            0,0,0,0, # pad
#                            $option{'min_width   INT32         If missing, assume base_width
#                            $option{'min_height  INT32         If missing, assume base_height
#                            $option{'max_width   INT32          
#                            $option{'max_height  INT32          
#                            $option{'width_inc'},
#                            $option{'height_inc'},
#                            $option{'min_aspect_num'},$option{'min_aspect_den'},
#                            $option{'max_aspect_num'},$option{'max_aspect_den'},
#                            $option{'base_width'},
#                            $option{'base_height'},
#                            $option{'win_gravity'},
#      ));
# }
sub _aspect {
  my ($which, $hint) = @_;
  if (defined (my $aspect = $hint->{"${which}_aspect"})) {
    return _aspect_frac($aspect);
  }
  return ($hint->{"${which}_aspect_num"}, $hint->{"${which}_aspect_den"});
}
sub _aspect_frac {
  my ($aspect) = @_;
  ### $aspect
  if ($aspect =~ /^\d+$/) {
    ### integer
    return ($aspect, 1);
  }
  if ($aspect =~ m{^(\d+)/(\d+)$}) {
    ### frac: $1, $2
    return ($1, $2);
  }
  if ($aspect =~ /^0*(\d*)\.(\d+?)0*$/
      && length($1)+length($2) <= 9) {
    ### decimal: $1, $2
    return ($1.$2, '1'.('0' x length($2)));
  }
  ### float, scale up in binary
  my $den = 1;
  while ($aspect < 0x4000_0000 && $den < 0x4000_0000) {
    if ($aspect == int($aspect)) {
      last;
    }
    $aspect *= 2;
    $den *= 2;
    ### up to: $aspect,$den
  }
  return (int($aspect + 0.5), $den);
}
# printf "%d %d", _aspect_frac('.123456789');

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

Create and return a new Splash object.  The key/value parameters are

    X         X11::Protocol object (mandatory)
    pixmap    xid of pixmap to display
    width     integer (optional)
    height    integer (optional)

=item C<< $splash->popup >>

=item C<< $splash->popdown >>

=back

=head1 SEE ALSO

L<X11::Protocol>,
L<X11::Protocol::Other>

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
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
