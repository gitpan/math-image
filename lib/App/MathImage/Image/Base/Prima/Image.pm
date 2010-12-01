# Copyright 2010 Kevin Ryde

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


package App::MathImage::Image::Base::Prima::Image;
use 5.004;
use strict;
use warnings;
use Carp;
use Prima;
use vars '$VERSION', '@ISA';

use App::MathImage::Image::Base::Prima::Drawable;
@ISA = ('App::MathImage::Image::Base::Prima::Drawable');

$VERSION = 34;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Prima-Image new: \%params

  if (exists $params{'-image'}) {
    $params{'-drawable'} = delete $params{'-image'};
  }

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    if (! defined $params{'-drawable'}) {
      $params{'-drawable'} = $class->{'-drawable'}->dup;
    }
    # inherit everything else, in particular '-file'
    %params = (%$class,
               %params);
  }

  if (! exists $params{'-drawable'}) {
    ### create new Prima-Image
    $params{'-drawable'} = Prima::Image->new;
  }

  return $class->SUPER::new (%params);
}

my %get_methods = (-codecID  => 'codecID');
sub _get {
  my ($self, $key) = @_;
  ### Prima-Image _get(): $key
  if (my $method = $get_methods{$key}) {
    return $self->{'-drawable'}->$method;
  }
  if ($key eq '-file_format') {
    return _codecid_to_format ($self->{'-drawable'}->codecID);
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  if (defined (my $format = delete $params{'-file_format'})) {
    my $drawable = $params{'-drawable'} || $self->{'-drawable'};
    $drawable->{'extras'}->{'codecID'} = _format_to_codecid($format);
  }
  $self->SUPER::set(%params);
}

sub _codecid_to_format {
  my ($codecid) = @_;
  if (! defined $codecid) {
    return undef;
  }
  return Prima::Image->codecs->[$codecid]->{'fileShortType'};
}
sub _format_to_codecid {
  my ($format) = @_;
  my $codecs = Prima::Image->codecs;
  foreach my $id (0 .. $#$codecs) {
    if ($codecs->[$id]->{'fileShortType'} =~ /\Q$format/i) {
      return $id;
    }
  }
  croak "No Prima codec for format $format";
}

sub load {
  my ($self, $filename) = @_;
  ### Prima-Drawable load()
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  ### $filename

  $self->{'-drawable'}->load ("$filename", loadExtras => 1)
    or croak "Error loading $filename: $@";
}

sub load_fh {
  my ($self, $fh) = @_;
  ### Prima-Drawable load_fh()
  $self->{'-drawable'}->load ($fh)
    or croak $@;
}

sub save {
  my ($self, $filename) = @_;
  ### Prima-Drawable save(): @_
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename

  # uses $im->{'extras'}->{'codecID'} if set, otherwise filename extension
  $self->{'-drawable'}->save ("$filename")
    or croak "Error saving $filename: $@";
}

sub save_fh {
  my ($self, $fh) = @_;
  # uses $im->{'extras'}->{'codecID'} and croaks if that not set
  $self->{'-drawable'}->save ($fh)
    or croak $@;
}

1;
__END__

=for stopwords Ryde Prima .png PNG JPEG filename

=head1 NAME

App::MathImage::Image::Base::Prima::Image -- draw into Prima image

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Prima::Image;
 my $image = App::MathImage::Image::Base::Prima::Image->new
               (-width => 200, -height => 100);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Prima::Image> is a subclass of
C<App::MathImage::Image::Base::Prima::Drawable>,

    Image::Base
      App::MathImage::Image::Base::Prima::Drawable
        App::MathImage::Image::Base::Prima::Image

=head1 DESCRIPTION

C<App::MathImage::Image::Base::Prima::Image> extends C<Image::Base> to
create and draw into C<Prima::Image> objects, including file loading and
saving.

See C<App::MathImage::Image::Base::Prima::Drawable> for the actual drawing
operation.  This subclass adds image creation and file load/save.

=head1 FUNCTIONS

=over 4

=item C<$image = App::MathImage::Image::Base::Prima::Image-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A new C<Prima::Image> object can be
created, usually a C<-width> and C<-height> though it also works to set them
later,

    $ibase = App::MathImage::Image::Base::Prima::Image->new
               (-width => 200,
                -height => 100);;

Or an existing C<Prima::Image> object can be given

    $ibase = App::MathImage::Image::Base::Prima::Image->new
               (-drawable => $pimage);

=item C<$image-E<gt>load>

=item C<$image-E<gt>load ($filename)>

Load from C<-file>, or with C<$filename> set C<-file> then load.

The Prima C<loadExtras> option is used so as to get the file format
C<codecID> in the underlying image.  

=item C<$image-E<gt>save>

=item C<$image-E<gt>save ($filename)>

Save to C<-file>, or with C<$filename> set C<-file> then save to that.

As per Prima C<save>, the file format is taken from the underlying
C<$primaimage-E<gt>{'extras'}-E<gt>{'codecID'}> if that's set, otherwise the
filename extension.

=back

=head1 ATTRIBUTES

=over

=item C<-file> (string)

For saving Prima takes the file format from the filename extension, for
example ".png".  See L<Prima::image-load>.

=item C<-file_format> (string or C<undef>)

The file format as a string like "PNG" or "JPEG", or C<undef> if unknown or
never set.  Getting or setting C<-file_format> operates on the underlying
C<$primaimage-E<gt>{'extras'}-E<gt>{'codecID'}> field.

=item C<-width> (integer, read-only)

=item C<-height> (integer, read-only)

The width and height of the underlying drawable.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Prima::Image>,
L<Prima::image-load>

=cut
