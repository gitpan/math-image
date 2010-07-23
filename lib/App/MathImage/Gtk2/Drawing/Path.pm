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


package App::MathImage::Gtk2::Drawing::Path;
use 5.008;
use strict;
use warnings;
use Locale::Messages;
use App::MathImage::Generator;
use App::MathImage::Gtk2::Drawing::Values;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 11;

Glib::Type->register_enum ('App::MathImage::Gtk2::Drawing::Path',
                           App::MathImage::Generator->path_choices);

use constant::defer model => sub {
  require Text::Capitalize;
  my $model = Gtk2::ListStore->new ('App::MathImage::Gtk2::Drawing::Path',
                                    'Glib::String');

  foreach my $elem (Glib::Type->list_values
                    ('App::MathImage::Gtk2::Drawing::Path')) {
    ### $elem
    my $nick = $elem->{'nick'};
    my $display = App::MathImage::Gtk2::Drawing::Values::key_to_display($nick);
    $display = Locale::Messages::dgettext
      ('Math-Image', Text::Capitalize::capitalize_title($display));
    ### $display
    $model->set ($model->append,
                 0, $nick,
                 1, $display);
  }
  return $model;
};

use constant::defer model_rows_hash => sub {
  my %hash;
  model()->foreach (sub {
                      my ($model, $path, $iter) = @_;
                      my ($n) = $path->get_indices;
                      my $nick = $model->get_value($iter,0);
                      $hash{$n} = $nick;
                      $hash{$nick} = $n;
                      return 0; # continue;
                    });
  return \%hash;
};

1;
__END__
