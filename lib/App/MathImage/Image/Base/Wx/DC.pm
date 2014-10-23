# Copyright, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


package App::MathImage::Image::Base::Wx::DC;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 80;

use Image::Base;
@ISA = ('Image::Base');

# uncomment this to run the ### lines
#use Devel::Comments;


sub new {
  my ($class, %params) = @_;
  my $self = bless { _pen_colour => '',
                     _brush_colour => '',
                   }, $class;
  ### Image-Base-Wx-DC new: $self
  $self->set (%params);
  return $self;
}

my %attr_to_get_method = (-width => sub { $_[0]->GetSize->GetWidth },
                          -height => sub { $_[0]->GetSize->GetHeight },
                         );
sub _get {
  my ($self, $key) = @_;

  if (my $method = $attr_to_get_method{$key}) {
    return $self->{'-dc'}->$method();
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  ### Image-Base-Wx-DC set: \%params

  foreach my $key ('-width','-height') {
    if (exists $params{$key}) {
      croak "Attribute $key is read-only";
    }
  }

  if (exists $params{'-dc'}) {
    $params{'_pen_colour'} = '';
    $params{'_brush_colour'} = '';
  }

  %$self = (%$self, %params);
  ### set leaves: $self
}

#------------------------------------------------------------------------------
# drawing

sub xy {
  my ($self, $x, $y, $colour) = @_;
  my $dc = $self->{'-dc'};
  if (@_ >= 4) {
    ### Image-DC xy: "$x, $y, $colour"
    _dc_pen($self,$colour)->DrawPoint ($x, $y);
  } else {
    ### Image-DC xy() fetch: "$x, $y"
    my $c = $self->{'-dc'}->GetPixel ($x,$y);
    ### $c
    ### c str: $c->GetAsString(4)
    return ($c && $c->GetAsString(Wx::wxC2S_HTML_SYNTAX()));
  }
}

# sub Image_Base_Other_xy_points {
#   my $self = shift;
#   my $colour = shift;
#   ### Image_Base_Other_xy_points $colour
#   ### len: scalar(@_)
#   @_ or return;
# 
#   ### dc: $self->{'-dc'}
#   ### brush: $self->brush_for_colour($colour)
#   unshift @_, $self->{'-dc'}, $self->brush_for_colour($colour);
#   ### len: scalar(@_)
#   ### $_[0]
#   ### $_[1]
# 
#   # shift/unshift changes the first two args from self,colour to dc,brush
#   # does that save stack copying?
#   my $code = $self->{'-dc'}->can('draw_points');
#   goto &$code;
# 
#   # the plain equivalent ...
#   # $self->{'-dc'}->draw_points ($self->brush_for_colour($colour), @_);
# }

sub line {
  my ($self, $x1,$y1, $x2,$y2, $colour) = @_;
  ### Image-DC line()
  _dc_pen($self,$colour)->DrawLine ($x1,$y1, $x2,$y2);
}

# $x1==$x2 and $y1==$y2 on $fill==false may or may not draw that x,y point
# outline with brush line_width==0
    # or alternately $dc->draw_point ($brush, $x1,$y1);
#
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  # ### Image-DC rectangle: "$x1, $y1, $x2, $y2, $colour, $fill"

  _dc_fill($self,$colour,$fill)->DrawRectangle ($x1, $y1, $x2-$x1+1, $y2-$y1+1);
}

sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-DC ellipse: "$x1, $y1, $x2, $y2, $colour, ".($fill||0)

  # Something fishy happens when width=0 or height=0 to DrawEllipse() where
  # the last pixel is not drawn.  Might be the usual X11 left/above rule, or
  # wx not quite coping with that rule.  In any case Nx1 and 1xN can be done
  # as rectangles.
  #
  my $w = $x2-$x1;
  my $h = $y2-$y1;
  my $dc = _dc_fill($self,$colour,$fill);
  if ($w == 0 || $h == 0) {
    $dc->DrawRectangle ($x1, $y1, $w+1, $h+1);
  } else {
    $dc->DrawEllipse ($x1,$y1, $w, $h);
  }
}

sub diamond {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-DC diamond: "$x1, $y1, $x2, $y2, $colour, ".($fill||0)

  my $xh = ($x2 - $x1);
  my $yh = ($y2 - $y1);
  my $xeven = ($xh & 1);
  my $yeven = ($yh & 1);
  $xh = int($xh / 2);
  $yh = int($yh / 2);
  ### assert: $x1+$xh+$xeven == $x2-$xh
  ### assert: $y1+$yh+$yeven == $y2-$yh

  _dc_fill($self,$colour,$fill)->DrawPolygon
    ([
      Wx::Point->new($x1+$xh, $y1),  # top centre

      # left
      Wx::Point->new($x1, $y1+$yh),
      ($yeven ? Wx::Point->new($x1, $y2-$yh) : ()),

      # bottom
      Wx::Point->new($x1+$xh, $y2),
      ($xeven ? Wx::Point->new($x2-$xh, $y2) : ()),

      # right
      ($yeven ? Wx::Point->new($x2, $y2-$yh) : ()),
      Wx::Point->new($x2, $y1+$yh),

      ($xeven ? Wx::Point->new($x2-$xh, $y1) : ()),
      Wx::Point->new($x1+$xh, $y1),  # back to start
     ],
     0,0);
}

#------------------------------------------------------------------------------
# colours

sub _dc_fill {
  my ($self, $colour, $fill) = @_;

  my $dc = _dc_pen($self,$colour);
  if ($fill) {
    if ($colour ne $self->{'_brush_colour'}) {
      ### _dc_fill() change brush: $colour, $fill

      my $brush = $dc->GetBrush;
      $brush->SetColour(Wx::Colour->new($colour));
      $brush->SetStyle (Wx::wxSOLID());
      $dc->SetBrush($brush);

      $self->{'_brush_colour'} = $colour;
    }
  } else {
    if ($self->{'_brush_colour'} ne 'None') {
      ### _dc_fill() change brush transparent ...

      # or ...
      # $dc->SetBrush (Wx::wxTRANSPARENT_BRUSH());

      my $brush = $dc->GetBrush;
      $brush->SetStyle (Wx::wxTRANSPARENT());
      $dc->SetBrush($brush);

      $self->{'_brush_colour'} = 'None';
    }
  }
  return $dc;
}

sub _dc_pen {
  my ($self, $colour) = @_;
  my $dc = $self->{'-dc'};
  if ($colour ne $self->{'_pen_colour'}) {
    ### _dc_pen() change: $colour

    my $pen = $dc->GetPen;
    $pen->SetColour(Wx::Colour->new($colour));
    $dc->SetPen($pen);

    $self->{'_pen_colour'} = $colour;
  }
  return $dc;
}

1;
__END__

=for stopwords resized filename Ryde bitmap Image-Base-Wx-DC

=head1 NAME

App::MathImage::Image::Base::Wx::DC -- draw into a Wx::DC

=for test_synopsis my $dc

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Wx::DC;
 my $image = App::MathImage::Image::Base::Wx::DC->new
                 (-dc => $dc);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Wx::DC> is a subclass of C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::Wx::DC

=head1 DESCRIPTION

I<In progress ...>

C<App::MathImage::Image::Base::Wx::DC> extends C<Image::Base> to draw into a
C<Wx::DC>.

Native C<Wx::DC> does much more than C<Image::Base> but if you have some
generic pixel twiddling code for C<Image::Base> then this class lets you
point it at a Wx paint for window, printer, etc.

=head2 Colour Names

Colour names are anything recognised by C<< Wx::Colour->new() >>, which
means various names like "pink" plus hex #RRGGBB or #RRRRGGGGBBB.

=head1 FUNCTIONS

See L<Image::Base/FUNCTIONS> for the behaviour common to all Image-Base
classes.

=over 4

=item C<$image = App::MathImage::Image::Base::Wx::DC-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A C<-dc> parameter must be
given,

    $image = App::MathImage::Image::Base::Wx::DC->new
                 (-dc => $dc);

Further parameters are applied per C<set> (see L</ATTRIBUTES> below).

=item C<$image-E<gt>xy ($x, $y, $colour)>

Get or set the pixel at C<$x>,C<$y>.

Getting a pixel is per C<Wx::DC> C<GetPixel()>.  In the current code colours
are returned in "#RRGGBB" form (C<wxC2S_HTML_SYNTAX> of C<Wx::Colour>).

=back

=head1 ATTRIBUTES

=over

=item C<-dc> (C<Wx::DC> object)

The target dc.

=item C<-width>, C<-height> (read-only)

The size of the DC's target, as per C<$dc-E<gt>GetSize()>.

=back

=head1 SEE ALSO

L<Wx>

=cut
