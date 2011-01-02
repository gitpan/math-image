# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


package App::MathImage::Gtk2::Ex::ToolbarBits;
use 5.010;
use strict;
use warnings;

use Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = qw(move_item_after);

our $VERSION = 38;

# uncomment this to run the ### lines
#use Smart::Comments;

sub move_item_after {
  my ($toolbar, $item, $after_item) = @_;

  # get_item_index() gives a g_log() if $after_item is not in $toolbar.
  # Could croak, but the log is enough report for now.
  #
  my $target_pos = $toolbar->get_item_index($after_item) + 1;

  if (my $parent = $item->get_parent) {
    if ($parent == $toolbar
        && $toolbar->get_item_index ($item) == $target_pos) {
      return; # already right
    }
    $toolbar->remove ($item);
  }
  $toolbar->insert ($item, $target_pos);
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::Gtk2::Ex::ToolbarBits -- helpers for Gtk2::Toolbar objects

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::ToolbarBits;

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::Gtk2::Ex::ToolbarBits::move_item_after ($toolbar, $item, $after_item) >>

Move C<$item> to immediately after C<$after_item> within C<$toolbar>.

There's no native move operation in C<Gtk2::Toolbar>, so this is a remove
and re-insert if C<$item> isn't already in the right position.

=back

=head1 SEE ALSO

L<Gtk2::Toolbar>, L<Gtk2::Ex::WidgetBits>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-image/index.html>

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
