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


package App::MathImage::Image::Base::SVG;
use 5.004;
use strict;
use Carp;
use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 60;

# uncomment this to run the ### lines
#use Devel::Comments '###';

sub new {
  my $class = shift;
  my $self = bless { @_ }, $class;
  $self->{'-svg_object'} ||= do {
    require SVG;
    SVG->new;
  };
  return $self;
}

sub set {
  my ($self, %option) = @_;
  my $svg = $option{'-svg_object'} || $self->{'-svg_object'};
  if (exists $option{'-title'}) {
    $svg->title->cdata (delete $option{'-title'});
  }
  if (exists $option{'-description'}) {
    $svg->description->cdata (delete $option{'-description'});
  }
  %$self = (%$self, @_);
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  ### Image-Base-SVG xy(): @_[1 .. $#_]

  my $svg = $self->{'-svg_object'};
  if (@_ == 3) {
    return undef;  # no pixel fetching available
  } else {
    $svg->rectangle (x => $x, y => $y,
                     width => 1, height => 1,
                     fill => $colour);
  }
}

sub rectangle {
  my ($self, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  ### Image-Base-SVG rectangle(): @_[1 .. $#_]

  if ($x1 == $x2 || $y1 == $y2) {
    $self->line ($x1,$y1, $x2,$y2, $colour);
  } else {
    if (! $fill) {
      $x1 += .5;
      $y1 += .5;
      $x2 -= .5;
      $y2 -= .5;
    }
    $self->{'-svg_object'}->rectangle (x => $x1,
                                       y => $y1,
                                       width  => abs($x2-$x1)+1,
                                       height => abs($y2-$y1)+1,
                                       ($fill?'fill':'stroke') => $colour);
  }
}

sub ellipse {
  my ($self, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  ### Image-Base-SVG rectangle(): @_[1 .. $#_]

  if ($x1 == $x2 || $y1 == $y2) {
    $self->line ($x1,$y1, $x2,$y2, $colour);
  } else {
    my $rx = (abs($x1-$x2) / 2);
    my $ry = (abs($y1-$y2) / 2);
    if ($fill) {
      $rx += .5;
      $ry += .5;
    }
    $self->{'-svg_object'}->ellipse (cx => ($x1+$x2) / 2,
                                     cy => ($y1+$y2) / 2,
                                     rx => $rx,
                                     ry => $ry,
                                     ($fill?'fill':'stroke') => $colour);
  }
}

sub line {
  my ($self, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  ### Image-Base-SVG rectangle(): @_[1 .. $#_]

  $self->{'-svg_object'}->line (x1 => $x1+.5,
                                y1 => $y1+.5,
                                x2 => $x2+.5,
                                y2 => $y2+.5,
                                stroke => $colour,
                                'stroke-linecap' => "square");
}

sub load {
  my ($self, $filename) = @_;
  croak "Image::Base::SVG is output-only";
}

sub save {
  my ($self, $filename) = @_;
  ### Image-Base-SVG save(): @_
  if (@_ > 1) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename

  require Fcntl;
  sysopen FH, $filename, Fcntl::O_WRONLY() | Fcntl::O_TRUNC() | Fcntl::O_CREAT()
    or croak "Cannot create $filename: $!";

  if (! $self->save_fh (\*FH)) {
    my $err = "Error writing $filename: $!";
    { local $!; close FH; }
    croak $err;
  }
  close FH
    or croak "Error closing $filename: $!";
}

# use constant::defer _SVG_credit => sub {
#   require SVG;
#   my $svg = SVG->new;
#   $svg->xmlify;
#   return (_get_comments($svg))[0];
# };
# print _SVG_credit();
# 
# sub _get_comments {
#   my ($svg) = @_;
#   ### _get_comments(): "$svg"
#   $svg->comment('x','y');
#   {  my $tag = $svg->tag('comment');
#      ### tag: "$tag"
#      ### comm: $tag->{'-comment'}
#    }
#   { my $tag = $svg->tag('comment');
#     ### tag: "$tag"
#     ### comm: $tag->{'-comment'}
#   }
#   { my $tag = $svg->tag('comment');
#     ### tag: "$tag"
#     ### comm: $tag->{'-comment'}
#   }
#   if (defined (my $tag = $svg->tag('comment'))) {
#     if (defined (my $aref = $tag->{'-comment'})) {
#       ### $aref
#       if (ref $aref eq 'ARRAY') {
#         return @$aref;
#       }
#     }
#   }
#   return;
# }

# not yet documented ...
sub save_fh {
  my ($self, $fh) = @_;
  ### save_fh() ...
  ### elements: $self->{'-elements'}
  ### height: $self->{'-height'}

  my $svg = $self->{'-svg_object'};
  # $svg->comment
  #   ("\n\tGenerated using ".ref($self)." version ".$self->VERSION." and:\n",
  #    _SVG_credit());
  return print $fh $svg->xmlify;
}

my %entity = ('&' => '&amp;',
             '"' => '&quot;',
             '<' => '&lt;',
             '>' => '&gt;',
            );
sub _entitize {
  my ($value) = @_;
  $value =~ s/([&"<>])/$entity{$1}/eg;
  return $value;
}

sub _attribute_quote {
  my ($value) = @_;
  return '"'._entitize($value).'"';
}

1;
__END__

=for stopwords SVG filename Ryde

=head1 NAME

App::MathImage::Image::Base::SVG -- SVG image file output

=head1 SYNOPSIS

 use App::MathImage::Image::Base::SVG;
 my $image = App::MathImage::Image::Base::SVG->new (-width => 100,
                                                       -height => 100);
 $image->rectangle (0,0, 99,99, 'b');
 $image->xy (20,20, 'o');
 $image->line (50,50, 70,70, 'o');
 $image->line (50,50, 70,70, 'o');
 $image->save ('/some/filename.rle');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::SVG> is a subclass of C<Image::Base>,

    Image::Base
      App::MathImage::Image::Base::SVG

=head1 DESCRIPTION

C<App::MathImage::Image::Base::SVG> extends C<Image::Base> to create SVG
format image files.

The colour names are ...

=head1 FUNCTIONS

=over 4

=item C<$image = App::MathImage::Image::Base::SVG-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A new image can be started with
C<-width> and C<-height>,

    $image = App::MathImage::Image::Base::SVG->new (-width => 200, -height => 100);

=item C<$image-E<gt>save ()>

=item C<$image-E<gt>save ($filename)>

Save the image to an SVG file, either the current C<-file> option, or set
that option to C<$filename> and save to there.

=back

=head1 SEE ALSO

L<Image::Base>

=cut
