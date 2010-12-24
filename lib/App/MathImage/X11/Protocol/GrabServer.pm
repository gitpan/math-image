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


package App::MathImage::X11::Protocol::GrabServer;
use strict;
use warnings;
BEGIN {
  # needing the XS version of Scalar::Util and new enough to have weakening
  eval "use Scalar::Util 'weaken'; 1"
    or *weaken = sub {};
}

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, $X) = @_;
  my $self = bless { X => $X }, $class;
  weaken ($self->{'X'});
  $self->grab;
  return $self;
}
sub DESTROY {
  my ($self) = @_;
  $self->ungrab;
}

sub grab {
  my ($self) = @_;
  ### GrabServer-object grab()
  unless ($self->{'grabbed'}) {
    my $X = $self->{'X'} || return;
    $self->{'grabbed'} = 1;
    if (! $X->{__PACKAGE__.'.count'}++) {
      ### initial X->GrabServer
      $X->GrabServer;
    }
  }
  ### grab count now: $self->{'X'} && $self->{'X'}->{__PACKAGE__.'.count'}
}

sub ungrab {
  my ($self, $value) = @_;
  ### GrabServer-object ungrab()
  if (delete $self->{'grabbed'}) {
    my $X = $self->{'X'} || return;
    if (--$X->{__PACKAGE__.'.count'} <= 0) {
      delete $X->{__PACKAGE__.'.count'};
      ### final X->UngrabServer
      $X->UngrabServer;
      $X->flush;
    }
  }
  ### grab count now: $self->{'X'} && $self->{'X'}->{__PACKAGE__.'.count'}
}

sub call_with_grab {
  my $class = shift;
  my $X = shift;
  my $subr = shift;
  my $grab = $class->new ($X);
  &$subr (@_);
}

1;
__END__

=for stopwords Ryde GrabServer ungrab ungrabs ungrabbed

=head1 NAME

App::MathImage::X11::Protocol::GrabServer -- object-oriented server grabbing

=for test_synopsis my ($X)

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::GrabServer;
 {
   my $grab = App::MathImage::X11::Protocol::GrabServer->new ($X); 
   ...
   # UngrabServer when $grab destroyed
 }

=head1 DESCRIPTION

This is an object-oriented approach to GrabServer.  A grab object represents
a desired grab.  When the last is destroyed an C<$X-E<gt>UngrabServer> is
done.

It can be used in a block as a kind of scope guard to grab the server to
make a few operations atomic (usually for something global like root window
properties etc).  Grabs done this way can nest or overlap which is good for
a library where an ungrab should wait until the end of any outermost desired
grab.

A grab object can be held for an extended time, perhaps for some state
driven interaction, but care should be taken not to hold the server too
long, as other client programs are locked out.

When weak references are available (Perl 5.6 and up), only a weak reference
is held to the target C<X11::Protocol> object.  This means the grab doesn't
keep it alive and connected once nothing else is interested.  The server
ungrabs automatically when the connection is closed, so there's no need for
an C<$X-E<gt>UngrabServer> in that case.

=head1 FUNCTIONS

=over 4

=item C<< $grab = App::MathImage::X11::Protocol::GrabServer->new ($X) >>

C<$X> should be an C<X11::Protocol> object.  Grab the server with
C<$X-E<gt>GrabServer> (if not already done)and return a C<$grab> object
representing the grab.

=item C<< $grab->ungrab >>

Explicitly ungrab the C<$grab> object.  This happens when C<$grab> is
destroyed, but can be done sooner if desired.  If C<$grab> has already been
ungrabbed then nothing is done.

=back

=head1 SEE ALSO

L<X11::Protocol>,
L<App::MathImage::X11::Protocol::Extras>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010 Kevin Ryde

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
