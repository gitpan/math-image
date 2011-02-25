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


package App::MathImage::X11::Protocol::GrabServer;
use strict;
BEGIN {
  # weaken() if available, which means new enough Perl to have weakening,
  # and Scalar::Util with its XS code
  eval "use Scalar::Util 'weaken'; 1"
    or eval "#line ".(__LINE__+1)." \"".__FILE__."\"\n" . <<'HERE' or die;
sub weaken {} # otherwise noop
HERE
}

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 45;

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
      delete $X->{__PACKAGE__.'.count'}; # cleanup
      ### final X->UngrabServer
      $X->UngrabServer;
      $X->flush;
    }
  }
  ### grab count now: $self->{'X'} && $self->{'X'}->{__PACKAGE__.'.count'}
}

# # not sure about this ...
# sub call_with_grab {
#   my $class = shift;
#   my $X = shift;
#   my $subr = shift;
#   my $grab = $class->new ($X);
#   &$subr (@_);
# }

1;
__END__

=for stopwords Ryde GrabServer UngrabServer ungrab ungrabs ungrabbed

=head1 NAME

App::MathImage::X11::Protocol::GrabServer -- object-oriented server grabbing

=for test_synopsis my ($X)

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::GrabServer;
 {
   my $grab = App::MathImage::X11::Protocol::GrabServer->new ($X); 
   do_some_things();
   # UngrabServer when $grab destroyed
 }

=head1 DESCRIPTION

This is an object-oriented approach to GrabServer / UngrabServer.  A grab
object represents a desired server grab on an C<X11::Protocol> connection.
The first grab object created does a GrabServer and the last to be destroyed
does an UngrabServer.

The idea is that is can be easier to manage the lifespan of an object in a
block or a state object than to be sure of catching all exits.  Grab objects
can nest or overlap, which is good in a library or sub-function where the
ungrab should wait until the end of the outermost desired grab.

A server grab is usually done to make a few operations atomic, usually
something global like root window properties etc.  The block-based temporary
object shown in the synopsis above is typical.  It's also possible to hold a
grab object for an extended time, perhaps for some state driven interaction,
but care should be taken not to grab for too long since other client
programs are locked out.

=head2 Weak C<$X>

If weak references are available, which means Perl 5.6 and up and
C<Scalar::Util> XS code, then only a weak reference is held to the target
C<X11::Protocol> object.  This means the grab doesn't keep it alive and
connected once nothing else is interested.  When the connection is destroyed
the server ungrabs automatically, so there's no need for an explicit
C<$X-E<gt>UngrabServer> in that case.

The effect of the weakening is that C<$X> can be destroyed anywhere within a
grab block once nothing else refers to it, the same as if there was no grab.
Without the weakening it would wait until the end of the block.  In practice
this is unlikely to make much difference.

=head1 FUNCTIONS

=over 4

=item C<< $grab = App::MathImage::X11::Protocol::GrabServer->new ($X) >>

C<$X> should be an C<X11::Protocol> object.  Create and return a C<$grab>
object representing a grab of the C<$X> server.

If this new grab object is the only one currently on C<$X> then do an
C<$X-E<gt>GrabServer>.

=item C<< $grab->grab >>

=item C<< $grab->ungrab >>

Explicitly grab or ungrab the C<$grab> object.  If it's already grabbing or
not grabbing then do nothing.

An ungrab is done automatically when C<$grab> is destroyed, but
C<$grab-E<gt>ungrab()> can do it sooner.  A C<$grab-E<gt>grab()> can re-grab
with that object if desired.

=back

=head1 SEE ALSO

L<X11::Protocol>,
L<App::MathImage::X11::Protocol::MoreUtils>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

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
